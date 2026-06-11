//
//  OposicionBackfill.swift
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
enum OposicionBackfill {

    static let nombrePorDefecto = "Mi oposición"

    @discardableResult
    static func run(context: ModelContext) -> Int {
        let temarios = (try? context.fetch(FetchDescriptor<Temario>())) ?? []
        let huerfanos = temarios.filter { $0.oposicion == nil }
        guard !huerfanos.isEmpty else { return 0 }

        let existentes = (try? context.fetch(
            FetchDescriptor<Oposicion>(sortBy: [SortDescriptor(\.fechaCreacion)])
        )) ?? []

        let destino: Oposicion
        if let primera = existentes.first {
            destino = primera
        } else {
            destino = Oposicion(nombre: nombrePorDefecto)
            context.insert(destino)
        }

        for temario in huerfanos {
            temario.oposicion = destino
        }
        try? context.save()
        return huerfanos.count
    }
}

/// Resolución de la oposición activa: la apuntada por el ajuste local del
/// dispositivo, o la primera existente. Cuál oposición está activa es
/// estado de UX local (como el flag de onboarding): NO debe sincronizar.
enum OposicionActiva {

    static let storageKey = "oposicionActivaId"

    static func resolver(en context: ModelContext) -> Oposicion? {
        let oposiciones = (try? context.fetch(
            FetchDescriptor<Oposicion>(sortBy: [SortDescriptor(\.fechaCreacion)])
        )) ?? []
        guard !oposiciones.isEmpty else { return nil }

        if let idString = UserDefaults.standard.string(forKey: storageKey),
           let id = UUID(uuidString: idString),
           let elegida = oposiciones.first(where: { $0.id == id }) {
            return elegida
        }
        return oposiciones.first
    }
}
