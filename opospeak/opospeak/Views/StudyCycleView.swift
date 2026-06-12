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

/// Desglose por estados, una línea por estado, SIEMPRE los tres
/// (incluidos los que están a cero: ver "0 necesitan repaso" enseña el
/// vocabulario antes de que haga falta). Vertical para que "2 al día"
/// nunca se lea como frecuencia diaria. Icono + texto: el color nunca
/// es la única señal.
struct SyllabusStatusBreakdown: View {
    let status: SyllabusStatus

    private func line(_ count: Int, state: TopicState) -> some View {
        let style = TopicStateStyle(state)
        let text = switch state {
        case .forgotten:
            count == 1
                ? String(localized: "1 necesita repaso")
                : String(localized: "\(count) necesitan repaso")
        case .pending:
            String(localized: "\(count) sin practicar")
        default:
            String(localized: "\(count) al día")
        }
        return Label {
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        } icon: {
            Image(systemName: style.icon)
                .font(.subheadline)
                .foregroundStyle(style.color)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            line(status.upToDate, state: .current)
            line(status.needsReview, state: .forgotten)
            line(status.unpracticed, state: .pending)
        }
        .accessibilityElement(children: .combine)
    }
}

/// La tarjeta del estado del temario: desglose por estados, no rotación.
/// Se calcula sobre estados, así que decae sola con el tiempo — no se
/// puede "completar" tocando cada tema una vez. Sin vuelta (concepto
/// interno), sin sugerencias: posición, nunca prescripción.
struct StudyCycleCard: View {
    let topics: [Topic]

    private var status: SyllabusStatus {
        let facts = topics.map(TopicFacts.init(topic:))
        let (insights, _) = TopicInsightsModel.evaluate(topics: facts, reference: .now)
        return TopicInsightsModel.status(insights)
    }

    var body: some View {
        let status = status

        Section {
            NavigationLink(value: StudyCycleDestination()) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Estado del temario")
                        .font(.headline)

                    ProgressView(
                        value: Double(status.upToDate),
                        total: Double(max(status.total, 1))
                    )
                    .tint(.ink)

                    SyllabusStatusBreakdown(status: status)
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

    private var activeSyllabi: [Syllabus] {
        (activeOpposition?.syllabi ?? [])
            .filter(\.isActive)
            .sorted { $0.createdAt < $1.createdAt }
    }

    private var activeTopics: [Topic] {
        activeSyllabi.flatMap { $0.topics ?? [] }.filter(\.isActive)
    }

    /// Con varios temarios, el contexto aparece donde hace falta;
    /// con uno solo, la pantalla no paga ruido por una ambigüedad
    /// que no puede existir.
    private var isMultiSyllabus: Bool {
        activeSyllabi.count > 1
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
        let health = TopicInsightsModel.status(insights)
        let next = TopicInsightsModel.suggestionOrder(insights).first
        let needsReview = insights.filter { $0.state == .forgotten }
            .sorted { ($0.lastPracticedAt ?? .distantPast) < ($1.lastPracticedAt ?? .distantPast) }
        let unpracticed = insights.filter { $0.state == .pending }
            .sorted { (topic(for: $0)?.number ?? 0) < (topic(for: $1)?.number ?? 0) }

        List {
            // Sin cabecera "salud": el título de la pantalla ya dice qué es.
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    ProgressView(
                        value: Double(health.upToDate),
                        total: Double(max(health.total, 1))
                    )
                    .tint(.ink)
                    SyllabusStatusBreakdown(status: health)
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
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(topic.displayName)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        if isMultiSyllabus, let name = topic.syllabus?.name {
                            Text("— \(name)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
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

    /// Texto compacto del desglose de un bloque (bajo el nombre del
    /// temario, el contexto está establecido).
    private func blockBreakdown(_ status: SyllabusStatus) -> String {
        let review = status.needsReview == 1
            ? String(localized: "1 necesita repaso")
            : String(localized: "\(status.needsReview) necesitan repaso")
        return String(localized: "\(status.upToDate) al día · ") + review
            + String(localized: " · \(status.unpracticed) sin practicar")
    }

    private func mapGrid(topics: [Topic], byID: [UUID: TopicInsight]) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 40), spacing: 6)], spacing: 6) {
            ForEach(topics.sorted { $0.number < $1.number }) { topic in
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
    }

    private func mapSection(byID: [UUID: TopicInsight]) -> some View {
        Section {
            if isMultiSyllabus {
                // Bloques por temario: los números son únicos dentro de su
                // bloque — la ambigüedad desaparece estructuralmente.
                ForEach(activeSyllabi) { syllabus in
                    let blockTopics = (syllabus.topics ?? []).filter(\.isActive)
                    let blockInsights = blockTopics.compactMap { byID[$0.id] }
                    VStack(alignment: .leading, spacing: 6) {
                        Text(syllabus.name)
                            .font(.subheadline.weight(.semibold))
                        Text(blockBreakdown(TopicInsightsModel.status(blockInsights)))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        mapGrid(topics: blockTopics, byID: byID)
                    }
                    .padding(.vertical, 4)
                }
            } else {
                mapGrid(topics: activeTopics, byID: byID)
                    .padding(.vertical, 4)
            }

            // Leyenda: tres estados visibles, con la MISMA muestra de tinte
            // que las celdas del mapa (la correspondencia celda↔leyenda se
            // entiende aunque un estado no tenga ejemplos todavía) + icono
            // + texto — el color nunca es la única señal.
            VStack(alignment: .leading, spacing: 6) {
                ForEach([TopicState.pending, .forgotten, .current], id: \.self) { state in
                    let style = TopicStateStyle(state)
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(style.color.opacity(style.mapTintOpacity))
                            .frame(width: 22, height: 18)
                        Image(systemName: style.icon)
                            .font(.caption)
                            .foregroundStyle(style.color)
                        Text(style.label)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .combine)
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
                            VStack(alignment: .leading, spacing: 2) {
                                Text(topic.displayName)
                                if isMultiSyllabus, let name = topic.syllabus?.name {
                                    Text(name)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
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

    private var isMultiSyllabus: Bool {
        (activeOpposition?.syllabi ?? []).filter(\.isActive).count > 1
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
                        VStack(alignment: .leading, spacing: 2) {
                            Text(row.topic.displayName)
                            if isMultiSyllabus, let name = row.topic.syllabus?.name {
                                Text(name)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
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
    // Los tres estados visibles presentes: al día (incl. matiz reciente),
    // necesita repaso y sin practicar — la leyenda siempre con ejemplos.
    for n in 1...12 {
        let topic = Topic(number: n, syllabus: syllabus)
        container.mainContext.insert(topic)
        let daysAgo: Double? = switch n {
        case 1...3: 2        // recientes (matiz dentro de "al día")
        case 4...6: 20       // al día
        case 7...9: 60       // necesitan repaso (umbral por defecto: 42)
        default: nil         // sin practicar
        }
        if let daysAgo {
            let attempt = Attempt(
                topic: topic, session: session,
                startedAt: .now.addingTimeInterval(-daysAgo * 86_400)
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
