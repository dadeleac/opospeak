//
//  TopicDetailView.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import SwiftUI
import SwiftData

// Centro de gravedad de la aplicación (define-information-architecture):
// info del tema, historial de intentos y la acción Practicar prominente.
struct TopicDetailView: View {
    let topic: Topic

    @State private var practicing = false
    @State private var editing = false

    private var sortedAttempts: [Attempt] {
        (topic.attempts ?? []).sorted { $0.startedAt > $1.startedAt }
    }

    var body: some View {
        List {
            Section {
                Button {
                    practicing = true
                } label: {
                    Label("Practicar", systemImage: "mic.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .accessibilityHint("Inicia la grabación de una práctica oral de este tema")
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
        .overlay {
            if sortedAttempts.isEmpty {
                ContentUnavailableView {
                    Label("Sin intentos", systemImage: "mic")
                } description: {
                    Text("Cuando practiques este tema, tu historial aparecerá aquí.")
                }
                .allowsHitTesting(false)
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
