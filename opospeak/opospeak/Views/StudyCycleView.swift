//
//  StudyCycleView.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import SwiftUI
import SwiftData

/// Destino de navegación de la Vuelta (vive en el stack de Temarios).
struct StudyCycleDestination: Hashable {
    init() {}
}

/// La tarjeta del estado del temario: salud, no rotación. Se calcula
/// sobre estados, así que decae sola con el tiempo — no se puede
/// "completar" tocando cada tema una vez. Sin vuelta (concepto interno),
/// sin sugerencias: posición, nunca prescripción.
struct StudyCycleCard: View {
    let topics: [Topic]

    private var health: SyllabusHealth {
        let facts = topics.map(TopicFacts.init(topic:))
        let (insights, _) = TopicInsightsModel.evaluate(topics: facts, reference: .now)
        return TopicInsightsModel.health(insights)
    }

    private func breakdown(_ health: SyllabusHealth) -> String {
        var parts: [String] = []
        if health.upToDate > 0 {
            parts.append(String(localized: "\(health.upToDate) al día"))
        }
        if health.needsReview > 0 {
            parts.append(String(localized: "\(health.needsReview) necesitan repaso"))
        }
        if health.unpracticed > 0 {
            parts.append(String(localized: "\(health.unpracticed) sin practicar"))
        }
        return parts.joined(separator: " · ")
    }

    var body: some View {
        let health = health

        Section {
            NavigationLink(value: StudyCycleDestination()) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Estado del temario")
                        .font(.headline)

                    ProgressView(
                        value: Double(health.upToDate),
                        total: Double(max(health.total, 1))
                    )
                    .tint(.ink)

                    Text(breakdown(health))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
            .accessibilityHint("Abre el detalle del estado del temario")
        }
    }
}

/// Destino de las listas completas por estado ("Ver todos").
struct StateGroupDestination: Hashable {
    let state: TopicState
}

// El detalle de la Vuelta: cobertura, mapa y grupos factuales.
// Toda la semántica viene de TopicInsightsModel; los grupos son
// navegación, no prescripción.
struct StudyCycleView: View {
    @Query(sort: \Opposition.createdAt) private var oppositions: [Opposition]

    /// Navegación programática del mapa: varias NavigationLink dentro de
    /// una misma fila de List rompen los gestos (un toque empuja varias
    /// pantallas) y duplican chevrons. Las celdas son botones y el push
    /// es único, vía destino por item.
    @State private var selectedTopic: Topic?

    private var activeOpposition: Opposition? {
        if let idString = UserDefaults.standard.string(forKey: ActiveOpposition.storageKey),
           let id = UUID(uuidString: idString),
           let chosen = oppositions.first(where: { $0.id == id }) {
            return chosen
        }
        return oppositions.first
    }

    private var activeTopics: [Topic] {
        (activeOpposition?.syllabi ?? [])
            .flatMap { $0.topics ?? [] }
            .filter(\.isActive)
    }

    private var evaluation: (insights: [TopicInsight], cycle: StudyCycle) {
        TopicInsightsModel.evaluate(
            topics: activeTopics.map(TopicFacts.init(topic:)),
            reference: .now
        )
    }

    private func topic(for insight: TopicInsight) -> Topic? {
        activeTopics.first { $0.id == insight.topicID }
    }

    var body: some View {
        let (insights, cycle) = evaluation
        let byID = Dictionary(uniqueKeysWithValues: insights.map { ($0.topicID, $0) })
        let health = TopicInsightsModel.health(insights)
        let next = TopicInsightsModel.suggestionOrder(insights).first
        let needsReview = insights.filter { $0.state == .forgotten }
            .sorted { ($0.lastPracticedAt ?? .distantPast) < ($1.lastPracticedAt ?? .distantPast) }
        let unpracticed = insights.filter { $0.state == .pending }
            .sorted { (topic(for: $0)?.number ?? 0) < (topic(for: $1)?.number ?? 0) }

        List {
            Section("Salud del temario") {
                VStack(alignment: .leading, spacing: 8) {
                    ProgressView(
                        value: Double(health.upToDate),
                        total: Double(max(health.total, 1))
                    )
                    .tint(.ink)
                    Text("\(health.upToDate) al día · \(health.needsReview) necesitan repaso · \(health.unpracticed) sin practicar")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    // La vuelta: posición de rotación, secundaria. Visible
                    // aquí (cultura Judicatura), nunca en la tarjeta.
                    Text("Vuelta \(cycle.currentRound) · \(cycle.coveredInRound) de \(cycle.totalTopics) practicados en esta vuelta")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, 4)
                .accessibilityElement(children: .combine)
            }

            if let next, let nextTopic = topic(for: next) {
                nextSection(insight: next, topic: nextTopic)
            }

            mapSection(byID: byID)

            if !needsReview.isEmpty {
                topicGroupSection(
                    title: String(localized: "Necesitan repaso"),
                    insights: needsReview,
                    state: .forgotten
                )
            }
            if !unpracticed.isEmpty {
                topicGroupSection(
                    title: String(localized: "Sin practicar"),
                    insights: unpracticed,
                    state: .pending
                )
            }
        }
        .editorialBackground()
        .navigationTitle("Estado del temario")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedTopic) { topic in
            TopicDetailView(topic: topic)
        }
        .navigationDestination(for: StateGroupDestination.self) { destination in
            StateGroupListView(state: destination.state)
        }
    }

    // MARK: - Siguiente

    /// La cabeza de la ordenación canónica con su razón factual.
    /// Un tema, un hecho, un toque — sin puntuaciones ni urgencia.
    private func nextSection(insight: TopicInsight, topic: Topic) -> some View {
        Section("Siguiente") {
            Button {
                selectedTopic = topic
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(topic.displayName)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(nextReason(insight))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityHint("Abre la ficha del tema")
        }
    }

    private func nextReason(_ insight: TopicInsight) -> String {
        if insight.state == .pending {
            return String(localized: "Todavía no lo has cantado")
        }
        if let days = insight.daysSinceLastPractice {
            return String(localized: "Hace \(days) días sin práctica")
        }
        return ""
    }

    // MARK: - Mapa

    private func mapSection(byID: [UUID: TopicInsight]) -> some View {
        let sorted = activeTopics.sorted { $0.number < $1.number }

        return Section {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40), spacing: 6)], spacing: 6) {
                ForEach(sorted) { topic in
                    let state = byID[topic.id]?.state ?? .pending
                    let style = TopicStateStyle(state)
                    Button {
                        selectedTopic = topic
                    } label: {
                        Text("\(topic.number)")
                            .font(.caption)
                            .monospacedDigit()
                            .frame(minWidth: 40, minHeight: 36)
                            .background(
                                style.color.opacity(style.mapTintOpacity),
                                in: RoundedRectangle(cornerRadius: 6)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Tema \(topic.number), \(style.label)")
                }
            }
            .padding(.vertical, 4)

            // Leyenda: tres estados visibles, icono + texto + color —
            // el color nunca es la única señal.
            VStack(alignment: .leading, spacing: 6) {
                ForEach([TopicState.pending, .forgotten, .current], id: \.self) { state in
                    let style = TopicStateStyle(state)
                    Label {
                        Text(style.label)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } icon: {
                        Image(systemName: style.icon)
                            .font(.caption)
                            .foregroundStyle(style.color)
                    }
                }
            }
        } header: {
            Text("Mapa del temario")
        }
    }

    // MARK: - Grupos

    private static let groupCap = 5

    private func topicGroupSection(title: String, insights groupInsights: [TopicInsight], state: TopicState) -> some View {
        Section(title) {
            ForEach(groupInsights.prefix(Self.groupCap), id: \.topicID) { insight in
                if let topic = topic(for: insight) {
                    NavigationLink(value: topic) {
                        HStack {
                            Text(topic.displayName)
                            Spacer()
                            if let days = insight.daysSinceLastPractice {
                                Text(days == 0 ? String(localized: "Hoy") : String(localized: "Hace \(days) días"))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
            }
            if groupInsights.count > Self.groupCap {
                NavigationLink(value: StateGroupDestination(state: state)) {
                    Text("Ver todos (\(groupInsights.count))")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

/// Lista completa de un grupo de estado ("Ver todos"). Derivada como
/// todo lo demás: recalcula los insights al entrar.
struct StateGroupListView: View {
    let state: TopicState

    @Query(sort: \Opposition.createdAt) private var oppositions: [Opposition]

    private var activeOpposition: Opposition? {
        if let idString = UserDefaults.standard.string(forKey: ActiveOpposition.storageKey),
           let id = UUID(uuidString: idString),
           let chosen = oppositions.first(where: { $0.id == id }) {
            return chosen
        }
        return oppositions.first
    }

    private var activeTopics: [Topic] {
        (activeOpposition?.syllabi ?? [])
            .flatMap { $0.topics ?? [] }
            .filter(\.isActive)
    }

    private var rows: [(topic: Topic, insight: TopicInsight)] {
        let (insights, _) = TopicInsightsModel.evaluate(
            topics: activeTopics.map(TopicFacts.init(topic:)),
            reference: .now
        )
        let byID = Dictionary(uniqueKeysWithValues: insights.map { ($0.topicID, $0) })
        return activeTopics
            .compactMap { topic in
                guard let insight = byID[topic.id], insight.state == state else { return nil }
                return (topic, insight)
            }
            .sorted { a, b in
                if state == .pending { return a.topic.number < b.topic.number }
                return (a.insight.lastPracticedAt ?? .distantPast) < (b.insight.lastPracticedAt ?? .distantPast)
            }
    }

    var body: some View {
        List {
            ForEach(rows, id: \.topic.id) { row in
                NavigationLink(value: row.topic) {
                    HStack {
                        Text(row.topic.displayName)
                        Spacer()
                        if let days = row.insight.daysSinceLastPractice {
                            Text(days == 0 ? String(localized: "Hoy") : String(localized: "Hace \(days) días"))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
        .editorialBackground()
        .navigationTitle(TopicStateStyle(state).label)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Opposition.self, Syllabus.self, Topic.self, PracticeSession.self,
        Attempt.self, Recording.self, Metric.self, Note.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let opposition = Opposition(name: "Judicatura")
    container.mainContext.insert(opposition)
    let syllabus = Syllabus(name: "Civil", opposition: opposition)
    container.mainContext.insert(syllabus)
    let session = PracticeSession()
    container.mainContext.insert(session)
    for n in 1...12 {
        let topic = Topic(number: n, syllabus: syllabus)
        container.mainContext.insert(topic)
        if n <= 8 {
            let attempt = Attempt(
                topic: topic, session: session,
                startedAt: .now.addingTimeInterval(Double(-n * 6) * 86_400)
            )
            attempt.duration = 700
            container.mainContext.insert(attempt)
        }
    }

    return NavigationStack {
        StudyCycleView()
            .navigationDestination(for: Topic.self) { TopicDetailView(topic: $0) }
    }
    .modelContainer(container)
    .environment(AppEnvironment(mode: .local))
}
