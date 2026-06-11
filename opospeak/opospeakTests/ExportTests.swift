//
//  ExportTests.swift
//  opospeakTests
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import Testing
import SwiftData
@testable import opospeak

@MainActor
struct ExportTests {

    // Mismo patrón que el resto de suites: esquema compartido y
    // contenedores retenidos para evitar el crash de deinit de SwiftData.
    private static let sharedSchema = Schema([
        Oposicion.self, Temario.self, Tema.self, Sesion.self, Intento.self,
        Grabacion.self, Metrica.self, Nota.self,
    ])
    private static var retainedContainers: [ModelContainer] = []

    private struct Entorno {
        let context: ModelContext
        let store: RecordingStore
        let service: ExportService
    }

    private func makeEntorno() throws -> Entorno {
        let config = ModelConfiguration(
            "test-\(UUID().uuidString)",
            schema: Self.sharedSchema,
            isStoredInMemoryOnly: true
        )
        let container = try ModelContainer(for: Self.sharedSchema, configurations: [config])
        Self.retainedContainers.append(container)

        let store = RecordingStore(
            directoryURL: FileManager.default.temporaryDirectory
                .appending(path: "ExportTests-\(UUID().uuidString)")
        )
        try store.ensureDirectoryExists()

        return Entorno(
            context: container.mainContext,
            store: store,
            service: ExportService(
                modelContext: container.mainContext,
                recordingStore: store,
                appVersion: "1.0-test"
            )
        )
    }

    /// Temario (con uno archivado), 2 temas, 2 intentos — uno con grabación
    /// real en disco y nota, otro sin grabación.
    private func poblar(_ entorno: Entorno) throws -> (conGrabacion: Intento, sinGrabacion: Intento) {
        let context = entorno.context

        let oposicion = Oposicion(nombre: "Judicatura, turno libre")
        context.insert(oposicion)
        let temario = Temario(nombre: "Civil", oposicion: oposicion)
        context.insert(temario)
        let archivado = Temario(nombre: "Antiguo", oposicion: oposicion)
        archivado.activo = false
        context.insert(archivado)

        let tema1 = Tema(numero: 42, titulo: "Responsabilidad \"patrimonial\"", temario: temario)
        context.insert(tema1)
        let tema2 = Tema(numero: 7, temario: temario)
        context.insert(tema2)

        let sesion = Sesion()
        context.insert(sesion)

        let intento1 = Intento(tema: tema1, sesion: sesion, fechaInicio: Date(timeIntervalSince1970: 1_750_000_000))
        intento1.fechaFin = intento1.fechaInicio.addingTimeInterval(708)
        intento1.duracionReal = 708
        intento1.completado = true
        context.insert(intento1)

        let grabacion = Grabacion(intento: intento1, duracion: 708, tamano: 4096)
        context.insert(grabacion)
        try Data(repeating: 0xC5, count: 4096)
            .write(to: entorno.store.url(forGrabacionId: grabacion.id))

        context.insert(Metrica(intento: intento1, tipo: .duracionTotal, valor: 708))
        context.insert(Nota(intento: intento1, contenido: "Bien, pero lento"))

        let intento2 = Intento(tema: tema2, sesion: sesion, fechaInicio: Date(timeIntervalSince1970: 1_750_010_000))
        intento2.duracionReal = 300
        context.insert(intento2)

        try context.save()
        return (intento1, intento2)
    }

    private func leerJSON(_ paquete: URL, _ relativo: String) throws -> Data {
        try Data(contentsOf: paquete.appending(path: relativo))
    }

    @Test func paqueteCompletoContieneTodo() throws {
        let entorno = try makeEntorno()
        _ = try poblar(entorno)

        let paquete = try entorno.service.buildFullPackage()
        let fm = FileManager.default

        #expect(paquete.lastPathComponent == "opospeak-export")
        for archivo in ["manifest.json", "data/oposiciones.json", "data/temarios.json", "data/temas.json",
                        "data/sesiones.json", "data/intentos.json", "data/metricas.json",
                        "data/notas.json", "data/intentos.csv"] {
            #expect(
                fm.fileExists(atPath: paquete.appending(path: archivo).path(percentEncoded: false)),
                "falta \(archivo)"
            )
        }

        let grabados = try fm.contentsOfDirectory(
            atPath: paquete.appending(path: "recordings").path(percentEncoded: false)
        )
        #expect(grabados.count == 1)
        #expect(grabados[0].hasSuffix(".m4a"))
    }

    @Test func manifestCuentaLoExportado() throws {
        let entorno = try makeEntorno()
        _ = try poblar(entorno)

        let paquete = try entorno.service.buildFullPackage()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let manifest = try decoder.decode(ManifestExport.self, from: leerJSON(paquete, "manifest.json"))

        #expect(manifest.format == "opospeak-export")
        #expect(manifest.version == 2)
        #expect(manifest.appVersion == "1.0-test")
        #expect(manifest.counts.oposiciones == 1)
        #expect(manifest.counts.temarios == 2)
        #expect(manifest.counts.temas == 2)
        #expect(manifest.counts.sesiones == 1)
        #expect(manifest.counts.intentos == 2)
        #expect(manifest.counts.grabaciones == 1)
        #expect(manifest.counts.notas == 1)
        #expect(manifest.recordingFormat == "m4a")
    }

    @Test func grabacionAusenteNoBloqueaYSeRefleja() throws {
        let entorno = try makeEntorno()
        let (conGrabacion, _) = try poblar(entorno)

        // Borrar el archivo dejando los metadatos huérfanos.
        if let grabacion = conGrabacion.grabacion {
            try entorno.store.deleteRecording(id: grabacion.id)
        }

        let paquete = try entorno.service.buildFullPackage()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let manifest = try decoder.decode(ManifestExport.self, from: leerJSON(paquete, "manifest.json"))

        #expect(manifest.counts.grabaciones == 0)
        #expect(manifest.counts.intentos == 2)
    }

    @Test func relacionesSeReconstruyenPorId() throws {
        let entorno = try makeEntorno()
        _ = try poblar(entorno)

        let paquete = try entorno.service.buildFullPackage()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let oposiciones = try decoder.decode([OposicionExport].self, from: leerJSON(paquete, "data/oposiciones.json"))
        let temarios = try decoder.decode([TemarioExport].self, from: leerJSON(paquete, "data/temarios.json"))
        let temas = try decoder.decode([TemaExport].self, from: leerJSON(paquete, "data/temas.json"))
        let intentos = try decoder.decode([IntentoExport].self, from: leerJSON(paquete, "data/intentos.json"))

        let idsOposicion = Set(oposiciones.map(\.id))
        let idsTemario = Set(temarios.map(\.id))
        let idsTema = Set(temas.map(\.id))

        for temario in temarios {
            #expect(temario.oposicionId.map(idsOposicion.contains) == true)
        }
        for tema in temas where tema.activo {
            #expect(tema.temarioId.map(idsTemario.contains) == true)
        }
        for intento in intentos {
            #expect(intento.temaId.map(idsTema.contains) == true)
            if let grabacion = intento.grabacion {
                let archivo = paquete.appending(path: grabacion.archivo)
                #expect(FileManager.default.fileExists(atPath: archivo.path(percentEncoded: false)))
            }
        }
    }

    @Test func audioExportadoEsIdenticoAlOriginal() throws {
        let entorno = try makeEntorno()
        let (conGrabacion, _) = try poblar(entorno)
        let grabacion = try #require(conGrabacion.grabacion)

        let paquete = try entorno.service.buildFullPackage()
        let original = try Data(contentsOf: entorno.store.url(forGrabacionId: grabacion.id))
        let exportado = try Data(
            contentsOf: paquete.appending(path: "recordings/\(grabacion.id.uuidString).m4a")
        )
        #expect(original == exportado)
    }

    @Test func csvTieneCabeceraFilasYEscapado() throws {
        let entorno = try makeEntorno()
        _ = try poblar(entorno)

        let paquete = try entorno.service.buildFullPackage()
        let csv = try String(
            contentsOf: paquete.appending(path: "data/intentos.csv"), encoding: .utf8
        )
        let lineas = csv.split(separator: "\n")

        #expect(lineas[0] == Substring(IntentosCSV.cabecera))
        #expect(lineas.count == 3) // cabecera + 2 intentos
        // El nombre del temario contiene una coma → debe ir entre comillas.
        #expect(csv.contains("\"Judicatura, turno libre\""))
        // El título del tema contiene comillas → deben duplicarse.
        #expect(csv.contains("\"Responsabilidad \"\"patrimonial\"\"\""))
    }

    @Test func escapadoCSV() {
        #expect(IntentosCSV.escape("simple") == "simple")
        #expect(IntentosCSV.escape("con, coma") == "\"con, coma\"")
        #expect(IntentosCSV.escape("con \"comillas\"") == "\"con \"\"comillas\"\"\"")
    }

    @Test func paqueteDeIntentoConGrabacion() throws {
        let entorno = try makeEntorno()
        let (conGrabacion, _) = try poblar(entorno)
        let grabacion = try #require(conGrabacion.grabacion)

        let paquete = try entorno.service.buildIntentoPackage(intento: conGrabacion)
        let fm = FileManager.default

        #expect(paquete.lastPathComponent == "intento-\(conGrabacion.id.uuidString)")
        #expect(fm.fileExists(atPath: paquete.appending(path: "intento.json").path(percentEncoded: false)))
        #expect(fm.fileExists(atPath: paquete.appending(path: "notas.json").path(percentEncoded: false)))
        #expect(fm.fileExists(
            atPath: paquete.appending(path: "\(grabacion.id.uuidString).m4a").path(percentEncoded: false)
        ))

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let notas = try decoder.decode([NotaExport].self, from: leerJSON(paquete, "notas.json"))
        #expect(notas.count == 1)
        #expect(notas[0].contenido == "Bien, pero lento")
    }

    @Test func paqueteDeIntentoSinGrabacion() throws {
        let entorno = try makeEntorno()
        let (_, sinGrabacion) = try poblar(entorno)

        let paquete = try entorno.service.buildIntentoPackage(intento: sinGrabacion)
        let contenido = try FileManager.default.contentsOfDirectory(
            atPath: paquete.path(percentEncoded: false)
        )
        #expect(Set(contenido) == ["intento.json", "notas.json"])
    }

    @Test func archiverProduceUnZipReal() throws {
        let dir = FileManager.default.temporaryDirectory
            .appending(path: "ArchiverTest-\(UUID().uuidString)")
            .appending(path: "contenido", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        try Data("hola".utf8).write(to: dir.appending(path: "archivo.txt"))

        let zip = try ExportArchiver.zip(directory: dir)

        #expect(zip.lastPathComponent == "contenido.zip")
        let datos = try Data(contentsOf: zip)
        #expect(datos.count > 0)
        // Firma PK de un zip.
        #expect(datos.prefix(2) == Data([0x50, 0x4B]))
    }
}
