//
//  SesionPolicy.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation

/// Decide si un intento reutiliza una sesión existente o necesita una nueva.
/// Las sesiones son invisibles para el usuario (define-practice-session-flow):
/// se crean y cierran solas, agrupando prácticas cercanas en el tiempo.
enum SesionPolicy {

    /// Ventana de inactividad tras la cual una sesión deja de reutilizarse.
    static let ventanaReutilizacion: TimeInterval = 30 * 60

    /// Devuelve si una sesión cuya última actividad fue `ultimaActividad`
    /// sigue siendo reutilizable en el momento `ahora`.
    static func esReutilizable(
        ultimaActividad: Date,
        ahora: Date,
        ventana: TimeInterval = ventanaReutilizacion
    ) -> Bool {
        let transcurrido = ahora.timeIntervalSince(ultimaActividad)
        return transcurrido >= 0 && transcurrido <= ventana
    }
}
