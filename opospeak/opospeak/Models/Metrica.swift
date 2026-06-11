//
//  Metrica.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import SwiftData

/// Tipo de métrica. Se persiste como String para poder añadir métricas
/// futuras (velocidad de habla, pausas, muletillas…) sin migraciones.
enum TipoMetrica: String, CaseIterable {
    case duracionTotal = "duracion_total"
    case diferenciaObjetivo = "diferencia_objetivo"
}

/// Información cuantitativa obtenida durante un intento.
/// Permite visualizar evolución; nunca evalúa conocimientos.
@Model
final class Metrica {
    var id: UUID = UUID()
    var tipoRaw: String = TipoMetrica.duracionTotal.rawValue
    var valor: Double = 0
    var fecha: Date = Date.now

    var intento: Intento?

    var tipo: TipoMetrica? {
        get { TipoMetrica(rawValue: tipoRaw) }
        set { if let newValue { tipoRaw = newValue.rawValue } }
    }

    init(intento: Intento, tipo: TipoMetrica, valor: Double, fecha: Date = .now) {
        self.id = UUID()
        self.tipoRaw = tipo.rawValue
        self.valor = valor
        self.fecha = fecha
        self.intento = intento
    }
}
