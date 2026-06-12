//
//  ContentView.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import SwiftUI
import SwiftData

// Empuje programático de un tema en el stack de Temarios. Las vistas que
// navegan desde botones (mapa del Estado, Siguiente, peek) usan esto en
// vez de navigationDestination(item:): un destino item: dentro del stack
// compite con los destinos por valor del root y rompe la navegación
// posterior (p. ej. Ficha → intento volvía a empujar la propia Ficha).
extension EnvironmentValues {
    @Entry var pushTopic: (Topic) -> Void = { _ in }
}

// Shell de navegación: tres pestañas estables (define-information-architecture).
// La práctica no es pestaña: nace siempre desde el tema.
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false

    @State private var syllabusPath = NavigationPath()
    @State private var showingOnboarding = false

    var body: some View {
        TabView {
            Tab("Temarios", systemImage: "books.vertical") {
                NavigationStack(path: $syllabusPath) {
                    SyllabusListView()
                }
                .environment(\.pushTopic) { syllabusPath.append($0) }
            }
            Tab("Progreso", systemImage: "chart.line.uptrend.xyaxis") {
                NavigationStack {
                    ProgressOverviewView()
                }
            }
            Tab("Ajustes", systemImage: "gearshape") {
                NavigationStack {
                    SettingsView()
                }
            }
        }
        .task {
            evaluateOnboarding()
        }
        .fullScreenCover(isPresented: $showingOnboarding) {
            // Cerrar de cualquier forma termina el onboarding para siempre;
            // los estados vacíos toman el relevo (onboarding continuo).
            onboardingCompleted = true
        } content: {
            OnboardingView { syllabus in
                syllabusPath.append(syllabus)
            }
        }
    }

    private func evaluateOnboarding() {
        var oppositions = FetchDescriptor<Opposition>()
        oppositions.fetchLimit = 1
        var syllabi = FetchDescriptor<Syllabus>()
        syllabi.fetchLimit = 1
        let hasData = ((try? modelContext.fetchCount(oppositions)) ?? 0) > 0
            || ((try? modelContext.fetchCount(syllabi)) ?? 0) > 0

        switch OnboardingDecision.shouldShow(
            completed: onboardingCompleted,
            hasData: hasData
        ) {
        case .show:
            showingOnboarding = true
        case .skipAndMark:
            // Datos restaurados (p. ej. iCloud en dispositivo nuevo):
            // un usuario que vuelve no es un usuario nuevo.
            onboardingCompleted = true
        case .skip:
            break
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Opposition.self, Syllabus.self, Topic.self, PracticeSession.self,
        Attempt.self, Recording.self, Metric.self, Note.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    return ContentView()
        .modelContainer(container)
        .environment(AppEnvironment(mode: .local))
}
