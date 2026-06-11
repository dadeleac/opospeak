//
//  OppositionDomainTests.swift
//  opospeakTests
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import Testing
import SwiftData
@testable import opospeak

@MainActor
struct OppositionDomainTests {

    private static let sharedSchema = Schema([
        Opposition.self, Syllabus.self, Topic.self, PracticeSession.self,
        Attempt.self, Recording.self, Metric.self, Note.self,
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

    @Test func realWorldHierarchy() throws {
        let context = try makeContext()

        let judicatura = Opposition(name: "Judicatura")
        context.insert(judicatura)
        for name in ["Civil", "Penal", "Procesal"] {
            context.insert(Syllabus(name: name, opposition: judicatura))
        }
        try context.save()

        #expect(judicatura.syllabi?.count == 3)
        let syllabi = try context.fetch(FetchDescriptor<Syllabus>())
        for syllabus in syllabi {
            #expect(syllabus.opposition?.id == judicatura.id)
        }
    }

    @Test func domainSupportsMultipleOppositions() throws {
        let context = try makeContext()

        let judicatura = Opposition(name: "Judicatura")
        context.insert(judicatura)
        context.insert(Syllabus(name: "Civil", opposition: judicatura))

        let hacienda = Opposition(name: "Inspección de Hacienda")
        context.insert(hacienda)
        context.insert(Syllabus(name: "Bloque I Derecho", opposition: hacienda))
        context.insert(Syllabus(name: "Bloque II Técnico", opposition: hacienda))
        try context.save()

        #expect(try context.fetch(FetchDescriptor<Opposition>()).count == 2)
        #expect(judicatura.syllabi?.count == 1)
        #expect(hacienda.syllabi?.count == 2)
    }

    @Test func deletingOppositionCascades() throws {
        let context = try makeContext()

        let opposition = Opposition(name: "Judicatura")
        context.insert(opposition)
        let syllabus = Syllabus(name: "Civil", opposition: opposition)
        context.insert(syllabus)
        let topic = Topic(number: 1, syllabus: syllabus)
        context.insert(topic)
        let session = PracticeSession()
        context.insert(session)
        context.insert(Attempt(topic: topic, session: session))
        try context.save()

        context.delete(opposition)
        try context.save()

        #expect(try context.fetch(FetchDescriptor<Syllabus>()).isEmpty)
        #expect(try context.fetch(FetchDescriptor<Topic>()).isEmpty)
        #expect(try context.fetch(FetchDescriptor<Attempt>()).isEmpty)
        // La sesión no pertenece a la oposición: sobrevive.
        #expect(try context.fetch(FetchDescriptor<PracticeSession>()).count == 1)
    }
}

// MARK: - Backfill

@MainActor
struct OppositionBackfillTests {

    private static let sharedSchema = Schema([
        Opposition.self, Syllabus.self, Topic.self, PracticeSession.self,
        Attempt.self, Recording.self, Metric.self, Note.self,
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
    private func createOrphan(name: String, in context: ModelContext) throws -> Syllabus {
        let temporary = Opposition(name: "tmp")
        context.insert(temporary)
        let syllabus = Syllabus(name: name, opposition: temporary)
        context.insert(syllabus)
        syllabus.opposition = nil
        context.delete(temporary)
        try context.save()
        return syllabus
    }

    @Test func adoptsOrphansUnderDefaultOpposition() throws {
        let context = try makeContext()
        let orphan1 = try createOrphan(name: "Civil", in: context)
        let orphan2 = try createOrphan(name: "Penal", in: context)

        let adopted = OppositionBackfill.run(context: context)

        #expect(adopted == 2)
        let oppositions = try context.fetch(FetchDescriptor<Opposition>())
        #expect(oppositions.count == 1)
        #expect(oppositions[0].name == OppositionBackfill.defaultName)
        #expect(orphan1.opposition?.id == oppositions[0].id)
        #expect(orphan2.opposition?.id == oppositions[0].id)
    }

    @Test func isIdempotent() throws {
        let context = try makeContext()
        _ = try createOrphan(name: "Civil", in: context)

        #expect(OppositionBackfill.run(context: context) == 1)
        #expect(OppositionBackfill.run(context: context) == 0)
        #expect(try context.fetch(FetchDescriptor<Opposition>()).count == 1)
    }

    @Test func reusesExistingOpposition() throws {
        let context = try makeContext()
        let existing = Opposition(name: "Judicatura")
        context.insert(existing)
        try context.save()
        let orphan = try createOrphan(name: "Civil", in: context)

        OppositionBackfill.run(context: context)

        // No crea la oposición por defecto si ya hay una: adopta bajo la existente.
        #expect(try context.fetch(FetchDescriptor<Opposition>()).count == 1)
        #expect(orphan.opposition?.id == existing.id)
    }

    @Test func withoutOrphansDoesNothing() throws {
        let context = try makeContext()
        #expect(OppositionBackfill.run(context: context) == 0)
        #expect(try context.fetch(FetchDescriptor<Opposition>()).isEmpty)
    }
}
