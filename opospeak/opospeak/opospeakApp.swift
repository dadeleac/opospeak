//
//  opospeakApp.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import SwiftUI
import SwiftData

@main
struct opospeakApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Temario.self,
            Tema.self,
            Sesion.self,
            Intento.self,
            Grabacion.self,
            Metrica.self,
            Nota.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
