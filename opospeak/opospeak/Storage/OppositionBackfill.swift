//
//  OppositionBackfill.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import SwiftData

/// Migración de datos pre-refactor: los temarios creados cuando Temario
/// era la raíz del dominio no tienen oposición. Este pase los adopta bajo
/// una oposición existente o una "Mi oposición" creada al vuelo.
/// Idempotente: una segunda ejecución no encuentra huérfanos.
enum OppositionBackfill {

    static var defaultName: String {
        String(localized: "Mi oposición")
    }

    @discardableResult
    static func run(context: ModelContext) -> Int {
        let syllabi = (try? context.fetch(FetchDescriptor<Syllabus>())) ?? []
        let orphans = syllabi.filter { $0.opposition == nil }
        guard !orphans.isEmpty else { return 0 }

        let existing = (try? context.fetch(
            FetchDescriptor<Opposition>(sortBy: [SortDescriptor(\.createdAt)])
        )) ?? []

        let target: Opposition
        if let first = existing.first {
            target = first
        } else {
            target = Opposition(name: defaultName)
            context.insert(target)
        }

        for syllabus in orphans {
            syllabus.opposition = target
        }
        try? context.save()
        return orphans.count
    }
}

/// Resolución de la oposición activa: la apuntada por el ajuste local del
/// dispositivo, o la primera existente. Cuál oposición está activa es
/// estado de UX local (como el flag de onboarding): NO debe sincronizar.
enum ActiveOpposition {

    static let storageKey = "activeOppositionID"

    static func resolve(in context: ModelContext) -> Opposition? {
        let oppositions = (try? context.fetch(
            FetchDescriptor<Opposition>(sortBy: [SortDescriptor(\.createdAt)])
        )) ?? []
        guard !oppositions.isEmpty else { return nil }

        if let idString = UserDefaults.standard.string(forKey: storageKey),
           let id = UUID(uuidString: idString),
           let chosen = oppositions.first(where: { $0.id == id }) {
            return chosen
        }
        return oppositions.first
    }
}
