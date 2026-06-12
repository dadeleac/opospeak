//
//  TopicDetailView.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import SwiftUI
import SwiftData
import Charts

// La Ficha de tema: el banco de trabajo del opositor para un tema
// (centro de gravedad, define-information-architecture). Estado, hechos,
// evolución y notas — toda la semántica temporal viene de
// TopicInsightsModel; la vista jamás reimplementa una definición.
struct TopicDetailView: View {
    let topic: Topic

    @State private var practicing = false
    @State private var editing = false

    private var sortedAttempts: [Attempt] {
        (topic.attempts ?? []).sorted { $0.startedAt > $1.startedAt }
    }

    private var detailSubtitle: String {
        let syllabusName = topic.syllabus?.name ?? ""
        guard topic.title?.isEmpty == false else { return syllabusName }
        return syllabusName.isEmpty
            ? String(localized: "Tema \(topic.number)")
            : String(localized: "Tema \(topic.number) — \(syllabusName)")
    }

    // La cadencia es agrupada: el insight de este tema necesita los hechos
    // de todos los temas activos de la oposición (vía relaciones, sin queries).
    private var insight: TopicInsight? {
        let syllabi = topic.syllabus?.opposition?.syllabi ?? []
        let allTopics = syllabi.flatMap { $0.topics ?? [] }.filter(\.isActive)
        let facts = allTopics.map(TopicFacts.init(topic:))
        let (insights, _) = TopicInsightsModel.evaluate(topics: facts, reference: .now)
        return insights.first { $0.topicID == topic.id }
    }

    /// Últimas 10 duraciones con tiempo, en orden cronológico.
    private var evolutionPoints: [(index: Int, minutes: Double)] {
        let timed = (topic.attempts ?? [])
            .filter { $0.duration > 0 }
            .sorted { $0.startedAt < $1.startedAt }
            .suffix(10)
        return timed.enumerated().map { ($0.offset + 1, $0.element.duration / 60) }
    }

    private var recentNotes: [Note] {
        (topic.attempts ?? [])
            .flatMap { $0.notes ?? [] }
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(3)
            .map { $0 }
    }

    var body: some View {
        List {
            Section {
                Button {
                    practicing = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "mic.fill")
                        Text("Practicar")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .accessibilityHint("Inicia la grabación de una práctica oral de este tema")
            }

            if let insight {
                stateSection(insight)
            }

            if evolutionPoints.count >= 2 {
                evolutionSection
            }

            if !recentNotes.isEmpty {
                notesSection
            }

            if !sortedAttempts.isEmpty {
                Section("Historial") {
                    ForEach(sortedAttempts) { attempt in
                        NavigationLink(value: attempt) {
                            AttemptRow(attempt: attempt)
                        }
                    }
                }
            }
        }
        .editorialBackground()
        .navigationTitle(topic.displayName)
        // Contexto completo bajo el título: el número (la clave que
        // conecta con el mapa) cuando el tema tiene título, y el temario.
        .navigationSubtitle(detailSubtitle)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    editing = true
                } label: {
                    Label("Editar tema", systemImage: "pencil")
                }
            }
        }
        .sheet(isPresented: $editing) {
            EditTopicSheet(topic: topic)
        }
        .fullScreenCover(isPresented: $practicing) {
            PracticeView(topic: topic)
        }
    }

    // MARK: - Estado

    private func stateSection(_ insight: TopicInsight) -> some View {
        let info = TopicStateStyle(insight.state)
        let totalTime = (topic.attempts ?? []).reduce(0) { $0 + $1.duration }

        return Section("Estado") {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: info.icon)
                        .foregroundStyle(info.color)
                    Text(info.label)
                        .font(.headline)
                }
                Text(info.explanation)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)

            if insight.attemptCount > 0 {
                LabeledContent("Intentos", value: "\(insight.attemptCount)")
                LabeledContent("Tiempo total", value: formatDuration(totalTime))
                if let days = insight.daysSinceLastPractice {
                    LabeledContent("Última práctica") {
                        Text(daysAgoLabel(days))
                    }
                }
            }
        }
    }

    // MARK: - Evolución

    private var evolutionSection: some View {
        Section("Evolución") {
            Chart(evolutionPoints, id: \.index) { point in
                LineMark(
                    x: .value("Intento", point.index),
                    y: .value("Minutos", point.minutes)
                )
                .foregroundStyle(Color.ink)
                PointMark(
                    x: .value("Intento", point.index),
                    y: .value("Minutos", point.minutes)
                )
                .foregroundStyle(Color.ink)
            }
            .chartXAxis(.hidden)
            .chartYAxisLabel("min")
            .frame(height: 120)
            .padding(.vertical, 4)
            .accessibilityLabel("Evolución de duraciones")
            .accessibilityValue(evolutionAccessibilitySummary)
        }
    }

    private var evolutionAccessibilitySummary: String {
        guard let first = evolutionPoints.first, let last = evolutionPoints.last else { return "" }
        return String(localized: "De \(Int(first.minutes)) a \(Int(last.minutes)) minutos en los últimos \(evolutionPoints.count) intentos")
    }

    // MARK: - Notas

    /// El post-it del banco de trabajo: "¿qué me dije la última vez?".
    /// Contenido para releer, no otra lista de navegación — el Historial
    /// de abajo ya es el archivo cronológico. El toque sigue llevando al
    /// intento, pero el texto manda y el timestamp (con hora: dos notas
    /// del mismo día deben distinguirse) es caption.
    private var notesSection: some View {
        Section("Notas recientes") {
            ForEach(recentNotes) { note in
                if let attempt = note.attempt {
                    // Link invisible de fondo: navega por el mismo destino
                    // (value-based) que el Historial — un segundo
                    // navigationDestination para Attempt en este stack
                    // pisa al existente y rompe los links del historial.
                    VStack(alignment: .leading, spacing: 6) {
                        Text(note.content)
                            .foregroundStyle(.primary)
                            .lineLimit(3)
                        Text(note.createdAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background {
                        NavigationLink(value: attempt) { EmptyView() }
                            .opacity(0)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityHint("Abre el intento de esta nota")
                }
            }
        }
    }
}

/// Edición de número y título (tema-editing). El título puede quedar
/// vacío — el tema vuelve a mostrarse como "Tema N". Los títulos nunca
/// son obligatorios para practicar.
struct EditTopicSheet: View {
    let topic: Topic

    @Environment(\.dismiss) private var dismiss

    @State private var number: Int = 1
    @State private var title = ""

    private var isNumberAvailable: Bool {
        guard number != topic.number else { return true }
        return !(topic.syllabus?.existingNumbers.contains(number) ?? false)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Stepper(value: $number, in: 1...9999) {
                        HStack {
                            Text("Número")
                            Spacer()
                            Text("\(number)")
                                .foregroundStyle(isNumberAvailable ? .secondary : Color.mutedRed)
                        }
                    }
                    .accessibilityLabel("Número de tema")
                    .accessibilityValue("\(number)")
                } footer: {
                    if !isNumberAvailable {
                        Text("Ya existe un tema con el número \(number) en este temario.")
                    }
                }
                Section {
                    TextField("Título", text: $title)
                        .accessibilityLabel("Título del tema")
                } footer: {
                    Text("Puedes dejarlo vacío: el tema se mostrará como \"Tema \(number)\".")
                }
            }
            .navigationTitle("Editar tema")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { save() }
                        .disabled(!isNumberAvailable)
                }
            }
            .onAppear {
                number = topic.number
                title = topic.title ?? ""
            }
        }
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        topic.number = number
        topic.title = trimmed.isEmpty ? nil : trimmed
        topic.updatedAt = .now
        dismiss()
    }
}

struct AttemptRow: View {
    let attempt: Attempt

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(attempt.startedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.headline)
                Text(formatDuration(attempt.duration))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            HStack(spacing: 8) {
                if attempt.isHighlighted {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color.amber)
                        .accessibilityLabel("Destacado")
                }
                if attempt.recording != nil {
                    Image(systemName: "waveform")
                        .accessibilityLabel("Con grabación")
                }
                if attempt.notes?.isEmpty == false {
                    Image(systemName: "note.text")
                        .accessibilityLabel("Con notas")
                }
            }
            .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
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
    let topic = Topic(number: 42, title: "Responsabilidad patrimonial", syllabus: syllabus)
    container.mainContext.insert(topic)
    let session = PracticeSession()
    container.mainContext.insert(session)
    let attempt = Attempt(topic: topic, session: session)
    attempt.duration = 708
    attempt.isCompleted = true
    container.mainContext.insert(attempt)

    return NavigationStack {
        TopicDetailView(topic: topic)
            .navigationDestination(for: Attempt.self) { AttemptDetailView(attempt: $0) }
    }
    .modelContainer(container)
    .environment(AppEnvironment(mode: .local))
}
