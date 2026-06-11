//
//  PracticeFlowTests.swift
//  opospeakTests
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import Testing
import SwiftData
@testable import opospeak

// MARK: - SesionPolicy

struct SesionPolicyTests {

    private let ahora = Date(timeIntervalSince1970: 1_750_000_000)

    @Test func dentroDeVentanaEsReutilizable() {
        let hace10min = ahora.addingTimeInterval(-10 * 60)
        #expect(SesionPolicy.esReutilizable(ultimaActividad: hace10min, ahora: ahora))
    }

    @Test func fueraDeVentanaNoEsReutilizable() {
        let hace45min = ahora.addingTimeInterval(-45 * 60)
        #expect(!SesionPolicy.esReutilizable(ultimaActividad: hace45min, ahora: ahora))
    }

    @Test func exactamenteEnElLimiteEsReutilizable() {
        let hace30min = ahora.addingTimeInterval(-30 * 60)
        #expect(SesionPolicy.esReutilizable(ultimaActividad: hace30min, ahora: ahora))
    }

    @Test func actividadFuturaNoEsReutilizable() {
        let dentroDe5min = ahora.addingTimeInterval(5 * 60)
        #expect(!SesionPolicy.esReutilizable(ultimaActividad: dentroDe5min, ahora: ahora))
    }
}

// MARK: - PracticeService

@MainActor
struct PracticeServiceTests {

    // Mismo patrón que DomainModelTests: esquema compartido y contenedores
    // retenidos — el deinit de un contenedor en uso crashea SwiftData.
    private static let sharedSchema = Schema([
        Oposicion.self, Temario.self, Tema.self, Sesion.self, Intento.self,
        Grabacion.self, Metrica.self, Nota.self,
    ])
    private static var retainedContainers: [ModelContainer] = []

    private struct Entorno {
        let context: ModelContext
        let store: RecordingStore
        let service: PracticeService
        let tema: Tema
    }

    private func makeEntorno() throws -> Entorno {
        let config = ModelConfiguration(
            "test-\(UUID().uuidString)",
            schema: Self.sharedSchema,
            isStoredInMemoryOnly: true
        )
        let container = try ModelContainer(for: Self.sharedSchema, configurations: [config])
        Self.retainedContainers.append(container)
        let context = container.mainContext

        let store = RecordingStore(
            directoryURL: FileManager.default.temporaryDirectory
                .appending(path: "PracticeServiceTests-\(UUID().uuidString)")
        )
        try store.ensureDirectoryExists()

        let oposicion = Oposicion(nombre: "Judicatura")
        context.insert(oposicion)
        let temario = Temario(nombre: "Civil", oposicion: oposicion)
        context.insert(temario)
        let tema = Tema(numero: 42, temario: temario)
        context.insert(tema)
        try context.save()

        return Entorno(
            context: context,
            store: store,
            service: PracticeService(modelContext: context, recordingStore: store),
            tema: tema
        )
    }

    private func crearArchivoFalso(en store: RecordingStore, id: UUID) throws {
        let url = store.url(forGrabacionId: id)
        try Data(repeating: 0xAB, count: 2048).write(to: url)
    }

    @Test func finishPersisteIntentoGrabacionYMetrica() throws {
        let entorno = try makeEntorno()
        let grabacionId = UUID()
        try crearArchivoFalso(en: entorno.store, id: grabacionId)

        let inicio = Date(timeIntervalSince1970: 1_750_000_000)
        let fin = inicio.addingTimeInterval(708)
        let intento = try entorno.service.finish(
            tema: entorno.tema, grabacionId: grabacionId, inicio: inicio, fin: fin
        )

        #expect(intento.duracionReal == 708)
        #expect(intento.completado)
        #expect(intento.tema?.id == entorno.tema.id)
        #expect(intento.sesion != nil)
        #expect(intento.sesion?.fechaFin == fin)

        let grabaciones = try entorno.context.fetch(FetchDescriptor<Grabacion>())
        #expect(grabaciones.count == 1)
        #expect(grabaciones[0].id == grabacionId)
        #expect(grabaciones[0].tamano == 2048)
        #expect(grabaciones[0].duracion == 708)

        let metricas = try entorno.context.fetch(FetchDescriptor<Metrica>())
        #expect(metricas.count == 1)
        #expect(metricas[0].tipo == .duracionTotal)
        #expect(metricas[0].valor == 708)
    }

    @Test func practicasCercanasCompartenSesion() throws {
        let entorno = try makeEntorno()
        let base = Date(timeIntervalSince1970: 1_750_000_000)

        let id1 = UUID()
        try crearArchivoFalso(en: entorno.store, id: id1)
        try entorno.service.finish(
            tema: entorno.tema, grabacionId: id1,
            inicio: base, fin: base.addingTimeInterval(600)
        )

        // Segunda práctica 10 minutos después de terminar la primera.
        let inicio2 = base.addingTimeInterval(600 + 10 * 60)
        let id2 = UUID()
        try crearArchivoFalso(en: entorno.store, id: id2)
        try entorno.service.finish(
            tema: entorno.tema, grabacionId: id2,
            inicio: inicio2, fin: inicio2.addingTimeInterval(600)
        )

        let sesiones = try entorno.context.fetch(FetchDescriptor<Sesion>())
        #expect(sesiones.count == 1)
        #expect(sesiones[0].intentos?.count == 2)
    }

    @Test func pausaLargaCreaSesionNueva() throws {
        let entorno = try makeEntorno()
        let base = Date(timeIntervalSince1970: 1_750_000_000)

        let id1 = UUID()
        try crearArchivoFalso(en: entorno.store, id: id1)
        try entorno.service.finish(
            tema: entorno.tema, grabacionId: id1,
            inicio: base, fin: base.addingTimeInterval(600)
        )

        // Segunda práctica 45 minutos después de terminar la primera.
        let inicio2 = base.addingTimeInterval(600 + 45 * 60)
        let id2 = UUID()
        try crearArchivoFalso(en: entorno.store, id: id2)
        try entorno.service.finish(
            tema: entorno.tema, grabacionId: id2,
            inicio: inicio2, fin: inicio2.addingTimeInterval(600)
        )

        let sesiones = try entorno.context.fetch(FetchDescriptor<Sesion>())
        #expect(sesiones.count == 2)
    }

    @Test func discardBorraArchivoYNoPersisteNada() throws {
        let entorno = try makeEntorno()
        let grabacionId = UUID()
        try crearArchivoFalso(en: entorno.store, id: grabacionId)
        #expect(entorno.store.existingURL(forGrabacionId: grabacionId) != nil)

        entorno.service.discard(grabacionId: grabacionId)

        #expect(entorno.store.existingURL(forGrabacionId: grabacionId) == nil)
        #expect(try entorno.context.fetch(FetchDescriptor<Intento>()).isEmpty)
        #expect(try entorno.context.fetch(FetchDescriptor<Grabacion>()).isEmpty)
        #expect(try entorno.context.fetch(FetchDescriptor<Sesion>()).isEmpty)
    }
}
