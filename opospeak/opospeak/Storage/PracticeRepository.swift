//
//  PracticeRepository.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import SwiftData

/// Punto único de borrado de toda la jerarquía. SwiftData no ofrece hooks
/// fiables de side effects al borrar, así que los archivos de audio se
/// eliminan aquí antes de borrar el modelo (la cascada hace el resto).
/// No usar `modelContext.delete` directamente sobre intentos, grabaciones,
/// temas ni temarios: dejaría huérfano cada audio de debajo.
struct PracticeRepository {
    let modelContext: ModelContext
    let recordingStore: RecordingStore

    func delete(attempt: Attempt) throws {
        try deleteRecordingFile(of: attempt)
        modelContext.delete(attempt)
        try modelContext.save()
    }

    func delete(topic: Topic) throws {
        for attempt in topic.attempts ?? [] {
            try deleteRecordingFile(of: attempt)
        }
        modelContext.delete(topic)
        try modelContext.save()
    }

    func delete(syllabus: Syllabus) throws {
        for topic in syllabus.topics ?? [] {
            for attempt in topic.attempts ?? [] {
                try deleteRecordingFile(of: attempt)
            }
        }
        modelContext.delete(syllabus)
        try modelContext.save()
    }

    private func deleteRecordingFile(of attempt: Attempt) throws {
        if let recording = attempt.recording {
            try recordingStore.deleteRecording(id: recording.id, format: recording.format)
        }
    }
}
