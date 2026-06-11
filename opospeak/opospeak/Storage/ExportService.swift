//
//  ExportService.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import SwiftData

/// Ensambla los paquetes de exportación en disco (define-export-format).
/// La exportación incluye TODO: temarios y temas archivados, todos los
/// intentos, métricas y notas, y cada grabación presente en disco.
struct ExportService {
    let modelContext: ModelContext
    let recordingStore: RecordingStore
    let appVersion: String

    init(modelContext: ModelContext, recordingStore: RecordingStore, appVersion: String? = nil) {
        self.modelContext = modelContext
        self.recordingStore = recordingStore
        self.appVersion = appVersion
            ?? Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            ?? "1.0"
    }

    /// Construye `opospeak-export/` en un directorio temporal único y
    /// devuelve su URL. El llamante decide comprimir y compartir.
    func buildFullPackage() throws -> URL {
        let raiz = FileManager.default.temporaryDirectory
            .appending(path: "export-\(UUID().uuidString)")
        let paquete = raiz.appending(path: "opospeak-export", directoryHint: .isDirectory)
        let dataDir = paquete.appending(path: "data", directoryHint: .isDirectory)
        let recordingsDir = paquete.appending(path: "recordings", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: dataDir, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: recordingsDir, withIntermediateDirectories: true)

        let oposiciones = try modelContext.fetch(FetchDescriptor<Oposicion>())
        let temarios = try modelContext.fetch(FetchDescriptor<Temario>())
        let temas = try modelContext.fetch(FetchDescriptor<Tema>())
        let sesiones = try modelContext.fetch(FetchDescriptor<Sesion>())
        let intentos = try modelContext.fetch(
            FetchDescriptor<Intento>(sortBy: [SortDescriptor(\.fechaInicio)])
        )
        let metricas = try modelContext.fetch(FetchDescriptor<Metrica>())
        let notas = try modelContext.fetch(FetchDescriptor<Nota>())

        let encoder = ExportSchema.encoder
        func escribir<T: Encodable>(_ valor: T, en archivo: String) throws {
            try encoder.encode(valor).write(to: dataDir.appending(path: archivo))
        }

        try escribir(oposiciones.map(OposicionExport.init), en: "oposiciones.json")
        try escribir(temarios.map(TemarioExport.init), en: "temarios.json")
        try escribir(temas.map(TemaExport.init), en: "temas.json")
        try escribir(sesiones.map(SesionExport.init), en: "sesiones.json")
        try escribir(intentos.map(IntentoExport.init), en: "intentos.json")
        try escribir(metricas.map(MetricaExport.init), en: "metricas.json")
        try escribir(notas.map(NotaExport.init), en: "notas.json")

        try IntentosCSV.build(intentos: intentos)
            .write(to: dataDir.appending(path: "intentos.csv"), atomically: true, encoding: .utf8)

        // Copia byte a byte; los archivos ausentes no bloquean la exportación.
        var grabacionesCopiadas = 0
        for intento in intentos {
            guard let grabacion = intento.grabacion,
                  let origen = recordingStore.existingURL(
                      forGrabacionId: grabacion.id, formato: grabacion.formato
                  )
            else { continue }
            let destino = recordingsDir.appending(
                path: "\(grabacion.id.uuidString).\(grabacion.formato)"
            )
            try FileManager.default.copyItem(at: origen, to: destino)
            grabacionesCopiadas += 1
        }

        let manifest = ManifestExport(
            format: ExportSchema.formato,
            version: ExportSchema.version,
            exportedAt: .now,
            appVersion: appVersion,
            counts: .init(
                oposiciones: oposiciones.count,
                temarios: temarios.count,
                temas: temas.count,
                sesiones: sesiones.count,
                intentos: intentos.count,
                grabaciones: grabacionesCopiadas,
                notas: notas.count
            ),
            recordingFormat: "m4a"
        )
        try encoder.encode(manifest).write(to: paquete.appending(path: "manifest.json"))

        return paquete
    }

    /// Paquete reducido de un intento: intento.json (con contexto de tema
    /// y temario), notas.json y el audio si existe.
    func buildIntentoPackage(intento: Intento) throws -> URL {
        let raiz = FileManager.default.temporaryDirectory
            .appending(path: "export-\(UUID().uuidString)")
        let nombre = "intento-\(intento.id.uuidString)"
        let paquete = raiz.appending(path: nombre, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: paquete, withIntermediateDirectories: true)

        struct IntentoUnicoExport: Codable {
            let intento: IntentoExport
            let tema: TemaExport?
            let temario: TemarioExport?
            let oposicion: OposicionExport?
        }

        let encoder = ExportSchema.encoder
        let contenido = IntentoUnicoExport(
            intento: IntentoExport(intento),
            tema: intento.tema.map(TemaExport.init),
            temario: intento.tema?.temario.map(TemarioExport.init),
            oposicion: intento.tema?.temario?.oposicion.map(OposicionExport.init)
        )
        try encoder.encode(contenido).write(to: paquete.appending(path: "intento.json"))

        let notas = (intento.notas ?? []).sorted { $0.fechaCreacion < $1.fechaCreacion }
        try encoder.encode(notas.map(NotaExport.init))
            .write(to: paquete.appending(path: "notas.json"))

        if let grabacion = intento.grabacion,
           let origen = recordingStore.existingURL(
               forGrabacionId: grabacion.id, formato: grabacion.formato
           ) {
            let destino = paquete.appending(
                path: "\(grabacion.id.uuidString).\(grabacion.formato)"
            )
            try FileManager.default.copyItem(at: origen, to: destino)
        }

        return paquete
    }
}
