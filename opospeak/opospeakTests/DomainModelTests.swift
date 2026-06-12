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
        Opposition.self, Syllabus.self, Topic.self, PracticeSession.self,
        Attempt.self, Recording.self, Metric.self, Note.self,
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

    @Test func createSyllabusWithMinimumInformation() throws {
        let context = try makeContainer().mainContext

        let opposition = Opposition(name: "Judicatura")
        context.insert(opposition)
        let syllabus = Syllabus(name: "Civil", opposition: opposition)
        context.insert(syllabus)
        try context.save()

        let syllabi = try context.fetch(FetchDescriptor<Syllabus>())
        #expect(syllabi.count == 1)
        #expect(syllabi[0].name == "Civil")
        #expect(syllabi[0].summary == nil)
        #expect(syllabi[0].topics?.isEmpty == true)
        #expect(syllabi[0].opposition?.name == "Judicatura")
        #expect(opposition.syllabi?.count == 1)
    }

    @Test func untitledTopicBelongsToItsSyllabus() throws {
        let context = try makeContainer().mainContext

        let opposition = Opposition(name: "Judicatura")
        context.insert(opposition)
        let syllabus = Syllabus(name: "Civil", opposition: opposition)
        context.insert(syllabus)
        let topic = Topic(number: 42, syllabus: syllabus)
        context.insert(topic)
        try context.save()

        #expect(topic.title == nil)
        #expect(topic.syllabus?.id == syllabus.id)
        #expect(syllabus.topics?.first?.id == topic.id)
    }

    @Test func completedAttemptLinksTopicAndSession() throws {
        let context = try makeContainer().mainContext

        let opposition = Opposition(name: "Judicatura")
        context.insert(opposition)
        let syllabus = Syllabus(name: "Civil", opposition: opposition)
        context.insert(syllabus)
        let topic = Topic(number: 42, title: "Responsabilidad patrimonial", syllabus: syllabus)
        context.insert(topic)
        let session = PracticeSession()
        context.insert(session)

        let attempt = Attempt(topic: topic, session: session)
        context.insert(attempt)
        attempt.duration = 708
        attempt.endedAt = attempt.startedAt.addingTimeInterval(708)
        attempt.isCompleted = true
        try context.save()

        #expect(attempt.topic?.number == 42)
        #expect(attempt.session?.id == session.id)
        #expect(attempt.duration == 708)
        #expect(attempt.isCompleted)
        #expect(topic.attempts?.count == 1)
        #expect(session.attempts?.count == 1)
    }

    @Test func attemptHighlightIsUserCurationAndPersists() throws {
        let context = try makeContainer().mainContext

        let opposition = Opposition(name: "Judicatura")
        context.insert(opposition)
        let syllabus = Syllabus(name: "Civil", opposition: opposition)
        context.insert(syllabus)
        let topic = Topic(number: 1, syllabus: syllabus)
        context.insert(topic)
        let session = PracticeSession()
        context.insert(session)
        let attempt = Attempt(topic: topic, session: session)
        context.insert(attempt)
        try context.save()

        // Por defecto, nada está destacado: el destacado lo pone el usuario.
        #expect(attempt.isHighlighted == false)

        attempt.isHighlighted = true
        try context.save()
        #expect(attempt.isHighlighted)

        // Reversible sin rastro.
        attempt.isHighlighted = false
        try context.save()
        #expect(attempt.isHighlighted == false)
    }

    @Test func editingNotePreservesCreationDate() throws {
        let context = try makeContainer().mainContext

        let opposition = Opposition(name: "Judicatura")
        context.insert(opposition)
        let syllabus = Syllabus(name: "Civil", opposition: opposition)
        context.insert(syllabus)
        let topic = Topic(number: 1, syllabus: syllabus)
        context.insert(topic)
        let session = PracticeSession()
        context.insert(session)
        let attempt = Attempt(topic: topic, session: session)
        context.insert(attempt)
        let note = Note(attempt: attempt, content: "Demasiado rapido al inicio")
        context.insert(note)
        try context.save()

        let originalDate = note.createdAt

        // Editar corrige la errata; la fecha registra la observación.
        note.content = "Demasiado rápido al inicio"
        try context.save()
        #expect(note.content == "Demasiado rápido al inicio")
        #expect(note.createdAt == originalDate)

        // Borrar elimina la nota y el intento queda intacto.
        context.delete(note)
        try context.save()
        #expect(attempt.notes?.isEmpty == true)
    }

    @Test func attemptWithoutRecordingIsValid() throws {
        let context = try makeContainer().mainContext

        let opposition = Opposition(name: "Judicatura")
        context.insert(opposition)
        let syllabus = Syllabus(name: "Civil", opposition: opposition)
        context.insert(syllabus)
        let topic = Topic(number: 1, syllabus: syllabus)
        context.insert(topic)
        let session = PracticeSession()
        context.insert(session)
        let attempt = Attempt(topic: topic, session: session)
        context.insert(attempt)
        try context.save()

        #expect(attempt.recording == nil)
        let attempts = try context.fetch(FetchDescriptor<Attempt>())
        #expect(attempts.count == 1)
    }

    @Test func deletingAttemptRemovesSatellitesAndFile() throws {
        let context = try makeContainer().mainContext
        let store = RecordingStore(
            directoryURL: FileManager.default.temporaryDirectory
                .appending(path: "RecordingStoreTests-\(UUID().uuidString)")
        )
        try store.ensureDirectoryExists()

        let opposition = Opposition(name: "Judicatura")
        context.insert(opposition)
        let syllabus = Syllabus(name: "Civil", opposition: opposition)
        context.insert(syllabus)
        let topic = Topic(number: 7, syllabus: syllabus)
        context.insert(topic)
        let session = PracticeSession()
        context.insert(session)
        let attempt = Attempt(topic: topic, session: session)
        context.insert(attempt)
        let recording = Recording(attempt: attempt, duration: 600, fileSize: 1024)
        context.insert(recording)
        context.insert(Metric(attempt: attempt, kind: .totalDuration, value: 600))
        context.insert(Metric(attempt: attempt, kind: .targetDelta, value: -30))
        context.insert(Note(attempt: attempt, content: "Demasiado rápido al inicio"))
        try context.save()

        let audioURL = store.url(forRecordingID: recording.id, format: recording.format)
        try Data("audio".utf8).write(to: audioURL)
        #expect(FileManager.default.fileExists(atPath: audioURL.path()))

        let repository = PracticeRepository(modelContext: context, recordingStore: store)
        try repository.delete(attempt: attempt)

        #expect(try context.fetch(FetchDescriptor<Attempt>()).isEmpty)
        #expect(try context.fetch(FetchDescriptor<Recording>()).isEmpty)
        #expect(try context.fetch(FetchDescriptor<Metric>()).isEmpty)
        #expect(try context.fetch(FetchDescriptor<Note>()).isEmpty)
        #expect(!FileManager.default.fileExists(atPath: audioURL.path()))
        // El tema sobrevive: el borrado de un intento nunca toca el tema.
        #expect(try context.fetch(FetchDescriptor<Topic>()).count == 1)
    }

    @Test func deletingTopicRemovesAudioFilesUnderneath() throws {
        let context = try makeContainer().mainContext
        let store = RecordingStore(
            directoryURL: FileManager.default.temporaryDirectory
                .appending(path: "RecordingStoreTests-\(UUID().uuidString)")
        )
        try store.ensureDirectoryExists()

        let opposition = Opposition(name: "Judicatura")
        context.insert(opposition)
        let syllabus = Syllabus(name: "Civil", opposition: opposition)
        context.insert(syllabus)
        let topic = Topic(number: 7, syllabus: syllabus)
        context.insert(topic)
        let session = PracticeSession()
        context.insert(session)

        var audioURLs: [URL] = []
        for _ in 0..<2 {
            let attempt = Attempt(topic: topic, session: session)
            context.insert(attempt)
            let recording = Recording(attempt: attempt, duration: 600, fileSize: 1024)
            context.insert(recording)
            let url = store.url(forRecordingID: recording.id, format: recording.format)
            try Data("audio".utf8).write(to: url)
            audioURLs.append(url)
        }
        try context.save()

        let repository = PracticeRepository(modelContext: context, recordingStore: store)
        try repository.delete(topic: topic)

        #expect(try context.fetch(FetchDescriptor<Topic>()).isEmpty)
        #expect(try context.fetch(FetchDescriptor<Attempt>()).isEmpty)
        #expect(try context.fetch(FetchDescriptor<Recording>()).isEmpty)
        for url in audioURLs {
            #expect(!FileManager.default.fileExists(atPath: url.path()))
        }
        // El temario sobrevive: borrar un tema nunca toca el temario.
        #expect(try context.fetch(FetchDescriptor<Syllabus>()).count == 1)
    }

    @Test func deletingSyllabusRemovesAudioFilesUnderneath() throws {
        let context = try makeContainer().mainContext
        let store = RecordingStore(
            directoryURL: FileManager.default.temporaryDirectory
                .appending(path: "RecordingStoreTests-\(UUID().uuidString)")
        )
        try store.ensureDirectoryExists()

        let opposition = Opposition(name: "Judicatura")
        context.insert(opposition)
        let syllabus = Syllabus(name: "Civil", opposition: opposition)
        context.insert(syllabus)
        let session = PracticeSession()
        context.insert(session)

        var audioURLs: [URL] = []
        for number in 1...2 {
            let topic = Topic(number: number, syllabus: syllabus)
            context.insert(topic)
            let attempt = Attempt(topic: topic, session: session)
            context.insert(attempt)
            let recording = Recording(attempt: attempt, duration: 600, fileSize: 1024)
            context.insert(recording)
            let url = store.url(forRecordingID: recording.id, format: recording.format)
            try Data("audio".utf8).write(to: url)
            audioURLs.append(url)
        }
        try context.save()

        let repository = PracticeRepository(modelContext: context, recordingStore: store)
        try repository.delete(syllabus: syllabus)

        #expect(try context.fetch(FetchDescriptor<Syllabus>()).isEmpty)
        #expect(try context.fetch(FetchDescriptor<Topic>()).isEmpty)
        #expect(try context.fetch(FetchDescriptor<Attempt>()).isEmpty)
        for url in audioURLs {
            #expect(!FileManager.default.fileExists(atPath: url.path()))
        }
        // La oposición sobrevive: borrar un temario nunca toca la oposición.
        #expect(try context.fetch(FetchDescriptor<Opposition>()).count == 1)
    }

    @Test func deletingSessionPreservesAttempts() throws {
        let context = try makeContainer().mainContext

        let opposition = Opposition(name: "Judicatura")
        context.insert(opposition)
        let syllabus = Syllabus(name: "Civil", opposition: opposition)
        context.insert(syllabus)
        let topic = Topic(number: 3, syllabus: syllabus)
        context.insert(topic)
        let session = PracticeSession()
        context.insert(session)
        let attempt = Attempt(topic: topic, session: session)
        context.insert(attempt)
        try context.save()

        context.delete(session)
        try context.save()

        let attempts = try context.fetch(FetchDescriptor<Attempt>())
        #expect(attempts.count == 1)
        #expect(attempts[0].session == nil)
        #expect(attempts[0].topic?.id == topic.id)
    }

    @Test func archivingTopicPreservesHistory() throws {
        let context = try makeContainer().mainContext

        let opposition = Opposition(name: "Judicatura")
        context.insert(opposition)
        let syllabus = Syllabus(name: "Civil", opposition: opposition)
        context.insert(syllabus)
        let topic = Topic(number: 5, syllabus: syllabus)
        context.insert(topic)
        let session = PracticeSession()
        context.insert(session)
        let attempt = Attempt(topic: topic, session: session)
        context.insert(attempt)
        context.insert(Note(attempt: attempt, content: "Bien"))
        try context.save()

        topic.isActive = false
        try context.save()

        #expect(topic.isActive == false)
        #expect(try context.fetch(FetchDescriptor<Attempt>()).count == 1)
        #expect(try context.fetch(FetchDescriptor<Note>()).count == 1)
    }

    @Test func deletingSyllabusCascades() throws {
        let context = try makeContainer().mainContext

        let opposition = Opposition(name: "Judicatura")
        context.insert(opposition)
        let syllabus = Syllabus(name: "Civil", opposition: opposition)
        context.insert(syllabus)
        let topic = Topic(number: 1, syllabus: syllabus)
        context.insert(topic)
        let session = PracticeSession()
        context.insert(session)
        let attempt = Attempt(topic: topic, session: session)
        context.insert(attempt)
        context.insert(Note(attempt: attempt, content: "x"))
        try context.save()

        context.delete(syllabus)
        try context.save()

        #expect(try context.fetch(FetchDescriptor<Topic>()).isEmpty)
        #expect(try context.fetch(FetchDescriptor<Attempt>()).isEmpty)
        #expect(try context.fetch(FetchDescriptor<Note>()).isEmpty)
        // La sesión no pertenece al temario: sobrevive.
        #expect(try context.fetch(FetchDescriptor<PracticeSession>()).count == 1)
    }

    @Test func recordingStoreResolvesURLsByIdentity() throws {
        let dir = FileManager.default.temporaryDirectory
            .appending(path: "RecordingStoreTests-\(UUID().uuidString)")
        let store = RecordingStore(directoryURL: dir)
        try store.ensureDirectoryExists()

        let id = UUID()
        let url = store.url(forRecordingID: id)
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
