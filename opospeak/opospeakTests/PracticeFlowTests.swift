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

// MARK: - SessionPolicy

struct SessionPolicyTests {

    private let now = Date(timeIntervalSince1970: 1_750_000_000)

    @Test func withinWindowIsReusable() {
        let tenMinutesAgo = now.addingTimeInterval(-10 * 60)
        #expect(SessionPolicy.isReusable(lastActivity: tenMinutesAgo, now: now))
    }

    @Test func outsideWindowIsNotReusable() {
        let fortyFiveMinutesAgo = now.addingTimeInterval(-45 * 60)
        #expect(!SessionPolicy.isReusable(lastActivity: fortyFiveMinutesAgo, now: now))
    }

    @Test func exactlyAtBoundaryIsReusable() {
        let thirtyMinutesAgo = now.addingTimeInterval(-30 * 60)
        #expect(SessionPolicy.isReusable(lastActivity: thirtyMinutesAgo, now: now))
    }

    @Test func futureActivityIsNotReusable() {
        let inFiveMinutes = now.addingTimeInterval(5 * 60)
        #expect(!SessionPolicy.isReusable(lastActivity: inFiveMinutes, now: now))
    }
}

// MARK: - PracticeService

@MainActor
struct PracticeServiceTests {

    // Mismo patrón que DomainModelTests: esquema compartido y contenedores
    // retenidos — el deinit de un contenedor en uso crashea SwiftData.
    private static let sharedSchema = Schema([
        Opposition.self, Syllabus.self, Topic.self, PracticeSession.self,
        Attempt.self, Recording.self, Metric.self, Note.self,
    ])
    private static var retainedContainers: [ModelContainer] = []

    private struct TestEnvironment {
        let context: ModelContext
        let store: RecordingStore
        let service: PracticeService
        let topic: Topic
    }

    private func makeEnvironment() throws -> TestEnvironment {
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

        let opposition = Opposition(name: "Judicatura")
        context.insert(opposition)
        let syllabus = Syllabus(name: "Civil", opposition: opposition)
        context.insert(syllabus)
        let topic = Topic(number: 42, syllabus: syllabus)
        context.insert(topic)
        try context.save()

        return TestEnvironment(
            context: context,
            store: store,
            service: PracticeService(modelContext: context, recordingStore: store),
            topic: topic
        )
    }

    private func createFakeAudio(in store: RecordingStore, id: UUID) throws {
        let url = store.url(forRecordingID: id)
        try Data(repeating: 0xAB, count: 2048).write(to: url)
    }

    @Test func finishPersistsAttemptRecordingAndMetric() throws {
        let env = try makeEnvironment()
        let recordingID = UUID()
        try createFakeAudio(in: env.store, id: recordingID)

        let startedAt = Date(timeIntervalSince1970: 1_750_000_000)
        let endedAt = startedAt.addingTimeInterval(708)
        let attempt = try env.service.finish(
            topic: env.topic, recordingID: recordingID, startedAt: startedAt, endedAt: endedAt
        )

        #expect(attempt.duration == 708)
        #expect(attempt.isCompleted)
        #expect(attempt.topic?.id == env.topic.id)
        #expect(attempt.session != nil)
        #expect(attempt.session?.endedAt == endedAt)

        let recordings = try env.context.fetch(FetchDescriptor<Recording>())
        #expect(recordings.count == 1)
        #expect(recordings[0].id == recordingID)
        #expect(recordings[0].fileSize == 2048)
        #expect(recordings[0].duration == 708)

        let metrics = try env.context.fetch(FetchDescriptor<Metric>())
        #expect(metrics.count == 1)
        #expect(metrics[0].kind == .totalDuration)
        #expect(metrics[0].value == 708)
    }

    @Test func closePracticesShareSession() throws {
        let env = try makeEnvironment()
        let base = Date(timeIntervalSince1970: 1_750_000_000)

        let id1 = UUID()
        try createFakeAudio(in: env.store, id: id1)
        try env.service.finish(
            topic: env.topic, recordingID: id1,
            startedAt: base, endedAt: base.addingTimeInterval(600)
        )

        // Segunda práctica 10 minutos después de terminar la primera.
        let secondStart = base.addingTimeInterval(600 + 10 * 60)
        let id2 = UUID()
        try createFakeAudio(in: env.store, id: id2)
        try env.service.finish(
            topic: env.topic, recordingID: id2,
            startedAt: secondStart, endedAt: secondStart.addingTimeInterval(600)
        )

        let sessions = try env.context.fetch(FetchDescriptor<PracticeSession>())
        #expect(sessions.count == 1)
        #expect(sessions[0].attempts?.count == 2)
    }

    @Test func longBreakCreatesNewSession() throws {
        let env = try makeEnvironment()
        let base = Date(timeIntervalSince1970: 1_750_000_000)

        let id1 = UUID()
        try createFakeAudio(in: env.store, id: id1)
        try env.service.finish(
            topic: env.topic, recordingID: id1,
            startedAt: base, endedAt: base.addingTimeInterval(600)
        )

        // Segunda práctica 45 minutos después de terminar la primera.
        let secondStart = base.addingTimeInterval(600 + 45 * 60)
        let id2 = UUID()
        try createFakeAudio(in: env.store, id: id2)
        try env.service.finish(
            topic: env.topic, recordingID: id2,
            startedAt: secondStart, endedAt: secondStart.addingTimeInterval(600)
        )

        let sessions = try env.context.fetch(FetchDescriptor<PracticeSession>())
        #expect(sessions.count == 2)
    }

    @Test func discardDeletesFileAndPersistsNothing() throws {
        let env = try makeEnvironment()
        let recordingID = UUID()
        try createFakeAudio(in: env.store, id: recordingID)
        #expect(env.store.existingURL(forRecordingID: recordingID) != nil)

        env.service.discard(recordingID: recordingID)

        #expect(env.store.existingURL(forRecordingID: recordingID) == nil)
        #expect(try env.context.fetch(FetchDescriptor<Attempt>()).isEmpty)
        #expect(try env.context.fetch(FetchDescriptor<Recording>()).isEmpty)
        #expect(try env.context.fetch(FetchDescriptor<PracticeSession>()).isEmpty)
    }
}
