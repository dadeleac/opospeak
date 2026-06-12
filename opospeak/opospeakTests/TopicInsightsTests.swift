//
//  TopicInsightsTests.swift
//  opospeakTests
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import Testing
import SwiftData
@testable import opospeak

struct TopicInsightsTests {

    private let reference = Date(timeIntervalSince1970: 1_750_000_000)
    private let day: TimeInterval = 86_400

    private func topic(_ id: UUID = UUID(), daysAgo: [Double]) -> TopicFacts {
        TopicFacts(
            topicID: id,
            attemptDates: daysAgo.map { reference.addingTimeInterval(-$0 * day) }
        )
    }

    // MARK: - Cadencia

    @Test func cadenceIsPooledMedianOfIntervals() {
        // Tema A: intervalos 10 y 10; tema B: intervalos 20, 30, 40.
        // Mediana de [10, 10, 20, 30, 40] = 20.
        let topics = [
            topic(daysAgo: [25, 15, 5]),
            topic(daysAgo: [95, 75, 45, 5]),
        ]
        #expect(TopicInsightsModel.cadence(topics: topics) == 20)
    }

    @Test func medianResistsOutliers() {
        // Una pausa de 90 días (vacaciones) no redefine el ritmo.
        // Intervalos: [7, 7, 7, 7, 90] → mediana 7.
        let topics = [topic(daysAgo: [118, 28, 21, 14, 7, 0])]
        #expect(TopicInsightsModel.cadence(topics: topics) == 7)
    }

    @Test func coldStartUsesDefaultCadence() {
        // Menos de 5 intervalos → cadencia por defecto (21 días).
        let topics = [topic(daysAgo: [10, 5]), topic(daysAgo: [8])]
        #expect(TopicInsightsModel.cadence(topics: topics) == TopicInsightsModel.defaultCadenceDays)
    }

    @Test func emptySyllabusUsesDefaultCadence() {
        #expect(TopicInsightsModel.cadence(topics: []) == TopicInsightsModel.defaultCadenceDays)
    }

    // MARK: - Estados

    @Test func statesAtExactBoundaries() {
        // Cadencia forzada por defecto (pocos intervalos) → umbral de olvido
        // = max(14, 2 × 21) = 42 días.
        let pending = topic(daysAgo: [])
        let recentAt7 = topic(daysAgo: [7])
        let currentAt8 = topic(daysAgo: [8])
        let currentAt42 = topic(daysAgo: [42])
        let forgottenAt43 = topic(daysAgo: [43])

        let (insights, _) = TopicInsightsModel.evaluate(
            topics: [pending, recentAt7, currentAt8, currentAt42, forgottenAt43],
            reference: reference
        )

        #expect(insights[0].state == .pending)
        #expect(insights[1].state == .recent)       // ≤ 7 días: esta semana
        #expect(insights[2].state == .current)      // 8 días: ya no es reciente
        #expect(insights[3].state == .current)      // 42 = umbral exacto: aún al día
        #expect(insights[4].state == .forgotten)    // 43 > umbral
    }

    @Test func forgottenIsRelativeToOwnRhythm() {
        // Ritmo rápido: muchos intervalos de 10 días → umbral = max(14, 20) = 20.
        // 25 días sin práctica = olvidado para este usuario.
        let fastRotation = [
            topic(daysAgo: [55, 45, 35, 25]),          // intervalos 10,10,10
            topic(daysAgo: [50, 40, 30]),              // intervalos 10,10
        ]
        let (insights, cycle) = TopicInsightsModel.evaluate(
            topics: fastRotation, reference: reference
        )
        #expect(cycle.cadenceDays == 10)
        // Ambos temas llevan 25 y 30 días sin práctica → olvidados.
        #expect(insights.allSatisfy { $0.state == .forgotten })
    }

    @Test func absoluteFloorPreventsAbsurdThresholds() {
        // Cadencia de 2 días → umbral = max(14, 4) = 14, no 4.
        #expect(TopicInsightsModel.forgottenThresholdDays(cadenceDays: 2) == 14)
    }

    // MARK: - Vuelta y cobertura

    @Test func midRoundPosition() {
        // 2 temas con 3 intentos, 1 tema con 2 → vuelta 3, cobertura 2/3.
        let topics = [
            topic(daysAgo: [30, 20, 10]),
            topic(daysAgo: [28, 18, 8]),
            topic(daysAgo: [25, 15]),
        ]
        let (_, cycle) = TopicInsightsModel.evaluate(topics: topics, reference: reference)
        #expect(cycle.currentRound == 3)
        #expect(cycle.coveredInRound == 2)
        #expect(cycle.totalTopics == 3)
    }

    @Test func newTopicReopensRoundOne() {
        // Un tema sin practicar devuelve la vuelta a 1: honesto.
        let topics = [
            topic(daysAgo: [30, 20, 10]),
            topic(daysAgo: []),
        ]
        let (_, cycle) = TopicInsightsModel.evaluate(topics: topics, reference: reference)
        #expect(cycle.currentRound == 1)
        #expect(cycle.coveredInRound == 1)
    }

    @Test func emptySyllabusCycleIsWellDefined() {
        let (insights, cycle) = TopicInsightsModel.evaluate(topics: [], reference: reference)
        #expect(insights.isEmpty)
        #expect(cycle.currentRound == 1)
        #expect(cycle.coveredInRound == 0)
        #expect(cycle.totalTopics == 0)
    }

    // MARK: - Honestidad de referencia

    @Test func futureAttemptsDoNotExistForEvaluation() {
        // Un intento posterior a la referencia no existe al evaluar:
        // el pasado no ve el futuro (la costura de la Evolución).
        let futureOnly = topic(daysAgo: [-5])          // intento 5 días DESPUÉS
        let mixed = topic(daysAgo: [10, -3])           // uno antes, uno después

        let (insights, _) = TopicInsightsModel.evaluate(
            topics: [futureOnly, mixed], reference: reference
        )

        #expect(insights[0].state == .pending)
        #expect(insights[0].attemptCount == 0)
        #expect(insights[1].state == .current)         // solo cuenta el de hace 10 días
        #expect(insights[1].attemptCount == 1)
        #expect(insights[1].daysSinceLastPractice == 10)
    }

    @Test func pastEvaluationIsATruthfulTimeMachine() {
        // Evaluar 90 días atrás devuelve el estado de entonces.
        let topics = [topic(daysAgo: [100]), topic(daysAgo: [5])]
        let past = reference.addingTimeInterval(-90 * day)

        let (insights, _) = TopicInsightsModel.evaluate(topics: topics, reference: past)

        // Hace 90 días: el primero llevaba 10 días practicado (al día);
        // el segundo aún no existía como práctica (sin practicar).
        #expect(insights[0].state == .current)
        #expect(insights[1].state == .pending)
    }

    // MARK: - Salud del temario

    @Test func healthCountsByVisibleGroup() {
        // Cadencia por defecto (umbral 42): 2 al día (3 y 20 días),
        // 1 necesita repaso (50), 2 sin practicar.
        let topics = [
            topic(daysAgo: [3]),
            topic(daysAgo: [20]),
            topic(daysAgo: [50]),
            topic(daysAgo: []),
            topic(daysAgo: []),
        ]
        let (insights, _) = TopicInsightsModel.evaluate(topics: topics, reference: reference)
        let health = TopicInsightsModel.status(insights)

        #expect(health.upToDate == 2)
        #expect(health.needsReview == 1)
        #expect(health.unpracticed == 2)
        #expect(health.total == 5)
    }

    @Test func healthDecaysWithTime() {
        // El mismo tema, evaluado más tarde, cambia de grupo: la salud
        // no se puede "completar" tocando cada tema una vez.
        let topics = [topic(daysAgo: [30])]

        let (now, _) = TopicInsightsModel.evaluate(topics: topics, reference: reference)
        #expect(TopicInsightsModel.status(now).upToDate == 1)

        let later = reference.addingTimeInterval(30 * day)
        let (afterMonth, _) = TopicInsightsModel.evaluate(topics: topics, reference: later)
        #expect(TopicInsightsModel.status(afterMonth).needsReview == 1)
        #expect(TopicInsightsModel.status(afterMonth).upToDate == 0)
    }

    @Test func emptySyllabusStatusIsZero() {
        let health = TopicInsightsModel.status([])
        #expect(health.total == 0)
    }

    // MARK: - Serie de estado (la película)

    @Test func statusSeriesEndpointsAndCount() {
        // Tema practicado hace 10 días: al inicio de una ventana de 90
        // días aún no existía (sin practicar); hoy está al día.
        let topics = [topic(daysAgo: [10])]
        let start = reference.addingTimeInterval(-90 * day)

        let series = TopicInsightsModel.statusSeries(
            topics: topics, from: start, to: reference, samples: 12
        )

        #expect(series.count == 12)
        #expect(series.first?.date == start)
        #expect(series.last?.date == reference)
        #expect(series.first?.status.unpracticed == 1)
        #expect(series.last?.status.upToDate == 1)
    }

    @Test func statusSeriesWithEmptyHistory() {
        let topics = [topic(daysAgo: []), topic(daysAgo: [])]
        let start = reference.addingTimeInterval(-30 * day)

        let series = TopicInsightsModel.statusSeries(
            topics: topics, from: start, to: reference, samples: 5
        )

        #expect(series.count == 5)
        #expect(series.allSatisfy { $0.status.unpracticed == 2 })
    }

    @Test func statusSeriesDegenerateWindowYieldsSinglePoint() {
        let topics = [topic(daysAgo: [3])]
        let series = TopicInsightsModel.statusSeries(
            topics: topics, from: reference, to: reference, samples: 12
        )
        #expect(series.count == 1)
        #expect(series[0].status.upToDate == 1)
    }

    // MARK: - Ordenación de sugerencia

    @Test func suggestionOrderGroupsAndAges() {
        let pendingTopic = topic(daysAgo: [])
        let oldForgotten = topic(daysAgo: [80])
        let newerForgotten = topic(daysAgo: [50])
        let currentTopic = topic(daysAgo: [10])
        let recentTopic = topic(daysAgo: [2])

        let (insights, _) = TopicInsightsModel.evaluate(
            topics: [recentTopic, newerForgotten, pendingTopic, currentTopic, oldForgotten],
            reference: reference
        )
        let ordered = TopicInsightsModel.suggestionOrder(insights)

        #expect(ordered.map(\.state) == [.pending, .forgotten, .forgotten, .current, .recent])
        // Entre olvidados: el de práctica más antigua primero.
        #expect(ordered[1].topicID == oldForgotten.topicID)
        #expect(ordered[2].topicID == newerForgotten.topicID)
    }
}

// MARK: - Proyección desde modelos

@MainActor
struct TopicFactsProjectionTests {

    private static let sharedSchema = Schema([
        Opposition.self, Syllabus.self, Topic.self, PracticeSession.self,
        Attempt.self, Recording.self, Metric.self, Note.self,
    ])
    private static var retainedContainers: [ModelContainer] = []

    @Test func projectsAttemptDatesFromModel() throws {
        let config = ModelConfiguration(
            "test-\(UUID().uuidString)",
            schema: Self.sharedSchema,
            isStoredInMemoryOnly: true
        )
        let container = try ModelContainer(for: Self.sharedSchema, configurations: [config])
        Self.retainedContainers.append(container)
        let context = container.mainContext

        let opposition = Opposition(name: "Judicatura")
        context.insert(opposition)
        let syllabus = Syllabus(name: "Civil", opposition: opposition)
        context.insert(syllabus)
        let topic = Topic(number: 42, syllabus: syllabus)
        context.insert(topic)
        let session = PracticeSession()
        context.insert(session)
        let date1 = Date(timeIntervalSince1970: 1_750_000_000)
        let date2 = date1.addingTimeInterval(86_400)
        context.insert(Attempt(topic: topic, session: session, startedAt: date1))
        context.insert(Attempt(topic: topic, session: session, startedAt: date2))
        try context.save()

        let facts = TopicFacts(topic: topic)

        #expect(facts.topicID == topic.id)
        #expect(Set(facts.attemptDates) == Set([date1, date2]))
    }

    @Test func pendingTopicProjectsEmpty() throws {
        let config = ModelConfiguration(
            "test-\(UUID().uuidString)",
            schema: Self.sharedSchema,
            isStoredInMemoryOnly: true
        )
        let container = try ModelContainer(for: Self.sharedSchema, configurations: [config])
        Self.retainedContainers.append(container)
        let context = container.mainContext

        let opposition = Opposition(name: "Judicatura")
        context.insert(opposition)
        let syllabus = Syllabus(name: "Civil", opposition: opposition)
        context.insert(syllabus)
        let topic = Topic(number: 1, syllabus: syllabus)
        context.insert(topic)
        try context.save()

        let facts = TopicFacts(topic: topic)
        #expect(facts.attemptDates.isEmpty)
    }
}
