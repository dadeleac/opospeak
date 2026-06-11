//
//  OposicionDomainTests.swift
//  opospeakTests
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import Testing
import SwiftData
@testable import opospeak

@MainActor
struct OposicionDomainTests {

    private static let sharedSchema = Schema([
        Oposicion.self, Temario.self, Tema.self, Sesion.self, Intento.self,
        Grabacion.self, Metrica.self, Nota.self,
    ])
    private static var retainedContainers: [ModelContainer] = []

    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(
            "test-\(UUID().uuidString)",
            schema: Self.sharedSchema,
            isStoredInMemoryOnly: true
        )
        let container = try ModelContainer(for: Self.sharedSchema, configurations: [config])
        Self.retainedContainers.append(container)
        return container.mainContext
    }

    @Test func jerarquiaRealOposicionTemariosTemas() throws {
        let context = try makeContext()

        let judicatura = Oposicion(nombre: "Judicatura")
        context.insert(judicatura)
        for nombre in ["Civil", "Penal", "Procesal"] {
            context.insert(Temario(nombre: nombre, oposicion: judicatura))
        }
        try context.save()

        #expect(judicatura.temarios?.count == 3)
        let temarios = try context.fetch(FetchDescriptor<Temario>())
        for temario in temarios {
            #expect(temario.oposicion?.id == judicatura.id)
        }
    }

    @Test func dominioSoportaMultiplesOposiciones() throws {
        let context = try makeContext()

        let judicatura = Oposicion(nombre: "Judicatura")
        context.insert(judicatura)
        context.insert(Temario(nombre: "Civil", oposicion: judicatura))

        let hacienda = Oposicion(nombre: "Inspección de Hacienda")
        context.insert(hacienda)
        context.insert(Temario(nombre: "Bloque I Derecho", oposicion: hacienda))
        context.insert(Temario(nombre: "Bloque II Técnico", oposicion: hacienda))
        try context.save()

        #expect(try context.fetch(FetchDescriptor<Oposicion>()).count == 2)
        #expect(judicatura.temarios?.count == 1)
        #expect(hacienda.temarios?.count == 2)
    }

    @Test func borrarOposicionCascadaCompleta() throws {
        let context = try makeContext()

        let oposicion = Oposicion(nombre: "Judicatura")
        context.insert(oposicion)
        let temario = Temario(nombre: "Civil", oposicion: oposicion)
        context.insert(temario)
        let tema = Tema(numero: 1, temario: temario)
        context.insert(tema)
        let sesion = Sesion()
        context.insert(sesion)
        context.insert(Intento(tema: tema, sesion: sesion))
        try context.save()

        context.delete(oposicion)
        try context.save()

        #expect(try context.fetch(FetchDescriptor<Temario>()).isEmpty)
        #expect(try context.fetch(FetchDescriptor<Tema>()).isEmpty)
        #expect(try context.fetch(FetchDescriptor<Intento>()).isEmpty)
        // La sesión no pertenece a la oposición: sobrevive.
        #expect(try context.fetch(FetchDescriptor<Sesion>()).count == 1)
    }
}

// MARK: - Backfill

@MainActor
struct OposicionBackfillTests {

    private static let sharedSchema = Schema([
        Oposicion.self, Temario.self, Tema.self, Sesion.self, Intento.self,
        Grabacion.self, Metrica.self, Nota.self,
    ])
    private static var retainedContainers: [ModelContainer] = []

    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(
            "test-\(UUID().uuidString)",
            schema: Self.sharedSchema,
            isStoredInMemoryOnly: true
        )
        let container = try ModelContainer(for: Self.sharedSchema, configurations: [config])
        Self.retainedContainers.append(container)
        return container.mainContext
    }

    /// Simula un temario pre-refactor: creado y luego desvinculado.
    private func crearHuerfano(nombre: String, en context: ModelContext) throws -> Temario {
        let temporal = Oposicion(nombre: "tmp")
        context.insert(temporal)
        let temario = Temario(nombre: nombre, oposicion: temporal)
        context.insert(temario)
        temario.oposicion = nil
        context.delete(temporal)
        try context.save()
        return temario
    }

    @Test func adoptaHuerfanosBajoMiOposicion() throws {
        let context = try makeContext()
        let huerfano1 = try crearHuerfano(nombre: "Civil", en: context)
        let huerfano2 = try crearHuerfano(nombre: "Penal", en: context)

        let adoptados = OposicionBackfill.run(context: context)

        #expect(adoptados == 2)
        let oposiciones = try context.fetch(FetchDescriptor<Oposicion>())
        #expect(oposiciones.count == 1)
        #expect(oposiciones[0].nombre == OposicionBackfill.nombrePorDefecto)
        #expect(huerfano1.oposicion?.id == oposiciones[0].id)
        #expect(huerfano2.oposicion?.id == oposiciones[0].id)
    }

    @Test func esIdempotente() throws {
        let context = try makeContext()
        _ = try crearHuerfano(nombre: "Civil", en: context)

        #expect(OposicionBackfill.run(context: context) == 1)
        #expect(OposicionBackfill.run(context: context) == 0)
        #expect(try context.fetch(FetchDescriptor<Oposicion>()).count == 1)
    }

    @Test func reutilizaOposicionExistente() throws {
        let context = try makeContext()
        let existente = Oposicion(nombre: "Judicatura")
        context.insert(existente)
        try context.save()
        let huerfano = try crearHuerfano(nombre: "Civil", en: context)

        OposicionBackfill.run(context: context)

        // No crea "Mi oposición" si ya hay una: adopta bajo la existente.
        #expect(try context.fetch(FetchDescriptor<Oposicion>()).count == 1)
        #expect(huerfano.oposicion?.id == existente.id)
    }

    @Test func sinHuerfanosNoHaceNada() throws {
        let context = try makeContext()
        #expect(OposicionBackfill.run(context: context) == 0)
        #expect(try context.fetch(FetchDescriptor<Oposicion>()).isEmpty)
    }
}
