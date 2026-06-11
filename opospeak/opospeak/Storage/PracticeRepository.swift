//
//  PracticeRepository.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import SwiftData

/// Punto único de borrado de intentos. SwiftData no ofrece hooks fiables
/// de side effects al borrar, así que el archivo de audio se elimina aquí
/// antes de borrar el modelo. No usar `modelContext.delete` directamente
/// sobre intentos o grabaciones.
struct PracticeRepository {
    let modelContext: ModelContext
    let recordingStore: RecordingStore

    func delete(attempt: Attempt) throws {
        if let recording = attempt.recording {
            try recordingStore.deleteRecording(id: recording.id, format: recording.format)
        }
        modelContext.delete(attempt)
        try modelContext.save()
    }
}
