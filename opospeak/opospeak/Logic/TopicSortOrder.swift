//
//  TopicSortOrder.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation

/// Abstracción mínima para ordenar temas sin depender de SwiftData,
/// de forma que la ordenación sea testable con datos planos.
protocol TopicSortable {
    var number: Int { get }
    var attemptCount: Int { get }
    var lastPracticedAt: Date? { get }
}

/// Órdenes de la lista de temas definidos en define-topic-management-flow.
enum TopicSortOrder: String, CaseIterable, Identifiable {
    case natural
    case mostPracticed
    case leastPracticed
    case recentlyPracticed
    case pending

    var id: String { rawValue }

    var title: String {
        switch self {
        case .natural: String(localized: "Orden del temario")
        case .mostPracticed: String(localized: "Más practicados")
        case .leastPracticed: String(localized: "Menos practicados")
        case .recentlyPracticed: String(localized: "Últimos practicados")
        case .pending: String(localized: "Pendientes de práctica")
        }
    }

    func sort<T: TopicSortable>(_ topics: [T]) -> [T] {
        switch self {
        case .natural:
            topics.sorted { $0.number < $1.number }
        case .mostPracticed:
            topics.sorted {
                $0.attemptCount != $1.attemptCount
                    ? $0.attemptCount > $1.attemptCount
                    : $0.number < $1.number
            }
        case .leastPracticed:
            topics.sorted {
                $0.attemptCount != $1.attemptCount
                    ? $0.attemptCount < $1.attemptCount
                    : $0.number < $1.number
            }
        case .recentlyPracticed:
            topics.sorted {
                switch ($0.lastPracticedAt, $1.lastPracticedAt) {
                case let (a?, b?): a != b ? a > b : $0.number < $1.number
                case (_?, nil): true
                case (nil, _?): false
                case (nil, nil): $0.number < $1.number
                }
            }
        case .pending:
            topics.sorted {
                let aPending = $0.attemptCount == 0
                let bPending = $1.attemptCount == 0
                return aPending != bPending ? aPending : $0.number < $1.number
            }
        }
    }
}
