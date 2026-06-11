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
    var body: some View {
        TabView {
            Tab("Temarios", systemImage: "books.vertical") {
                NavigationStack {
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
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Temario.self, Tema.self, Sesion.self, Intento.self,
        Grabacion.self, Metrica.self, Nota.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    return ContentView()
        .modelContainer(container)
}
