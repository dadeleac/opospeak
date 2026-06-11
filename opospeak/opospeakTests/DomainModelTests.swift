//
//  DomainModelTests.swift
//  opospeakTests
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import Testing
import SwiftData
@testable import opospeak

@MainActor
struct DomainModelTests {

    // Esquema único y contenedores retenidos durante todo el proceso:
    // el deinit de un ModelContainer mientras otro está en uso crashea
    // SwiftData (EXC_BREAKPOINT en estado global compartido).
    private static let sharedSchema = Schema([
        Temario.self, Tema.self, Sesion.self, Intento.self,
        Grabacion.self, Metrica.self, Nota.self,
    ])
    private static var retainedContainers: [ModelContainer] = []

    private func makeContainer() throws -> ModelContainer {
        let config = ModelConfiguration(
            "test-\(UUID().uuidString)",
            schema: Self.sharedSchema,
            isStoredInMemoryOnly: true
        )
        let container = try ModelContainer(for: Self.sharedSchema, configurations: [config])
        Self.retainedContainers.append(container)
        return container
    }

    @Test func crearTemarioConInformacionMinima() throws {
        let context = try makeContainer().mainContext

        let temario = Temario(nombre: "Judicatura")
        context.insert(temario)
        try context.save()

        let temarios = try context.fetch(FetchDescriptor<Temario>())
        #expect(temarios.count == 1)
        #expect(temarios[0].nombre == "Judicatura")
        #expect(temarios[0].descripcion == nil)
        #expect(temarios[0].temas?.isEmpty == true)
    }

    @Test func temaSinTituloPerteneceASuTemario() throws {
        let context = try makeContainer().mainContext

        let temario = Temario(nombre: "Judicatura")
        context.insert(temario)
        let tema = Tema(numero: 42, temario: temario)
        context.insert(tema)
        try context.save()

        #expect(tema.titulo == nil)
        #expect(tema.temario?.id == temario.id)
        #expect(temario.temas?.first?.id == tema.id)
    }

    @Test func intentoCompletoVinculaTemaYSesion() throws {
        let context = try makeContainer().mainContext

        let temario = Temario(nombre: "Judicatura")
        context.insert(temario)
        let tema = Tema(numero: 42, titulo: "Responsabilidad patrimonial", temario: temario)
        context.insert(tema)
        let sesion = Sesion()
        context.insert(sesion)

        let intento = Intento(tema: tema, sesion: sesion)
        context.insert(intento)
        intento.duracionReal = 708
        intento.fechaFin = intento.fechaInicio.addingTimeInterval(708)
        intento.completado = true
        try context.save()

        #expect(intento.tema?.numero == 42)
        #expect(intento.sesion?.id == sesion.id)
        #expect(intento.duracionReal == 708)
        #expect(intento.completado)
        #expect(tema.intentos?.count == 1)
        #expect(sesion.intentos?.count == 1)
    }

    @Test func intentoSinGrabacionEsValido() throws {
        let context = try makeContainer().mainContext

        let temario = Temario(nombre: "Judicatura")
        context.insert(temario)
        let tema = Tema(numero: 1, temario: temario)
        context.insert(tema)
        let sesion = Sesion()
        context.insert(sesion)
        let intento = Intento(tema: tema, sesion: sesion)
        context.insert(intento)
        try context.save()

        #expect(intento.grabacion == nil)
        let intentos = try context.fetch(FetchDescriptor<Intento>())
        #expect(intentos.count == 1)
    }

    @Test func borrarIntentoEliminaSatelitesYArchivo() throws {
        let context = try makeContainer().mainContext
        let store = RecordingStore(
            directoryURL: FileManager.default.temporaryDirectory
                .appending(path: "RecordingStoreTests-\(UUID().uuidString)")
        )
        try store.ensureDirectoryExists()

        let temario = Temario(nombre: "Judicatura")
        context.insert(temario)
        let tema = Tema(numero: 7, temario: temario)
        context.insert(tema)
        let sesion = Sesion()
        context.insert(sesion)
        let intento = Intento(tema: tema, sesion: sesion)
        context.insert(intento)
        let grabacion = Grabacion(intento: intento, duracion: 600, tamano: 1024)
        context.insert(grabacion)
        context.insert(Metrica(intento: intento, tipo: .duracionTotal, valor: 600))
        context.insert(Metrica(intento: intento, tipo: .diferenciaObjetivo, valor: -30))
        context.insert(Nota(intento: intento, contenido: "Demasiado rápido al inicio"))
        try context.save()

        let audioURL = store.url(forGrabacionId: grabacion.id, formato: grabacion.formato)
        try Data("audio".utf8).write(to: audioURL)
        #expect(FileManager.default.fileExists(atPath: audioURL.path()))

        let repository = PracticeRepository(modelContext: context, recordingStore: store)
        try repository.delete(intento: intento)

        #expect(try context.fetch(FetchDescriptor<Intento>()).isEmpty)
        #expect(try context.fetch(FetchDescriptor<Grabacion>()).isEmpty)
        #expect(try context.fetch(FetchDescriptor<Metrica>()).isEmpty)
        #expect(try context.fetch(FetchDescriptor<Nota>()).isEmpty)
        #expect(!FileManager.default.fileExists(atPath: audioURL.path()))
        // El tema sobrevive: el borrado de un intento nunca toca el tema.
        #expect(try context.fetch(FetchDescriptor<Tema>()).count == 1)
    }

    @Test func borrarSesionConservaIntentos() throws {
        let context = try makeContainer().mainContext

        let temario = Temario(nombre: "Judicatura")
        context.insert(temario)
        let tema = Tema(numero: 3, temario: temario)
        context.insert(tema)
        let sesion = Sesion()
        context.insert(sesion)
        let intento = Intento(tema: tema, sesion: sesion)
        context.insert(intento)
        try context.save()

        context.delete(sesion)
        try context.save()

        let intentos = try context.fetch(FetchDescriptor<Intento>())
        #expect(intentos.count == 1)
        #expect(intentos[0].sesion == nil)
        #expect(intentos[0].tema?.id == tema.id)
    }

    @Test func archivarTemaConservaHistorial() throws {
        let context = try makeContainer().mainContext

        let temario = Temario(nombre: "Judicatura")
        context.insert(temario)
        let tema = Tema(numero: 5, temario: temario)
        context.insert(tema)
        let sesion = Sesion()
        context.insert(sesion)
        let intento = Intento(tema: tema, sesion: sesion)
        context.insert(intento)
        context.insert(Nota(intento: intento, contenido: "Bien"))
        try context.save()

        tema.activo = false
        try context.save()

        #expect(tema.activo == false)
        #expect(try context.fetch(FetchDescriptor<Intento>()).count == 1)
        #expect(try context.fetch(FetchDescriptor<Nota>()).count == 1)
    }

    @Test func borrarTemarioCascadaCompleta() throws {
        let context = try makeContainer().mainContext

        let temario = Temario(nombre: "Judicatura")
        context.insert(temario)
        let tema = Tema(numero: 1, temario: temario)
        context.insert(tema)
        let sesion = Sesion()
        context.insert(sesion)
        let intento = Intento(tema: tema, sesion: sesion)
        context.insert(intento)
        context.insert(Nota(intento: intento, contenido: "x"))
        try context.save()

        context.delete(temario)
        try context.save()

        #expect(try context.fetch(FetchDescriptor<Tema>()).isEmpty)
        #expect(try context.fetch(FetchDescriptor<Intento>()).isEmpty)
        #expect(try context.fetch(FetchDescriptor<Nota>()).isEmpty)
        // La sesión no pertenece al temario: sobrevive.
        #expect(try context.fetch(FetchDescriptor<Sesion>()).count == 1)
    }

    @Test func recordingStoreResuelveURLsPorIdentidad() throws {
        let dir = FileManager.default.temporaryDirectory
            .appending(path: "RecordingStoreTests-\(UUID().uuidString)")
        let store = RecordingStore(directoryURL: dir)
        try store.ensureDirectoryExists()

        let id = UUID()
        let url = store.url(forGrabacionId: id)
        #expect(url.lastPathComponent == "\(id.uuidString).m4a")
        // Comparar URLs estandarizadas: /tmp es symlink de /private/tmp y
        // deletingLastPathComponent deja barra final.
        #expect(
            url.deletingLastPathComponent().standardizedFileURL.resolvingSymlinksInPath().path()
                .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                == dir.standardizedFileURL.resolvingSymlinksInPath().path()
                .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        )

        try Data("audio".utf8).write(to: url)
        try store.deleteRecording(id: id)
        #expect(!FileManager.default.fileExists(atPath: url.path()))

        // Borrar una grabación inexistente no lanza error.
        try store.deleteRecording(id: UUID())
    }
}
