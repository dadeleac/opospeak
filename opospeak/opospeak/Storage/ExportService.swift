//
//  ExportService.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import SwiftData

/// Ensambla los paquetes de exportación en disco (define-export-format).
/// La exportación incluye TODO: oposiciones, temarios y temas archivados,
/// todos los intentos, métricas y notas, y cada grabación presente en disco.
/// Los nombres de archivo del paquete son contrato v2 (español).
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
        let root = FileManager.default.temporaryDirectory
            .appending(path: "export-\(UUID().uuidString)")
        let package = root.appending(path: "opospeak-export", directoryHint: .isDirectory)
        let dataDir = package.appending(path: "data", directoryHint: .isDirectory)
        let recordingsDir = package.appending(path: "recordings", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: dataDir, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: recordingsDir, withIntermediateDirectories: true)

        let oppositions = try modelContext.fetch(FetchDescriptor<Opposition>())
        let syllabi = try modelContext.fetch(FetchDescriptor<Syllabus>())
        let topics = try modelContext.fetch(FetchDescriptor<Topic>())
        let sessions = try modelContext.fetch(FetchDescriptor<PracticeSession>())
        let attempts = try modelContext.fetch(
            FetchDescriptor<Attempt>(sortBy: [SortDescriptor(\.startedAt)])
        )
        let metrics = try modelContext.fetch(FetchDescriptor<Metric>())
        let notes = try modelContext.fetch(FetchDescriptor<Note>())

        let encoder = ExportSchema.encoder
        func write<T: Encodable>(_ value: T, to fileName: String) throws {
            try encoder.encode(value).write(to: dataDir.appending(path: fileName))
        }

        try write(oppositions.map(OppositionExport.init), to: "oposiciones.json")
        try write(syllabi.map(SyllabusExport.init), to: "temarios.json")
        try write(topics.map(TopicExport.init), to: "temas.json")
        try write(sessions.map(SessionExport.init), to: "sesiones.json")
        try write(attempts.map(AttemptExport.init), to: "intentos.json")
        try write(metrics.map(MetricExport.init), to: "metricas.json")
        try write(notes.map(NoteExport.init), to: "notas.json")

        try AttemptsCSV.build(attempts: attempts)
            .write(to: dataDir.appending(path: "intentos.csv"), atomically: true, encoding: .utf8)

        // Copia byte a byte; los archivos ausentes no bloquean la exportación.
        var copiedRecordings = 0
        for attempt in attempts {
            guard let recording = attempt.recording,
                  let source = recordingStore.existingURL(
                      forRecordingID: recording.id, format: recording.format
                  )
            else { continue }
            let target = recordingsDir.appending(
                path: "\(recording.id.uuidString).\(recording.format)"
            )
            try FileManager.default.copyItem(at: source, to: target)
            copiedRecordings += 1
        }

        let manifest = ManifestExport(
            format: ExportSchema.packageFormat,
            version: ExportSchema.version,
            exportedAt: .now,
            appVersion: appVersion,
            counts: .init(
                oppositions: oppositions.count,
                syllabi: syllabi.count,
                topics: topics.count,
                sessions: sessions.count,
                attempts: attempts.count,
                recordings: copiedRecordings,
                notes: notes.count
            ),
            recordingFormat: "m4a"
        )
        try encoder.encode(manifest).write(to: package.appending(path: "manifest.json"))

        return package
    }

    /// Paquete reducido de un intento: intento.json (con contexto de tema,
    /// temario y oposición), notas.json y el audio si existe.
    func buildAttemptPackage(attempt: Attempt) throws -> URL {
        let root = FileManager.default.temporaryDirectory
            .appending(path: "export-\(UUID().uuidString)")
        let name = "intento-\(attempt.id.uuidString)"
        let package = root.appending(path: name, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: package, withIntermediateDirectories: true)

        struct SingleAttemptExport: Codable {
            let attempt: AttemptExport
            let topic: TopicExport?
            let syllabus: SyllabusExport?
            let opposition: OppositionExport?

            enum CodingKeys: String, CodingKey {
                case attempt = "intento"
                case topic = "tema"
                case syllabus = "temario"
                case opposition = "oposicion"
            }
        }

        let encoder = ExportSchema.encoder
        let content = SingleAttemptExport(
            attempt: AttemptExport(attempt),
            topic: attempt.topic.map(TopicExport.init),
            syllabus: attempt.topic?.syllabus.map(SyllabusExport.init),
            opposition: attempt.topic?.syllabus?.opposition.map(OppositionExport.init)
        )
        try encoder.encode(content).write(to: package.appending(path: "intento.json"))

        let notes = (attempt.notes ?? []).sorted { $0.createdAt < $1.createdAt }
        try encoder.encode(notes.map(NoteExport.init))
            .write(to: package.appending(path: "notas.json"))

        if let recording = attempt.recording,
           let source = recordingStore.existingURL(
               forRecordingID: recording.id, format: recording.format
           ) {
            let target = package.appending(
                path: "\(recording.id.uuidString).\(recording.format)"
            )
            try FileManager.default.copyItem(at: source, to: target)
        }

        return package
    }
}
