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
        Opposition.self,
        Syllabus.self,
        Topic.self,
        PracticeSession.self,
        Attempt.self,
        Recording.self,
        Metric.self,
        Note.self,
    ])

    /// CloudKit primero; si el contenedor no puede inicializarse (sin sesión
    /// de iCloud, dispositivo restringido, error de contenedor), la app cae
    /// a almacenamiento local y funciona completa. Local-first nunca se
    /// compromete por la disponibilidad de la sincronización.
    private static func makeContainer() -> (ModelContainer, SyncStatus.Mode) {
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
    @State private var appEnvironment: AppEnvironment

    init() {
        let (container, mode) = Self.makeContainer()
        sharedModelContainer = container
        _appEnvironment = State(initialValue: AppEnvironment(mode: mode))
        // Antes de que ninguna vista consulte: los temarios pre-refactor
        // sin oposición se adoptan bajo una (pase idempotente).
        OppositionBackfill.run(context: container.mainContext)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appEnvironment)
                .task {
                    await appEnvironment.bootstrap()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
