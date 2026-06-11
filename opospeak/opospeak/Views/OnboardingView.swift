//
//  OnboardingView.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import SwiftUI
import SwiftData

// Primer arranque (define-onboarding-flow): no enseña la aplicación,
// lleva al usuario a su primera práctica cuanto antes. Cuatro fases con
// la jerarquía correcta — oposición (Judicatura) → temario (Civil) →
// temas — todas abandonables; lo creado en fases completadas persiste.
struct OnboardingView: View {

    /// Se invoca al completar el flujo con el temario creado, para que
    /// ContentView navegue directamente a su lista de temas.
    let onComplete: (Syllabus) -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private enum Phase {
        case welcome
        case oppositionName
        case syllabusName
        case topics
    }

    @State private var phase: Phase = .welcome
    @State private var oppositionName = ""
    @State private var syllabusName = ""
    @State private var topicCount = 25
    @State private var createdOpposition: Opposition?
    @State private var createdSyllabus: Syllabus?

    private static let oppositionExamples = ["Judicatura", "Notarías", "Inspección de Hacienda"]
    private static let syllabusExamples = ["Civil", "Penal", "Procesal"]
    private static let quickPicks = [25, 50, 100, 200, 325]

    var body: some View {
        NavigationStack {
            switch phase {
            case .welcome:
                welcomeView
            case .oppositionName:
                oppositionNameView
            case .syllabusName:
                syllabusNameView
            case .topics:
                topicsView
            }
        }
    }

    // MARK: - Fase 1: bienvenida

    private var welcomeView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "mic.circle")
                .font(.system(size: 72))
                .foregroundStyle(Color.ink)
                .accessibilityHidden(true)

            Text("OpoSpeak")
                .font(.largeTitle.bold())

            Text("Tu historial completo de práctica oral: organiza tus temas, graba tus intentos y observa tu evolución a lo largo de los años.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)

            Label("Tus datos son privados y viven en tu dispositivo.", systemImage: "lock.shield")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Spacer()

            Button {
                phase = .oppositionName
            } label: {
                Text("Empezar")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.paper)
    }

    // MARK: - Fase 2: oposición

    private var isOppositionNameValid: Bool {
        !oppositionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var oppositionNameView: some View {
        Form {
            Section {
                TextField("Nombre de tu oposición", text: $oppositionName)
                    .accessibilityLabel("Nombre de la oposición")
            } header: {
                Text("¿Qué oposición preparas?")
            } footer: {
                Text("Dentro de tu oposición organizarás tus temarios: Civil, Penal, bloques…")
            }

            Section("Sugerencias") {
                ForEach(Self.oppositionExamples, id: \.self) { example in
                    Button(example) {
                        oppositionName = example
                    }
                    .accessibilityHint("Rellena el nombre con \(example)")
                }
            }
        }
        .navigationTitle("Tu oposición")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Continuar") {
                    createOpposition()
                }
                .disabled(!isOppositionNameValid)
            }
        }
    }

    // MARK: - Fase 3: primer temario

    private var isSyllabusNameValid: Bool {
        !syllabusName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var syllabusNameView: some View {
        Form {
            Section {
                TextField("Nombre del temario", text: $syllabusName)
                    .accessibilityLabel("Nombre del temario")
            } header: {
                Text("Tu primer temario de \(oppositionName)")
            } footer: {
                Text("Solo necesitas el nombre. Podrás crear más temarios después.")
            }

            Section("Sugerencias") {
                ForEach(Self.syllabusExamples, id: \.self) { example in
                    Button(example) {
                        syllabusName = example
                    }
                    .accessibilityHint("Rellena el nombre con \(example)")
                }
            }
        }
        .navigationTitle("Crea tu temario")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Continuar") {
                    createSyllabus()
                }
                .disabled(!isSyllabusNameValid)
            }
        }
    }

    // MARK: - Fase 4: temas

    private var topicsView: some View {
        Form {
            Section {
                Stepper(value: $topicCount, in: 1...TopicBulkCreator.maxTopics) {
                    HStack {
                        Text("Temas")
                        Spacer()
                        Text("\(topicCount)").foregroundStyle(.secondary)
                    }
                }
                .accessibilityLabel("Número de temas")
                .accessibilityValue("\(topicCount)")
            } header: {
                Text("¿Cuántos temas tiene tu temario?")
            } footer: {
                Text("Se crearán como Tema 1, Tema 2… Podrás añadir títulos cuando quieras.")
            }

            Section {
                HStack {
                    ForEach(Self.quickPicks, id: \.self) { pick in
                        Button("\(pick)") {
                            topicCount = pick
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                    }
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }

            Section {
                Button {
                    createTopicsAndFinish()
                } label: {
                    Text("Crear \(topicCount) temas")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }

                Button("Prefiero añadirlos después") {
                    finish()
                }
                .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(syllabusName)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Acciones

    /// Cada artefacto se persiste al salir de su fase: si el usuario
    /// abandona después, su trabajo se conserva.
    private func createOpposition() {
        let trimmed = oppositionName.trimmingCharacters(in: .whitespacesAndNewlines)
        let opposition = Opposition(name: trimmed)
        modelContext.insert(opposition)
        createdOpposition = opposition
        phase = .syllabusName
    }

    private func createSyllabus() {
        guard let opposition = createdOpposition else { return }
        let trimmed = syllabusName.trimmingCharacters(in: .whitespacesAndNewlines)
        let syllabus = Syllabus(name: trimmed, opposition: opposition)
        modelContext.insert(syllabus)
        createdSyllabus = syllabus
        phase = .topics
    }

    private func createTopicsAndFinish() {
        guard let syllabus = createdSyllabus else { return }
        let numbers = (try? TopicBulkCreator.plan(
            existingNumbers: syllabus.existingNumbers,
            from: 1,
            to: topicCount
        )) ?? []
        for number in numbers {
            modelContext.insert(Topic(number: number, syllabus: syllabus))
        }
        finish()
    }

    private func finish() {
        guard let syllabus = createdSyllabus else {
            dismiss()
            return
        }
        try? modelContext.save()
        onComplete(syllabus)
        dismiss()
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Opposition.self, Syllabus.self, Topic.self, PracticeSession.self,
        Attempt.self, Recording.self, Metric.self, Note.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    return OnboardingView { _ in }
        .modelContainer(container)
}
