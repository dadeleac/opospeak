//
//  ProgressOverviewView.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import SwiftUI
import SwiftData

// Vista editorial, no panel de control: hechos, sin juicios ni rachas
// (define-progress-and-history-model).
struct ProgressOverviewView: View {
    @Query(sort: \Opposition.createdAt) private var oppositions: [Opposition]
    @Query private var attempts: [Attempt]
    @Query(filter: #Predicate<Topic> { $0.isActive }) private var topics: [Topic]

    private var activeOpposition: Opposition? {
        if let idString = UserDefaults.standard.string(forKey: ActiveOpposition.storageKey),
           let id = UUID(uuidString: idString),
           let chosen = oppositions.first(where: { $0.id == id }) {
            return chosen
        }
        return oppositions.first
    }

    // El progreso se calcula sobre la oposición activa: con una sola
    // oposición es idéntico al global, pero la semántica queda correcta.
    private var activeTopics: [Topic] {
        guard let active = activeOpposition else { return [] }
        return topics.filter { $0.syllabus?.opposition?.id == active.id }
    }

    private var activeAttempts: [Attempt] {
        guard let active = activeOpposition else { return [] }
        return attempts.filter { $0.topic?.syllabus?.opposition?.id == active.id }
    }

    private var summary: ProgressSummary {
        ProgressSummary(
            attempts: activeAttempts.map {
                .init(date: $0.startedAt, duration: $0.duration, topicID: $0.topic?.id ?? UUID())
            },
            topicIDs: activeTopics.map(\.id)
        )
    }

    private func topic(with id: UUID) -> Topic? {
        activeTopics.first { $0.id == id }
    }

    var body: some View {
        List {
            if summary.hasActivity {
                Section("Volumen") {
                    LabeledContent("Intentos", value: "\(summary.totalAttempts)")
                    LabeledContent("Tiempo acumulado", value: formatDuration(summary.totalTime))
                    LabeledContent("Temas trabajados", value: "\(summary.topicsWorked)")
                    LabeledContent("Días con práctica", value: "\(summary.activeDays)")
                }
                Section("Consistencia") {
                    LabeledContent("Últimos 7 días", value: "\(summary.daysPracticedLast7) días con práctica")
                    LabeledContent("Últimos 30 días", value: "\(summary.daysPracticedLast30) días con práctica")
                }
                Section("Cobertura") {
                    LabeledContent("Temas practicados", value: "\(summary.practicedTopics) de \(summary.totalTopics)")
                    LabeledContent("Sin practicar todavía", value: "\(summary.neverPracticedTopics)")
                }
                Section("Distribución") {
                    if let most = summary.mostPracticedTopic, let topic = topic(with: most.topicID) {
                        LabeledContent("Más practicado") {
                            Text("\(topic.displayName) · \(most.attempts) intentos")
                        }
                    }
                    if let least = summary.leastPracticedTopic, let topic = topic(with: least.topicID) {
                        LabeledContent("Menos practicado") {
                            Text("\(topic.displayName) · \(least.attempts) intentos")
                        }
                    }
                }
            }
        }
        .editorialBackground()
        .navigationTitle("Progreso")
        .overlay {
            if !summary.hasActivity {
                ContentUnavailableView {
                    Label("Todavía sin progreso", systemImage: "chart.line.uptrend.xyaxis")
                } description: {
                    Text("Tu progreso aparecerá aquí a medida que practiques tus temas. Empieza desde la pestaña Temarios.")
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
    return NavigationStack {
        ProgressOverviewView()
    }
    .modelContainer(container)
}
