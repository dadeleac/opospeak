//
//  Sesion.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import SwiftData

/// Tipo de sesión. Se persiste como String para que la lista sea extensible
/// sin migraciones y tolere valores desconocidos de versiones futuras.
enum TipoSesion: String, CaseIterable {
    case practicaIndividual = "practica_individual"
    case preparador = "preparador"
    case simulacro = "simulacro"
}

/// Bloque de entrenamiento realizado por el opositor.
/// Las sesiones se crean y cierran automáticamente; el usuario nunca las gestiona.
@Model
final class Sesion {
    var id: UUID = UUID()
    var fechaInicio: Date = Date.now
    var fechaFin: Date?
    var tipoRaw: String = TipoSesion.practicaIndividual.rawValue
    var observaciones: String?

    // Borrar una sesión nunca borra el historial de práctica.
    @Relationship(deleteRule: .nullify, inverse: \Intento.sesion)
    var intentos: [Intento]? = []

    var tipo: TipoSesion? {
        get { TipoSesion(rawValue: tipoRaw) }
        set { if let newValue { tipoRaw = newValue.rawValue } }
    }

    init(tipo: TipoSesion = .practicaIndividual, fechaInicio: Date = .now) {
        self.id = UUID()
        self.fechaInicio = fechaInicio
        self.tipoRaw = tipo.rawValue
    }
}
