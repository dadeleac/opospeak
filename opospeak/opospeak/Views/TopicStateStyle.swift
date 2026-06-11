//
//  TopicStateStyle.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import SwiftUI

/// Presentación única de los estados del tema. La semántica vive en
/// TopicInsightsModel; su presentación (etiqueta, icono, color y
/// explicación) vive aquí y solo aquí — Ficha, tarjeta de Vuelta, mapa
/// y leyenda consumen lo mismo. Siempre icono + texto: el color nunca
/// es la única señal. Olvidado es Amber (atención), deliberadamente
/// nunca rojo: el olvido es tiempo, no juicio.
struct TopicStateStyle {
    let label: String
    let icon: String
    let color: Color
    /// La frase de una línea de la fundación.
    let explanation: String
    /// Reciente destaca como matiz dentro de "Al día".
    let emphasized: Bool

    // Tres estados visibles sobre cuatro internos: "Al día" absorbe
    // "Reciente" (que conserva un matiz visual: icono relleno y tinte
    // más intenso). "Necesita repaso" habla de tiempo relativo al ritmo
    // propio — necesidad temporal, jamás mérito.
    init(_ state: TopicState) {
        switch state {
        case .pending:
            label = String(localized: "Sin practicar")
            icon = "circle.dashed"
            color = .slate
            explanation = String(localized: "Todavía no lo has cantado.")
            emphasized = false
        case .recent:
            label = String(localized: "Al día")
            icon = "checkmark.circle.fill"
            color = .sage
            explanation = String(localized: "Lo cantaste esta semana.")
            emphasized = true
        case .current:
            label = String(localized: "Al día")
            icon = "checkmark.circle"
            color = .sage
            explanation = String(localized: "Dentro de tu ritmo habitual.")
            emphasized = false
        case .forgotten:
            label = String(localized: "Necesita repaso")
            icon = "clock.arrow.circlepath"
            color = .amber
            explanation = String(localized: "Llevas más del doble de tu ritmo sin cantarlo.")
            emphasized = false
        }
    }

    /// Intensidad del tinte en el mapa: reciente destaca dentro de "Al día".
    var mapTintOpacity: Double {
        emphasized ? 0.45 : 0.25
    }
}
