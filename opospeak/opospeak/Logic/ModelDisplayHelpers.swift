//
//  ModelDisplayHelpers.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation

extension Tema: TemaSortable {
    var intentoCount: Int { intentos?.count ?? 0 }

    var ultimaPractica: Date? {
        intentos?.map(\.fechaInicio).max()
    }

    /// "Tema 42" cuando no hay título; el título cuando existe.
    var nombreVisible: String {
        if let titulo, !titulo.isEmpty { return titulo }
        return "Tema \(numero)"
    }
}

extension Temario {
    var temasActivos: [Tema] {
        temas?.filter(\.activo) ?? []
    }

    /// Fecha del intento más reciente entre todos los temas del temario.
    var actividadReciente: Date? {
        temas?.compactMap(\.ultimaPractica).max()
    }

    /// Siguiente número libre, contando también temas archivados.
    var siguienteNumeroLibre: Int {
        (temas?.map(\.numero).max() ?? 0) + 1
    }

    var numerosExistentes: Set<Int> {
        Set(temas?.map(\.numero) ?? [])
    }
}

/// Formatea segundos como "11:48" o "1:02:30".
func formatearDuracion(_ segundos: TimeInterval) -> String {
    let total = Int(segundos.rounded())
    let h = total / 3600
    let m = (total % 3600) / 60
    let s = total % 60
    return h > 0
        ? String(format: "%d:%02d:%02d", h, m, s)
        : String(format: "%d:%02d", m, s)
}
