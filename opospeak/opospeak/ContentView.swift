//
//  ContentView.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import SwiftUI
import SwiftData

// Shell de navegación: tres pestañas estables (define-information-architecture).
// La práctica no es pestaña: nace siempre desde el tema.
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("onboardingCompletado") private var onboardingCompletado = false

    @State private var rutaTemarios = NavigationPath()
    @State private var mostrandoOnboarding = false

    var body: some View {
        TabView {
            Tab("Temarios", systemImage: "books.vertical") {
                NavigationStack(path: $rutaTemarios) {
                    TemariosListView()
                }
            }
            Tab("Progreso", systemImage: "chart.line.uptrend.xyaxis") {
                NavigationStack {
                    ProgresoView()
                }
            }
            Tab("Ajustes", systemImage: "gearshape") {
                NavigationStack {
                    AjustesView()
                }
            }
        }
        .task {
            evaluarOnboarding()
        }
        .fullScreenCover(isPresented: $mostrandoOnboarding) {
            // Cerrar de cualquier forma termina el onboarding para siempre;
            // los estados vacíos toman el relevo (onboarding continuo).
            onboardingCompletado = true
        } content: {
            OnboardingView { temario in
                rutaTemarios.append(temario)
            }
        }
    }

    private func evaluarOnboarding() {
        var oposiciones = FetchDescriptor<Oposicion>()
        oposiciones.fetchLimit = 1
        var temarios = FetchDescriptor<Temario>()
        temarios.fetchLimit = 1
        let tieneDatos = ((try? modelContext.fetchCount(oposiciones)) ?? 0) > 0
            || ((try? modelContext.fetchCount(temarios)) ?? 0) > 0

        switch OnboardingDecision.debeMostrarse(
            completado: onboardingCompletado,
            tieneDatos: tieneDatos
        ) {
        case .mostrar:
            mostrandoOnboarding = true
        case .omitirYMarcar:
            // Datos restaurados (p. ej. iCloud en dispositivo nuevo):
            // un usuario que vuelve no es un usuario nuevo.
            onboardingCompletado = true
        case .omitir:
            break
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Oposicion.self, Temario.self, Tema.self, Sesion.self, Intento.self,
        Grabacion.self, Metrica.self, Nota.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    return ContentView()
        .modelContainer(container)
        .environment(AppEnvironment(modo: .local))
}
