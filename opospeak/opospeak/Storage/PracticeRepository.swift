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

    func delete(intento: Intento) throws {
        if let grabacion = intento.grabacion {
            try recordingStore.deleteRecording(id: grabacion.id, formato: grabacion.formato)
        }
        modelContext.delete(intento)
        try modelContext.save()
    }
}
