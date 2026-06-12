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
enum TopicState: Equatable, Hashable {
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

/// Salud del temario: la métrica de cobertura principal. Se calcula
/// sobre estados — decae sola con el tiempo, no se puede "completar"
/// tocando cada tema una vez. La cobertura por vuelta es otra cosa:
/// posición de rotación, secundaria.
struct SyllabusStatus: Equatable {
    /// recent + current.
    let upToDate: Int
    /// forgotten.
    let needsReview: Int
    /// pending.
    let unpracticed: Int

    var total: Int { upToDate + needsReview + unpracticed }
}

/// Posición en el ciclo de estudio (la vuelta). Concepto interno:
/// visible solo dentro del detalle, nunca como titular de la tarjeta.
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
    /// Honestidad de referencia: los intentos posteriores a `reference`
    /// no existen para la evaluación — evaluar en una fecha pasada
    /// devuelve exactamente el estado que el usuario tenía entonces.
    /// Esta es la costura que permite derivar la evolución
    /// ("estado hace 90 días") sin persistir snapshots.
    static func evaluate(
        topics: [TopicFacts],
        reference: Date,
        calendar: Calendar = .current
    ) -> (insights: [TopicInsight], cycle: StudyCycle) {
        let topics = topics.map { topic in
            TopicFacts(
                topicID: topic.topicID,
                attemptDates: topic.attemptDates.filter { $0 <= reference }
            )
        }
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

    /// Salud del temario a partir de los insights evaluados.
    static func status(_ insights: [TopicInsight]) -> SyllabusStatus {
        var upToDate = 0
        var needsReview = 0
        var unpracticed = 0
        for insight in insights {
            switch insight.state {
            case .recent, .current: upToDate += 1
            case .forgotten: needsReview += 1
            case .pending: unpracticed += 1
            }
        }
        return SyllabusStatus(
            upToDate: upToDate,
            needsReview: needsReview,
            unpracticed: unpracticed
        )
    }

    /// La película derivada: el estado del temario muestreado a lo largo
    /// de una ventana. Cada punto es una evaluación completa en esa
    /// referencia pasada (honestidad de referencia) — la evolución sale
    /// del mismo cálculo que la fotografía, sin snapshots persistidos.
    static func statusSeries(
        topics: [TopicFacts],
        from start: Date,
        to end: Date,
        samples: Int,
        calendar: Calendar = .current
    ) -> [(date: Date, status: SyllabusStatus)] {
        guard samples >= 2, end > start else {
            let (insights, _) = evaluate(topics: topics, reference: end, calendar: calendar)
            return [(end, status(insights))]
        }
        let step = end.timeIntervalSince(start) / Double(samples - 1)
        return (0..<samples).map { index in
            let date = start.addingTimeInterval(Double(index) * step)
            let (insights, _) = evaluate(topics: topics, reference: date, calendar: calendar)
            return (date, status(insights))
        }
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
