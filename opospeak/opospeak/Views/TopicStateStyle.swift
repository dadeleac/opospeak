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

    init(_ state: TopicState) {
        switch state {
        case .pending:
            label = String(localized: "Pendiente")
            icon = "circle.dashed"
            color = .slate
            explanation = String(localized: "Todavía no lo has cantado.")
        case .recent:
            label = String(localized: "Reciente")
            icon = "checkmark.circle"
            color = .sage
            explanation = String(localized: "Lo cantaste esta semana.")
        case .current:
            label = String(localized: "Al día")
            icon = "clock"
            color = .slate
            explanation = String(localized: "Dentro de tu ritmo habitual.")
        case .forgotten:
            label = String(localized: "Olvidado")
            icon = "clock.arrow.circlepath"
            color = .amber
            explanation = String(localized: "Llevas más del doble de tu ritmo sin cantarlo.")
        }
    }
}
