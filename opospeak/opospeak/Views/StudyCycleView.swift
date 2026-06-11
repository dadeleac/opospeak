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

/// La tarjeta de la Vuelta: cuatro hechos y un toque. Se oculta sin temas.
/// Sin sugerencias ni prioridades — posición, nunca prescripción (Fase 3
/// llegará cuando los datos la justifiquen).
struct StudyCycleCard: View {
    let topics: [Topic]

    private var summary: (cycle: StudyCycle, forgottenCount: Int) {
        let facts = topics.map(TopicFacts.init(topic:))
        let (insights, cycle) = TopicInsightsModel.evaluate(topics: facts, reference: .now)
        return (cycle, insights.filter { $0.state == .forgotten }.count)
    }

    var body: some View {
        let (cycle, forgotten) = summary

        Section {
            NavigationLink(value: StudyCycleDestination()) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Vuelta actual")
                            .font(.headline)
                        Spacer()
                        Text("Vuelta \(cycle.currentRound)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    ProgressView(
                        value: Double(cycle.coveredInRound),
                        total: Double(max(cycle.totalTopics, 1))
                    )
                    .tint(.ink)

                    Text("\(cycle.coveredInRound) de \(cycle.totalTopics) temas practicados")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if forgotten > 0 {
                        Label {
                            Text("\(forgotten) temas olvidados")
                        } icon: {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundStyle(Color.amber)
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
            .accessibilityHint("Abre el detalle de la vuelta al temario")
        }
    }
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
        let forgotten = insights.filter { $0.state == .forgotten }
            .sorted { ($0.lastPracticedAt ?? .distantPast) < ($1.lastPracticedAt ?? .distantPast) }
        let pending = activeTopics.filter { byID[$0.id]?.state == .pending }
            .sorted { $0.number < $1.number }
        let recent = insights.filter { $0.state == .recent }
            .sorted { ($0.lastPracticedAt ?? .distantPast) > ($1.lastPracticedAt ?? .distantPast) }

        List {
            Section("Cobertura") {
                VStack(alignment: .leading, spacing: 8) {
                    ProgressView(
                        value: Double(cycle.coveredInRound),
                        total: Double(max(cycle.totalTopics, 1))
                    )
                    .tint(.ink)
                    Text("Vuelta \(cycle.currentRound) · \(cycle.coveredInRound) de \(cycle.totalTopics) temas practicados")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
                .accessibilityElement(children: .combine)
            }

            mapSection(byID: byID)

            if !forgotten.isEmpty {
                topicGroupSection(title: "Temas olvidados", insights: forgotten)
            }
            if !pending.isEmpty {
                Section("Temas pendientes") {
                    ForEach(pending) { topic in
                        NavigationLink(value: topic) {
                            Text(topic.displayName)
                        }
                    }
                }
            }
            if !recent.isEmpty {
                topicGroupSection(title: "Temas recientes", insights: recent)
            }
        }
        .editorialBackground()
        .navigationTitle("Vuelta al temario")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedTopic) { topic in
            TopicDetailView(topic: topic)
        }
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
                            .background(style.color.opacity(0.25), in: RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Tema \(topic.number), \(style.label)")
                }
            }
            .padding(.vertical, 4)

            // Leyenda: icono + texto + color — el color nunca es la única señal.
            VStack(alignment: .leading, spacing: 6) {
                ForEach([TopicState.pending, .forgotten, .current, .recent], id: \.self) { state in
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

    private func topicGroupSection(title: LocalizedStringKey, insights groupInsights: [TopicInsight]) -> some View {
        Section(title) {
            ForEach(groupInsights, id: \.topicID) { insight in
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
        }
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
