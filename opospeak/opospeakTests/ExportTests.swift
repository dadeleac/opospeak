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
        Opposition.self, Syllabus.self, Topic.self, PracticeSession.self,
        Attempt.self, Recording.self, Metric.self, Note.self,
    ])
    private static var retainedContainers: [ModelContainer] = []

    private struct TestEnvironment {
        let context: ModelContext
        let store: RecordingStore
        let service: ExportService
    }

    private func makeEnvironment() throws -> TestEnvironment {
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

        return TestEnvironment(
            context: container.mainContext,
            store: store,
            service: ExportService(
                modelContext: container.mainContext,
                recordingStore: store,
                appVersion: "1.0-test"
            )
        )
    }

    /// Oposición con coma (test de escapado CSV), 2 temarios (uno archivado),
    /// 2 temas, 2 intentos — uno con grabación real en disco y nota, otro sin.
    private func seed(_ env: TestEnvironment) throws -> (withRecording: Attempt, withoutRecording: Attempt) {
        let context = env.context

        let opposition = Opposition(name: "Judicatura, turno libre")
        context.insert(opposition)
        let syllabus = Syllabus(name: "Civil", opposition: opposition)
        context.insert(syllabus)
        let archived = Syllabus(name: "Antiguo", opposition: opposition)
        archived.isActive = false
        context.insert(archived)

        let topic1 = Topic(number: 42, title: "Responsabilidad \"patrimonial\"", syllabus: syllabus)
        context.insert(topic1)
        let topic2 = Topic(number: 7, syllabus: syllabus)
        context.insert(topic2)

        let session = PracticeSession()
        context.insert(session)

        let attempt1 = Attempt(topic: topic1, session: session, startedAt: Date(timeIntervalSince1970: 1_750_000_000))
        attempt1.endedAt = attempt1.startedAt.addingTimeInterval(708)
        attempt1.duration = 708
        attempt1.isCompleted = true
        context.insert(attempt1)

        let recording = Recording(attempt: attempt1, duration: 708, fileSize: 4096)
        context.insert(recording)
        try Data(repeating: 0xC5, count: 4096)
            .write(to: env.store.url(forRecordingID: recording.id))

        context.insert(Metric(attempt: attempt1, kind: .totalDuration, value: 708))
        context.insert(Note(attempt: attempt1, content: "Bien, pero lento"))

        let attempt2 = Attempt(topic: topic2, session: session, startedAt: Date(timeIntervalSince1970: 1_750_010_000))
        attempt2.duration = 300
        context.insert(attempt2)

        try context.save()
        return (attempt1, attempt2)
    }

    private func readJSON(_ package: URL, _ relativePath: String) throws -> Data {
        try Data(contentsOf: package.appending(path: relativePath))
    }

    @Test func fullPackageContainsEverything() throws {
        let env = try makeEnvironment()
        _ = try seed(env)

        let package = try env.service.buildFullPackage()
        let fm = FileManager.default

        #expect(package.lastPathComponent == "opospeak-export")
        for file in ["manifest.json", "data/oposiciones.json", "data/temarios.json", "data/temas.json",
                     "data/sesiones.json", "data/intentos.json", "data/metricas.json",
                     "data/notas.json", "data/intentos.csv"] {
            #expect(
                fm.fileExists(atPath: package.appending(path: file).path(percentEncoded: false)),
                "falta \(file)"
            )
        }

        let recordings = try fm.contentsOfDirectory(
            atPath: package.appending(path: "recordings").path(percentEncoded: false)
        )
        #expect(recordings.count == 1)
        #expect(recordings[0].hasSuffix(".m4a"))
    }

    @Test func manifestCountsExportedData() throws {
        let env = try makeEnvironment()
        _ = try seed(env)

        let package = try env.service.buildFullPackage()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let manifest = try decoder.decode(ManifestExport.self, from: readJSON(package, "manifest.json"))

        #expect(manifest.format == "opospeak-export")
        #expect(manifest.version == 2)
        #expect(manifest.appVersion == "1.0-test")
        #expect(manifest.counts.oppositions == 1)
        #expect(manifest.counts.syllabi == 2)
        #expect(manifest.counts.topics == 2)
        #expect(manifest.counts.sessions == 1)
        #expect(manifest.counts.attempts == 2)
        #expect(manifest.counts.recordings == 1)
        #expect(manifest.counts.notes == 1)
        #expect(manifest.recordingFormat == "m4a")
    }

    @Test func spanishContractKeysArePreserved() throws {
        let env = try makeEnvironment()
        _ = try seed(env)

        let package = try env.service.buildFullPackage()

        // Las claves JSON son contrato v2 en español (CodingKeys explícitas).
        let manifestText = try String(contentsOf: package.appending(path: "manifest.json"), encoding: .utf8)
        #expect(manifestText.contains("\"temarios\""))
        #expect(manifestText.contains("\"oposiciones\""))

        let syllabiText = try String(contentsOf: package.appending(path: "data/temarios.json"), encoding: .utf8)
        #expect(syllabiText.contains("\"nombre\""))
        #expect(syllabiText.contains("\"oposicionId\""))
        #expect(syllabiText.contains("\"fechaCreacion\""))

        let attemptsText = try String(contentsOf: package.appending(path: "data/intentos.json"), encoding: .utf8)
        #expect(attemptsText.contains("\"temaId\""))
        #expect(attemptsText.contains("\"duracionReal\""))
        #expect(attemptsText.contains("\"completado\""))
        // Clave aditiva (refine-attempt-curation): la curación viaja.
        #expect(attemptsText.contains("\"destacado\""))
    }

    @Test func missingRecordingDoesNotBlockAndIsReflected() throws {
        let env = try makeEnvironment()
        let (withRecording, _) = try seed(env)

        // Borrar el archivo dejando los metadatos huérfanos.
        if let recording = withRecording.recording {
            try env.store.deleteRecording(id: recording.id)
        }

        let package = try env.service.buildFullPackage()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let manifest = try decoder.decode(ManifestExport.self, from: readJSON(package, "manifest.json"))

        #expect(manifest.counts.recordings == 0)
        #expect(manifest.counts.attempts == 2)
    }

    @Test func relationshipsReconstructByID() throws {
        let env = try makeEnvironment()
        _ = try seed(env)

        let package = try env.service.buildFullPackage()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let oppositions = try decoder.decode([OppositionExport].self, from: readJSON(package, "data/oposiciones.json"))
        let syllabi = try decoder.decode([SyllabusExport].self, from: readJSON(package, "data/temarios.json"))
        let topics = try decoder.decode([TopicExport].self, from: readJSON(package, "data/temas.json"))
        let attempts = try decoder.decode([AttemptExport].self, from: readJSON(package, "data/intentos.json"))

        let oppositionIDs = Set(oppositions.map(\.id))
        let syllabusIDs = Set(syllabi.map(\.id))
        let topicIDs = Set(topics.map(\.id))

        for syllabus in syllabi {
            #expect(syllabus.oppositionID.map(oppositionIDs.contains) == true)
        }
        for topic in topics where topic.isActive {
            #expect(topic.syllabusID.map(syllabusIDs.contains) == true)
        }
        for attempt in attempts {
            #expect(attempt.topicID.map(topicIDs.contains) == true)
            if let recording = attempt.recording {
                let file = package.appending(path: recording.file)
                #expect(FileManager.default.fileExists(atPath: file.path(percentEncoded: false)))
            }
        }
    }

    @Test func exportedAudioIsByteIdentical() throws {
        let env = try makeEnvironment()
        let (withRecording, _) = try seed(env)
        let recording = try #require(withRecording.recording)

        let package = try env.service.buildFullPackage()
        let original = try Data(contentsOf: env.store.url(forRecordingID: recording.id))
        let exported = try Data(
            contentsOf: package.appending(path: "recordings/\(recording.id.uuidString).m4a")
        )
        #expect(original == exported)
    }

    @Test func csvHasHeaderRowsAndEscaping() throws {
        let env = try makeEnvironment()
        _ = try seed(env)

        let package = try env.service.buildFullPackage()
        let csv = try String(
            contentsOf: package.appending(path: "data/intentos.csv"), encoding: .utf8
        )
        let lines = csv.split(separator: "\n")

        #expect(lines[0] == Substring(AttemptsCSV.header))
        #expect(lines.count == 3) // cabecera + 2 intentos
        // El nombre de la oposición contiene una coma → debe ir entre comillas.
        #expect(csv.contains("\"Judicatura, turno libre\""))
        // El título del tema contiene comillas → deben duplicarse.
        #expect(csv.contains("\"Responsabilidad \"\"patrimonial\"\"\""))
    }

    @Test func csvEscaping() {
        #expect(AttemptsCSV.escape("simple") == "simple")
        #expect(AttemptsCSV.escape("con, coma") == "\"con, coma\"")
        #expect(AttemptsCSV.escape("con \"comillas\"") == "\"con \"\"comillas\"\"\"")
    }

    @Test func attemptPackageWithRecording() throws {
        let env = try makeEnvironment()
        let (withRecording, _) = try seed(env)
        let recording = try #require(withRecording.recording)

        let package = try env.service.buildAttemptPackage(attempt: withRecording)
        let fm = FileManager.default

        #expect(package.lastPathComponent == "intento-\(withRecording.id.uuidString)")
        #expect(fm.fileExists(atPath: package.appending(path: "intento.json").path(percentEncoded: false)))
        #expect(fm.fileExists(atPath: package.appending(path: "notas.json").path(percentEncoded: false)))
        #expect(fm.fileExists(
            atPath: package.appending(path: "\(recording.id.uuidString).m4a").path(percentEncoded: false)
        ))

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let notes = try decoder.decode([NoteExport].self, from: readJSON(package, "notas.json"))
        #expect(notes.count == 1)
        #expect(notes[0].content == "Bien, pero lento")
    }

    @Test func attemptPackageWithoutRecording() throws {
        let env = try makeEnvironment()
        let (_, withoutRecording) = try seed(env)

        let package = try env.service.buildAttemptPackage(attempt: withoutRecording)
        let contents = try FileManager.default.contentsOfDirectory(
            atPath: package.path(percentEncoded: false)
        )
        #expect(Set(contents) == ["intento.json", "notas.json"])
    }

    @Test func archiverProducesRealZip() throws {
        let dir = FileManager.default.temporaryDirectory
            .appending(path: "ArchiverTest-\(UUID().uuidString)")
            .appending(path: "contenido", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        try Data("hola".utf8).write(to: dir.appending(path: "archivo.txt"))

        let zip = try ExportArchiver.zip(directory: dir)

        #expect(zip.lastPathComponent == "contenido.zip")
        let data = try Data(contentsOf: zip)
        #expect(data.count > 0)
        // Firma PK de un zip.
        #expect(data.prefix(2) == Data([0x50, 0x4B]))
    }
}
