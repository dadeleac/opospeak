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

    /// "42 · Título" cuando hay título; "Tema 42" si no. El número es la
    /// clave que conecta cada superficie con la cuadrícula del mapa y
    /// nunca debe desaparecer de las filas.
    var numberedDisplayName: String {
        if let title, !title.isEmpty { return "\(number) · \(title)" }
        return displayName
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

/// "Hoy", "Hace 1 día" o "Hace N días" — el singular importa.
func daysAgoLabel(_ days: Int) -> String {
    switch days {
    case 0: String(localized: "Hoy")
    case 1: String(localized: "Hace 1 día")
    default: String(localized: "Hace \(days) días")
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
