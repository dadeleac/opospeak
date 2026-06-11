//
//  Metric.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import SwiftData

/// Tipo de métrica. Se persiste como String para poder añadir métricas
/// futuras (velocidad de habla, pausas, muletillas…) sin migraciones.
/// Los raw values son contrato de datos (export v2): no traducir.
enum MetricKind: String, CaseIterable {
    case totalDuration = "duracion_total"
    case targetDelta = "diferencia_objetivo"
}

/// Métrica: información cuantitativa obtenida durante un intento.
/// Permite visualizar evolución; nunca evalúa conocimientos.
@Model
final class Metric {
    var id: UUID = UUID()
    var kindRaw: String = MetricKind.totalDuration.rawValue
    var value: Double = 0
    var date: Date = Date.now

    var attempt: Attempt?

    var kind: MetricKind? {
        get { MetricKind(rawValue: kindRaw) }
        set { if let newValue { kindRaw = newValue.rawValue } }
    }

    init(attempt: Attempt, kind: MetricKind, value: Double, date: Date = .now) {
        self.id = UUID()
        self.kindRaw = kind.rawValue
        self.value = value
        self.date = date
        self.attempt = attempt
    }
}
