//
//  PracticeService.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import SwiftData

/// Único punto de escritura al finalizar una práctica: sesión (reutilizada
/// o nueva según SessionPolicy), Intento, Grabación y Métrica se guardan en
/// una sola transacción. El archivo de audio ya debe existir en disco.
struct PracticeService {
    let modelContext: ModelContext
    let recordingStore: RecordingStore

    @discardableResult
    func finish(topic: Topic, recordingID: UUID, startedAt: Date, endedAt: Date) throws -> Attempt {
        let duration = endedAt.timeIntervalSince(startedAt)
        let session = try activeSession(at: endedAt)

        let attempt = Attempt(topic: topic, session: session, startedAt: startedAt)
        attempt.endedAt = endedAt
        attempt.duration = duration
        attempt.isCompleted = true
        modelContext.insert(attempt)

        let fileURL = recordingStore.url(forRecordingID: recordingID)
        let attributes = try? FileManager.default.attributesOfItem(
            atPath: fileURL.path(percentEncoded: false)
        )
        let fileSize = (attributes?[.size] as? Int64) ?? 0

        let recording = Recording(attempt: attempt, duration: duration, fileSize: fileSize)
        recording.id = recordingID
        modelContext.insert(recording)

        modelContext.insert(Metric(attempt: attempt, kind: .totalDuration, value: duration, date: endedAt))

        session.endedAt = endedAt
        try modelContext.save()
        return attempt
    }

    /// Abandona una práctica: borra el archivo parcial, no persiste nada.
    func discard(recordingID: UUID) {
        try? recordingStore.deleteRecording(id: recordingID)
    }

    private func activeSession(at date: Date) throws -> PracticeSession {
        var descriptor = FetchDescriptor<PracticeSession>(
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 5
        let recent = try modelContext.fetch(descriptor)

        if let reusable = recent.first(where: {
            SessionPolicy.isReusable(lastActivity: $0.endedAt ?? $0.startedAt, now: date)
        }) {
            return reusable
        }

        let session = PracticeSession(startedAt: date)
        modelContext.insert(session)
        return session
    }
}
