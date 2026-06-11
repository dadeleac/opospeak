//
//  OnboardingDecision.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation

/// Decide si el flujo de primer arranque debe mostrarse. Un usuario con
/// datos restaurados por iCloud en un dispositivo nuevo NO es un usuario
/// nuevo: se omite y se marca como completado en silencio.
enum OnboardingDecision: Equatable {
    case show
    case skip
    case skipAndMark

    /// `hasData`: existe alguna oposición (o temarios pre-refactor).
    static func shouldShow(completed: Bool, hasData: Bool) -> OnboardingDecision {
        if completed { return .skip }
        if hasData { return .skipAndMark }
        return .show
    }
}
