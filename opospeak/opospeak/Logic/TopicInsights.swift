//
//  TopicInsights.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation

// Implementación de referencia de define-topic-insights-model.
// La semántica de pendiente/reciente/al día/olvidado, la cadencia, la
// vuelta y la cobertura viven AQUÍ y solo aquí: ningún consumidor
// (Ficha, Vuelta, extracción, Progreso) reimplementa estas definiciones.
// Todo es derivado — nada se persiste; los estados hablan de tiempo,
// nunca de calidad.

/// Proyección plana de un tema, para que el cálculo sea testable sin
/// contenedor SwiftData.
struct TopicFacts {
    let topicID: UUID
    /// Fechas de inicio de los intentos, en cualquier orden.
    let attemptDates: [Date]
}

extension TopicFacts {
    /// Proyección desde el modelo. Todo consumidor (Ficha, Vuelta,
    /// extracción) construye las entradas exactamente igual.
    init(topic: Topic) {
        self.init(
            topicID: topic.id,
            attemptDates: (topic.attempts ?? []).map(\.startedAt)
        )
    }
}

/// Estado temporal de un tema. Exactamente uno por tema activo.
enum TopicState: Equatable {
    /// Nunca practicado.
    case pending
    /// Practicado esta semana.
    case recent
    /// Practicado, ni reciente ni olvidado.
    case current
    /// Más del doble de tu propio ritmo sin cantarlo.
    case forgotten
}

/// Resultado por tema.
struct TopicInsight: Equatable {
    let topicID: UUID
    let state: TopicState
    let attemptCount: Int
    let lastPracticedAt: Date?
    let daysSinceLastPractice: Int?
}

/// Posición en el ciclo de estudio (la vuelta).
struct StudyCycle: Equatable {
    /// Vuelta actual = mínimo de intentos entre temas activos + 1.
    let currentRound: Int
    /// Temas activos ya practicados en la vuelta actual.
    let coveredInRound: Int
    let totalTopics: Int
    /// Cadencia de revisita aplicada (días), por defecto en arranque en frío.
    let cadenceDays: Double
}

enum TopicInsightsModel {

    // Constantes nombradas de la fundación: ajustar aquí y en el doc, juntos.
    /// "Esta semana": ventana de reciente, fija y universal.
    static let recencyWindowDays = 7
    /// Suelo absoluto del umbral de olvido.
    static let forgottenFloorDays = 14.0
    /// Multiplicador sobre la cadencia propia.
    static let forgottenCadenceFactor = 2.0
    /// Cadencia por defecto en arranque en frío.
    static let defaultCadenceDays = 21.0
    /// Intervalos mínimos para confiar en la cadencia calculada.
    static let minimumIntervalsForCadence = 5

    /// Mediana de los intervalos (en días) entre intentos consecutivos del
    /// mismo tema, agrupando todos los temas. Mediana y no media: unas
    /// vacaciones no deben redefinir el ritmo.
    static func cadence(topics: [TopicFacts]) -> Double {
        var intervals: [Double] = []
        for topic in topics {
            let sorted = topic.attemptDates.sorted()
            guard sorted.count >= 2 else { continue }
            for i in 1..<sorted.count {
                intervals.append(sorted[i].timeIntervalSince(sorted[i - 1]) / 86_400)
            }
        }
        guard intervals.count >= minimumIntervalsForCadence else {
            return defaultCadenceDays
        }
        let sorted = intervals.sorted()
        let mid = sorted.count / 2
        return sorted.count.isMultiple(of: 2)
            ? (sorted[mid - 1] + sorted[mid]) / 2
            : sorted[mid]
    }

    /// Umbral de olvido en días: max(suelo, factor × cadencia).
    static func forgottenThresholdDays(cadenceDays: Double) -> Double {
        max(forgottenFloorDays, forgottenCadenceFactor * cadenceDays)
    }

    /// Evalúa todos los temas activos de la oposición activa.
    static func evaluate(
        topics: [TopicFacts],
        reference: Date,
        calendar: Calendar = .current
    ) -> (insights: [TopicInsight], cycle: StudyCycle) {
        let cadenceDays = cadence(topics: topics)
        let threshold = forgottenThresholdDays(cadenceDays: cadenceDays)

        let insights = topics.map { topic -> TopicInsight in
            let last = topic.attemptDates.max()
            let days = last.map {
                calendar.dateComponents(
                    [.day],
                    from: calendar.startOfDay(for: $0),
                    to: calendar.startOfDay(for: reference)
                ).day ?? 0
            }

            let state: TopicState
            if topic.attemptDates.isEmpty {
                state = .pending
            } else if let days, Double(days) > threshold {
                state = .forgotten
            } else if let days, days <= recencyWindowDays {
                state = .recent
            } else {
                state = .current
            }

            return TopicInsight(
                topicID: topic.topicID,
                state: state,
                attemptCount: topic.attemptDates.count,
                lastPracticedAt: last,
                daysSinceLastPractice: days
            )
        }

        let counts = topics.map(\.attemptDates.count)
        let currentRound = (counts.min() ?? 0) + 1
        let covered = counts.filter { $0 >= currentRound }.count

        return (
            insights,
            StudyCycle(
                currentRound: currentRound,
                coveredInRound: covered,
                totalTopics: topics.count,
                cadenceDays: cadenceDays
            )
        )
    }

    /// Ordenación canónica de "qué practicar ahora": pendientes →
    /// olvidados (más antiguo primero) → al día → recientes.
    /// Es una ordenación sobre hechos, jamás un planificador.
    static func suggestionOrder(_ insights: [TopicInsight]) -> [TopicInsight] {
        func group(_ state: TopicState) -> Int {
            switch state {
            case .pending: 0
            case .forgotten: 1
            case .current: 2
            case .recent: 3
            }
        }
        return insights.sorted { a, b in
            let ga = group(a.state)
            let gb = group(b.state)
            if ga != gb { return ga < gb }
            // Dentro del grupo: práctica más antigua primero (nil = pendiente,
            // conserva orden estable por fecha distantePast).
            let da = a.lastPracticedAt ?? .distantPast
            let db = b.lastPracticedAt ?? .distantPast
            return da < db
        }
    }
}
