//
//  SyllabusListView.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import SwiftUI
import SwiftData

// Temarios de la oposición activa. El título de navegación es el nombre
// de la oposición (Judicatura arriba, sus temarios debajo): la jerarquía
// Oposición → Temarios → Temas se lee tal cual.
struct SyllabusListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Opposition.createdAt)
    private var oppositions: [Opposition]
    @Query(filter: #Predicate<Syllabus> { $0.isActive }, sort: \Syllabus.createdAt)
    private var syllabi: [Syllabus]

    @State private var showingCreation = false

    private var activeOpposition: Opposition? {
        if let idString = UserDefaults.standard.string(forKey: ActiveOpposition.storageKey),
           let id = UUID(uuidString: idString),
           let chosen = oppositions.first(where: { $0.id == id }) {
            return chosen
        }
        return oppositions.first
    }

    private var visibleSyllabi: [Syllabus] {
        guard let active = activeOpposition else { return [] }
        return syllabi.filter { $0.opposition?.id == active.id }
    }

    var body: some View {
        List {
            ForEach(visibleSyllabi) { syllabus in
                NavigationLink(value: syllabus) {
                    SyllabusRow(syllabus: syllabus)
                }
                .swipeActions(edge: .trailing) {
                    Button {
                        archive(syllabus)
                    } label: {
                        Label("Archivar", systemImage: "archivebox")
                    }
                    .tint(.amber)
                }
            }
        }
        .editorialBackground()
        .navigationTitle(activeOpposition?.name ?? String(localized: "Temarios"))
        .navigationDestination(for: Syllabus.self) { syllabus in
            SyllabusDetailView(syllabus: syllabus)
        }
        .navigationDestination(for: Topic.self) { topic in
            TopicDetailView(topic: topic)
        }
        .navigationDestination(for: Attempt.self) { attempt in
            AttemptDetailView(attempt: attempt)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingCreation = true
                } label: {
                    Label("Crear temario", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingCreation) {
            NewSyllabusSheet(opposition: activeOpposition)
        }
        .overlay {
            if visibleSyllabi.isEmpty {
                ContentUnavailableView {
                    Label("Sin temarios", systemImage: "books.vertical")
                } description: {
                    Text("Crea tu primer temario — por ejemplo Civil, Penal o Bloque I — para organizar tus temas.")
                } actions: {
                    Button("Crear temario") {
                        showingCreation = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }

    private func archive(_ syllabus: Syllabus) {
        syllabus.isActive = false
        syllabus.updatedAt = .now
    }
}

private struct SyllabusRow: View {
    let syllabus: Syllabus

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(syllabus.name)
                .font(.headline)
            HStack(spacing: 12) {
                Text("\(syllabus.activeTopics.count) temas")
                if let date = syllabus.recentActivity {
                    Text("Última práctica \(date.formatted(date: .abbreviated, time: .omitted))")
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}

struct NewSyllabusSheet: View {
    /// Oposición destino; si aún no existe ninguna (caso límite: onboarding
    /// descartado), se crea una por defecto al guardar.
    let opposition: Opposition?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var summary = ""

    private var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nombre", text: $name)
                        .accessibilityLabel("Nombre del temario")
                } header: {
                    if let opposition {
                        Text("Nuevo temario de \(opposition.name)")
                    }
                } footer: {
                    Text("Por ejemplo: Civil, Penal, Procesal, Bloque I.")
                }
                Section("Opcional") {
                    TextField("Descripción", text: $summary, axis: .vertical)
                        .accessibilityLabel("Descripción del temario")
                }
            }
            .navigationTitle("Nuevo temario")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Crear") { create() }
                        .disabled(!isNameValid)
                }
            }
        }
    }

    private func create() {
        let target: Opposition
        if let opposition {
            target = opposition
        } else {
            target = Opposition(name: OppositionBackfill.defaultName)
            modelContext.insert(target)
        }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSummary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        let syllabus = Syllabus(
            name: trimmedName,
            summary: trimmedSummary.isEmpty ? nil : trimmedSummary,
            opposition: target
        )
        modelContext.insert(syllabus)
        dismiss()
    }
}

#Preview("Con temarios") {
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

    return NavigationStack {
        SyllabusListView()
    }
    .modelContainer(container)
    .environment(AppEnvironment(mode: .local))
}

#Preview("Vacío") {
    let container = try! ModelContainer(
        for: Opposition.self, Syllabus.self, Topic.self, PracticeSession.self,
        Attempt.self, Recording.self, Metric.self, Note.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    return NavigationStack {
        SyllabusListView()
    }
    .modelContainer(container)
    .environment(AppEnvironment(mode: .local))
}
