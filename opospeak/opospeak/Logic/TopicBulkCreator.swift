//
//  TopicBulkCreator.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation

/// Planifica el alta rápida de temas ("crear temas del 1 al N").
/// Lógica pura: decide qué números crear; la persistencia es del llamante.
enum TopicBulkCreator {

    enum BulkError: Error, Equatable {
        case invalidStart
        case invalidRange
        case rangeTooLarge
    }

    static let maxTopics = 1000

    /// Números a crear en el rango [from, to], saltando los ya existentes.
    static func plan(existingNumbers: Set<Int>, from: Int, to: Int) throws -> [Int] {
        guard from >= 1 else { throw BulkError.invalidStart }
        guard to >= from else { throw BulkError.invalidRange }
        guard to - from + 1 <= maxTopics else { throw BulkError.rangeTooLarge }

        return (from...to).filter { !existingNumbers.contains($0) }
    }
}
