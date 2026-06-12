//
//  SyllabusDetailView.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import SwiftUI
import SwiftData

struct SyllabusDetailView: View {
    let syllabus: Syllabus

    @State private var searchText = ""
    @State private var sortOrder: TopicSortOrder = .natural
    @State private var showingNewTopic = false
    @State private var showingBulkCreation = false
    @State private var showingEdit = false
    @State private var topicToDelete: Topic?

    @Environment(\.modelContext) private var modelContext
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.dismiss) private var dismiss

    private var visibleTopics: [Topic] {
        var topics = syllabus.activeTopics
        if !searchText.isEmpty {
            topics = topics.filter { topic in
                String(topic.number).contains(searchText)
                    || (topic.title ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
        return sortOrder.sort(topics)
    }

    var body: some View {
        List {
            ForEach(visibleTopics) { topic in
                NavigationLink(value: topic) {
                    TopicRow(topic: topic)
                }
                .swipeActions(edge: .trailing) {
                    // Eliminar con alerta (destruye audio); archivar
                    // directo (conserva el historial). El coste dicta
                    // la fricción.
                    Button(role: .destructive) {
                        topicToDelete = topic
                    } label: {
                        Label("Eliminar", systemImage: "trash")
                    }
                    Button {
                        archive(topic)
                    } label: {
                        Label("Archivar", systemImage: "archivebox")
                    }
                    .tint(.amber)
                }
            }
        }
        .editorialBackground()
        .navigationTitle(syllabus.name)
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Buscar por número o título"
        )
        .toolbar {
            ToolbarItem(placement: .secondaryAction) {
                Picker("Ordenar", selection: $sortOrder) {
                    ForEach(TopicSortOrder.allCases) { order in
                        Text(order.title).tag(order)
                    }
                }
                .pickerStyle(.menu)
            }
            ToolbarItem(placement: .secondaryAction) {
                Button {
                    showingEdit = true
                } label: {
                    Label("Editar temario", systemImage: "pencil")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showingNewTopic = true
                    } label: {
                        Label("Añadir tema", systemImage: "plus")
                    }
                    Button {
                        showingBulkCreation = true
                    } label: {
                        Label("Crear temas del 1 al N", systemImage: "list.number")
                    }
                } label: {
                    Label("Añadir", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingNewTopic) {
            NewTopicSheet(syllabus: syllabus)
        }
        .sheet(isPresented: $showingEdit) {
            EditSyllabusSheet(syllabus: syllabus) {
                showingEdit = false
                dismiss()
            }
        }
        .alert(
            "¿Eliminar este tema?",
            isPresented: Binding(
                get: { topicToDelete != nil },
                set: { if !$0 { topicToDelete = nil } }
            )
        ) {
            Button("Eliminar tema", role: .destructive) {
                deleteTopic()
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text(topicDeletionMessage)
        }
        .sheet(isPresented: $showingBulkCreation) {
            BulkTopicsSheet(syllabus: syllabus)
        }
        .overlay {
            if syllabus.activeTopics.isEmpty {
                ContentUnavailableView {
                    Label("Sin temas", systemImage: "list.bullet")
                } description: {
                    Text("Añade tus temas para empezar a practicar.")
                } actions: {
                    Button("Añadir tema") { showingNewTopic = true }
                        .buttonStyle(.borderedProminent)
                    Button("Crear temas del 1 al N") { showingBulkCreation = true }
                }
            } else if visibleTopics.isEmpty {
                ContentUnavailableView.search(text: searchText)
            }
        }
    }

    private func archive(_ topic: Topic) {
        topic.isActive = false
        topic.updatedAt = .now
    }

    /// La alerta dice la escala real: el usuario confirma sabiendo qué pierde.
    private var topicDeletionMessage: String {
        let count = topicToDelete?.attempts?.count ?? 0
        switch count {
        case 0:
            return String(localized: "No se puede deshacer.")
        case 1:
            return String(localized: "Se eliminará 1 intento con su grabación y notas. No se puede deshacer.")
        default:
            return String(localized: "Se eliminarán \(count) intentos con sus grabaciones y notas. No se puede deshacer.")
        }
    }

    /// Siempre vía el punto único: los audios de debajo mueren con el tema.
    private func deleteTopic() {
        guard let topic = topicToDelete else { return }
        topicToDelete = nil
        let repository = PracticeRepository(
            modelContext: modelContext,
            recordingStore: environment.recordingStore
        )
        try? repository.delete(topic: topic)
    }
}

/// Edición del temario: renombrar y, al final, la acción destructiva
/// sobre el objeto editado (patrón HIG). Eliminar pide confirmación con
/// la escala real y pasa por el punto único: los audios mueren con el
/// temario. Archivar sigue siendo la alternativa que conserva.
struct EditSyllabusSheet: View {
    let syllabus: Syllabus
    var onDelete: () -> Void = {}

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppEnvironment.self) private var environment

    @State private var name = ""
    @State private var confirmingDeletion = false

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var attemptCount: Int {
        (syllabus.topics ?? []).reduce(0) { $0 + ($1.attempts?.count ?? 0) }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nombre", text: $name)
                        .accessibilityLabel("Nombre del temario")
                }
                Section {
                    Button("Eliminar temario", role: .destructive) {
                        confirmingDeletion = true
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Editar temario")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { save() }
                        .disabled(trimmedName.isEmpty)
                }
            }
            .alert("¿Eliminar este temario?", isPresented: $confirmingDeletion) {
                Button("Eliminar temario", role: .destructive) {
                    deleteSyllabus()
                }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text(deletionMessage)
            }
            .onAppear {
                name = syllabus.name
            }
        }
    }

    private var deletionMessage: String {
        let topics = (syllabus.topics ?? []).count
        let attempts = attemptCount
        if topics == 0 {
            return String(localized: "No se puede deshacer.")
        }
        return String(localized: "Se eliminarán sus \(topics) temas y \(attempts) intentos con sus grabaciones. No se puede deshacer.")
    }

    private func save() {
        syllabus.name = trimmedName
        syllabus.updatedAt = .now
        dismiss()
    }

    private func deleteSyllabus() {
        let repository = PracticeRepository(
            modelContext: modelContext,
            recordingStore: environment.recordingStore
        )
        try? repository.delete(syllabus: syllabus)
        onDelete()
    }
}

private struct TopicRow: View {
    let topic: Topic

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(topic.displayName)
                    .font(.headline)
                if topic.title?.isEmpty == false {
                    Text("Tema \(topic.number)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            HStack(spacing: 12) {
                Text("\(topic.attemptCount) intentos")
                if let date = topic.lastPracticedAt {
                    Text("Último: \(date.formatted(date: .abbreviated, time: .omitted))")
                } else {
                    Text("Sin practicar")
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}

struct NewTopicSheet: View {
    let syllabus: Syllabus

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var number: Int = 1
    @State private var title = ""

    private var isNumberAvailable: Bool {
        !syllabus.existingNumbers.contains(number)
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
                        Text("Ya existe un tema con el número \(number).")
                    }
                }
                Section("Opcional") {
                    TextField("Título", text: $title)
                        .accessibilityLabel("Título del tema")
                }
            }
            .navigationTitle("Nuevo tema")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Crear") { create() }
                        .disabled(!isNumberAvailable)
                }
            }
            .onAppear {
                number = syllabus.nextFreeNumber
            }
        }
    }

    private func create() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let topic = Topic(number: number, title: trimmed.isEmpty ? nil : trimmed, syllabus: syllabus)
        modelContext.insert(topic)
        dismiss()
    }
}

struct BulkTopicsSheet: View {
    let syllabus: Syllabus

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var from = 1
    @State private var to = 25

    private var numbersToCreate: [Int] {
        (try? TopicBulkCreator.plan(
            existingNumbers: syllabus.existingNumbers,
            from: from,
            to: to
        )) ?? []
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Stepper(value: $from, in: 1...9999) {
                        HStack {
                            Text("Desde")
                            Spacer()
                            Text("\(from)").foregroundStyle(.secondary)
                        }
                    }
                    .accessibilityLabel("Primer número")
                    .accessibilityValue("\(from)")
                    Stepper(value: $to, in: 1...9999) {
                        HStack {
                            Text("Hasta")
                            Spacer()
                            Text("\(to)").foregroundStyle(.secondary)
                        }
                    }
                    .accessibilityLabel("Último número")
                    .accessibilityValue("\(to)")
                } footer: {
                    Text(summaryText)
                }
            }
            .navigationTitle("Alta rápida")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Crear \(numbersToCreate.count)") { create() }
                        .disabled(numbersToCreate.isEmpty)
                }
            }
        }
    }

    private var summaryText: String {
        if to < from {
            return String(localized: "El rango no es válido.")
        }
        let existing = (to - from + 1) - numbersToCreate.count
        if existing > 0 {
            return String(localized: "Se crearán \(numbersToCreate.count) temas. Se omiten \(existing) que ya existen.")
        }
        return String(localized: "Se crearán \(numbersToCreate.count) temas sin título: Tema \(from) … Tema \(to).")
    }

    private func create() {
        for number in numbersToCreate {
            modelContext.insert(Topic(number: number, syllabus: syllabus))
        }
        dismiss()
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
    container.mainContext.insert(Topic(number: 1, syllabus: syllabus))
    container.mainContext.insert(Topic(number: 2, title: "La Constitución", syllabus: syllabus))

    return NavigationStack {
        SyllabusDetailView(syllabus: syllabus)
            .navigationDestination(for: Topic.self) { TopicDetailView(topic: $0) }
    }
    .modelContainer(container)
    .environment(AppEnvironment(mode: .local))
}
