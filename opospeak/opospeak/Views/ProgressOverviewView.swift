//
//  ProgressOverviewView.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import SwiftUI
import SwiftData

/// Ventana temporal de la evolución. "Todo" arranca en el primer intento.
private enum EvolutionWindow: String, CaseIterable, Identifiable {
    case days30
    case days90
    case all

    var id: String { rawValue }

    var title: String {
        switch self {
        case .days30: String(localized: "30 días")
        case .days90: String(localized: "90 días")
        case .all: String(localized: "Todo")
        }
    }

    func start(now: Date, earliestAttempt: Date?) -> Date {
        switch self {
        case .days30: now.addingTimeInterval(-30 * 86_400)
        case .days90: now.addingTimeInterval(-90 * 86_400)
        case .all: earliestAttempt ?? now
        }
    }

    /// Ancla temporal del "antes" en las barras de composición.
    var thenLabel: String {
        switch self {
        case .days30: String(localized: "Hace 30 días")
        case .days90: String(localized: "Hace 90 días")
        case .all: String(localized: "Al empezar")
        }
    }
}

/// El temario completo como una barra de composición: cada segmento es
/// un estado visible, con los mismos colores que el mapa del Estado —
/// el usuario ya conoce este lenguaje. Dos barras ("antes" y "Hoy")
/// muestran el temario cambiando de color: la forma visual de
/// "estoy avanzando", sin una sola cifra que interpretar.
private struct StatusCompositionBar: View {
    let status: SyllabusStatus

    private var segments: [(count: Int, state: TopicState)] {
        [
            (status.upToDate, .current),
            (status.needsReview, .forgotten),
            (status.unpracticed, .pending),
        ]
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 1) {
                ForEach(segments.filter { $0.count > 0 }, id: \.state) { segment in
                    TopicStateStyle(segment.state).color
                        .opacity(0.55)
                        .frame(
                            width: geometry.size.width
                                * Double(segment.count) / Double(max(status.total, 1))
                        )
                }
            }
            .clipShape(Capsule())
        }
        .frame(height: 12)
    }
}

// Progreso es la película: "¿qué ha cambiado?". La fotografía ("¿qué
// hago ahora?") vive en Temarios. Todo derivado retroactivamente del
// modelo de insights — cero snapshots. Hechos, sin juicios ni rachas
// (define-progress-and-history-model).
struct ProgressOverviewView: View {
    @Query(sort: \Opposition.createdAt) private var oppositions: [Opposition]
    @Query private var attempts: [Attempt]
    @Query(filter: #Predicate<Topic> { $0.isActive }) private var topics: [Topic]

    @State private var window: EvolutionWindow = .days90

    private var activeOpposition: Opposition? {
        if let idString = UserDefaults.standard.string(forKey: ActiveOpposition.storageKey),
           let id = UUID(uuidString: idString),
           let chosen = oppositions.first(where: { $0.id == id }) {
            return chosen
        }
        return oppositions.first
    }

    private var activeTopics: [Topic] {
        guard let active = activeOpposition else { return [] }
        return topics.filter { $0.syllabus?.opposition?.id == active.id }
    }

    private var activeAttempts: [Attempt] {
        guard let active = activeOpposition else { return [] }
        return attempts.filter { $0.topic?.syllabus?.opposition?.id == active.id }
    }

    private var hasActivity: Bool {
        !activeAttempts.isEmpty
    }

    var body: some View {
        let now = Date.now
        let earliest = activeAttempts.map(\.startedAt).min()
        let start = window.start(now: now, earliestAttempt: earliest)
        let facts = activeTopics.map(TopicFacts.init(topic:))

        List {
            if hasActivity {
                Section {
                    Picker("Periodo", selection: $window) {
                        ForEach(EvolutionWindow.allCases) { window in
                            Text(window.title).tag(window)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }

                periodSection(start: start, now: now)
                evolutionSection(facts: facts, start: start, now: now)
            }
        }
        .editorialBackground()
        .navigationTitle("Progreso")
        .overlay {
            if !hasActivity {
                ContentUnavailableView {
                    Label("Todavía sin evolución", systemImage: "chart.line.uptrend.xyaxis")
                } description: {
                    Text("Aquí verás cómo cambia tu preparación a medida que practiques. Empieza desde la pestaña Temarios.")
                }
            }
        }
    }

    // MARK: - En este periodo

    /// Los hechos de actividad de la ventana, vía el resumen existente.
    private func periodSection(start: Date, now: Date) -> some View {
        let windowAttempts = activeAttempts.filter { $0.startedAt >= start }
        let summary = ProgressSummary(
            attempts: windowAttempts.map {
                .init(date: $0.startedAt, duration: $0.duration, topicID: $0.topic?.id ?? UUID())
            },
            topicIDs: activeTopics.map(\.id),
            reference: now
        )

        return Section("En este periodo") {
            LabeledContent("Prácticas", value: "\(summary.totalAttempts)")
            LabeledContent("Tiempo total", value: formatDuration(summary.totalTime))
            LabeledContent("Días con práctica", value: "\(summary.activeDays)")
        }
    }

    // MARK: - Evolución del temario

    /// La película necesita metraje: con menos de 14 días de historia no
    /// se proyecta — una explicación tranquila ocupa su lugar.
    private static let minimumHistoryDays = 14.0

    private func evolutionSection(facts: [TopicFacts], start: Date, now: Date) -> some View {
        let earliest = activeAttempts.map(\.startedAt).min() ?? now
        let historyDays = now.timeIntervalSince(earliest) / 86_400

        return Section("Evolución del temario") {
            if historyDays < Self.minimumHistoryDays {
                Text("La evolución aparecerá cuando acumules más días de práctica.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                evolutionBars(facts: facts, start: start, now: now)
            }
        }
    }

    /// El antes y el después de la foto del mapa: dos barras de
    /// composición ancladas en el tiempo, y la frase narrativa como pie
    /// y como resumen de accesibilidad.
    private func evolutionBars(facts: [TopicFacts], start: Date, now: Date) -> some View {
        let (thenInsights, _) = TopicInsightsModel.evaluate(topics: facts, reference: start)
        let (nowInsights, _) = TopicInsightsModel.evaluate(topics: facts, reference: now)
        let then = TopicInsightsModel.status(thenInsights)
        let current = TopicInsightsModel.status(nowInsights)

        return VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(window.thenLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                StatusCompositionBar(status: then)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Hoy")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                StatusCompositionBar(status: current)
            }

            Text(narrative(then: then, current: current))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(narrative(then: then, current: current))
    }

    /// La versión editorial del cambio, en palabras llanas. Hechos con
    /// dirección, jamás calificaciones.
    private func narrative(then: SyllabusStatus, current: SyllabusStatus) -> String {
        var sentence = String(localized: "\(window.thenLabel) tenías \(then.upToDate) temas al día; hoy tienes \(current.upToDate).")
        if current.needsReview > 0 {
            sentence += " " + (current.needsReview == 1
                ? String(localized: "1 necesita repaso.")
                : String(localized: "\(current.needsReview) necesitan repaso."))
        }
        if current.unpracticed > 0 {
            sentence += " " + String(localized: "\(current.unpracticed) siguen sin practicar.")
        }
        return sentence
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
                startedAt: .now.addingTimeInterval(Double(-n * 8) * 86_400)
            )
            attempt.duration = 700
            container.mainContext.insert(attempt)
        }
    }

    return NavigationStack {
        ProgressOverviewView()
    }
    .modelContainer(container)
}
