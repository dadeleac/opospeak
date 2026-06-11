//
//  ModelDisplayHelpers.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation

extension Topic: TopicSortable {
    var attemptCount: Int { attempts?.count ?? 0 }

    var lastPracticedAt: Date? {
        attempts?.map(\.startedAt).max()
    }

    /// "Tema 42" cuando no hay título; el título cuando existe.
    var displayName: String {
        if let title, !title.isEmpty { return title }
        return String(localized: "Tema \(number)")
    }
}

extension Syllabus {
    var activeTopics: [Topic] {
        topics?.filter(\.isActive) ?? []
    }

    /// Fecha del intento más reciente entre todos los temas del temario.
    var recentActivity: Date? {
        topics?.compactMap(\.lastPracticedAt).max()
    }

    /// Siguiente número libre, contando también temas archivados.
    var nextFreeNumber: Int {
        (topics?.map(\.number).max() ?? 0) + 1
    }

    var existingNumbers: Set<Int> {
        Set(topics?.map(\.number) ?? [])
    }
}

/// Formatea segundos como "11:48" o "1:02:30".
func formatDuration(_ seconds: TimeInterval) -> String {
    let total = Int(seconds.rounded())
    let h = total / 3600
    let m = (total % 3600) / 60
    let s = total % 60
    return h > 0
        ? String(format: "%d:%02d:%02d", h, m, s)
        : String(format: "%d:%02d", m, s)
}
