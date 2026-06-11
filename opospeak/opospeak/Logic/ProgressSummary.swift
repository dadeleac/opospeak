//
//  ProgressSummary.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation

/// Resumen de progreso derivado de los intentos. Nunca se persiste:
/// las estadísticas son vistas derivadas (define-core-domain-model).
/// Muestra hechos, no juicios (define-progress-and-history-model).
struct ProgressSummary {

    /// Proyección plana de un intento, para que el cálculo sea testable
    /// sin contenedor SwiftData.
    struct AttemptData {
        let date: Date
        let duration: TimeInterval
        let topicID: UUID
    }

    // Volumen
    let totalAttempts: Int
    let totalTime: TimeInterval
    let topicsWorked: Int
    let activeDays: Int

    // Consistencia (hechos, sin presión de racha)
    let daysPracticedLast7: Int
    let daysPracticedLast30: Int

    // Cobertura
    let totalTopics: Int
    let practicedTopics: Int
    var neverPracticedTopics: Int { totalTopics - practicedTopics }

    // Distribución
    let mostPracticedTopic: (topicID: UUID, attempts: Int)?
    let leastPracticedTopic: (topicID: UUID, attempts: Int)?

    var hasActivity: Bool { totalAttempts > 0 }

    init(attempts: [AttemptData], topicIDs: [UUID], reference: Date = .now, calendar: Calendar = .current) {
        totalAttempts = attempts.count
        totalTime = attempts.reduce(0) { $0 + $1.duration }

        let byTopic = Dictionary(grouping: attempts, by: \.topicID)
        topicsWorked = byTopic.count

        let days = Set(attempts.map { calendar.startOfDay(for: $0.date) })
        activeDays = days.count

        func daysPracticed(last n: Int) -> Int {
            guard let limit = calendar.date(byAdding: .day, value: -n, to: reference) else { return 0 }
            return days.filter { $0 > limit && $0 <= reference }.count
        }
        daysPracticedLast7 = daysPracticed(last: 7)
        daysPracticedLast30 = daysPracticed(last: 30)

        totalTopics = topicIDs.count
        let knownIDs = Set(topicIDs)
        practicedTopics = byTopic.keys.filter { knownIDs.contains($0) }.count

        let counts = byTopic
            .filter { knownIDs.contains($0.key) }
            .map { (topicID: $0.key, attempts: $0.value.count) }
        mostPracticedTopic = counts.max { $0.attempts < $1.attempts }
        leastPracticedTopic = counts.min { $0.attempts < $1.attempts }
    }
}
