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

    private static let schema = Schema([
        Temario.self,
        Tema.self,
        Sesion.self,
        Intento.self,
        Grabacion.self,
        Metrica.self,
        Nota.self,
    ])

    /// CloudKit primero; si el contenedor no puede inicializarse (sin sesión
    /// de iCloud, dispositivo restringido, error de contenedor), la app cae
    /// a almacenamiento local y funciona completa. Local-first nunca se
    /// compromete por la disponibilidad de la sincronización.
    private static func makeContainer() -> (ModelContainer, SyncStatus.Modo) {
        do {
            let cloud = ModelConfiguration(
                schema: schema,
                cloudKitDatabase: .private(RecordingLocation.containerIdentifier)
            )
            return (try ModelContainer(for: schema, configurations: [cloud]), .icloud)
        } catch {
            do {
                let local = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
                return (try ModelContainer(for: schema, configurations: [local]), .local)
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }

    private let sharedModelContainer: ModelContainer
    @State private var entorno: AppEnvironment

    init() {
        let (container, modo) = Self.makeContainer()
        sharedModelContainer = container
        _entorno = State(initialValue: AppEnvironment(modo: modo))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(entorno)
                .task {
                    await entorno.arrancar()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
