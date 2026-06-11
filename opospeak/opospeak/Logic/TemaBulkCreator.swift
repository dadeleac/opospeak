//
//  TemaBulkCreator.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation

/// Planifica el alta rápida de temas ("crear temas del 1 al N").
/// Lógica pura: decide qué números crear; la persistencia es del llamante.
enum TemaBulkCreator {

    enum BulkError: Error, Equatable {
        case inicioInvalido
        case rangoInvalido
        case rangoDemasiadoGrande
    }

    static let maximoTemas = 1000

    /// Números a crear en el rango [desde, hasta], saltando los ya existentes.
    static func plan(existingNumbers: Set<Int>, desde: Int, hasta: Int) throws -> [Int] {
        guard desde >= 1 else { throw BulkError.inicioInvalido }
        guard hasta >= desde else { throw BulkError.rangoInvalido }
        guard hasta - desde + 1 <= maximoTemas else { throw BulkError.rangoDemasiadoGrande }

        return (desde...hasta).filter { !existingNumbers.contains($0) }
    }
}
