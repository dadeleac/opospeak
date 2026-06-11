//
//  SessionPolicy.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation

/// Decide si un intento reutiliza una sesión existente o necesita una nueva.
/// Las sesiones son invisibles para el usuario (define-practice-session-flow):
/// se crean y cierran solas, agrupando prácticas cercanas en el tiempo.
enum SessionPolicy {

    /// Ventana de inactividad tras la cual una sesión deja de reutilizarse.
    static let reuseWindow: TimeInterval = 30 * 60

    /// Devuelve si una sesión cuya última actividad fue `lastActivity`
    /// sigue siendo reutilizable en el momento `now`.
    static func isReusable(
        lastActivity: Date,
        now: Date,
        window: TimeInterval = reuseWindow
    ) -> Bool {
        let elapsed = now.timeIntervalSince(lastActivity)
        return elapsed >= 0 && elapsed <= window
    }
}
