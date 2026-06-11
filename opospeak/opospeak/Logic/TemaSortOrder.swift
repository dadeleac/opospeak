//
//  TemaSortOrder.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation

/// Abstracción mínima para ordenar temas sin depender de SwiftData,
/// de forma que la ordenación sea testable con datos planos.
protocol TemaSortable {
    var numero: Int { get }
    var intentoCount: Int { get }
    var ultimaPractica: Date? { get }
}

/// Órdenes de la lista de temas definidos en define-topic-management-flow.
enum TemaSortOrder: String, CaseIterable, Identifiable {
    case natural
    case masPracticados
    case menosPracticados
    case ultimosPracticados
    case pendientes

    var id: String { rawValue }

    var titulo: String {
        switch self {
        case .natural: "Orden del temario"
        case .masPracticados: "Más practicados"
        case .menosPracticados: "Menos practicados"
        case .ultimosPracticados: "Últimos practicados"
        case .pendientes: "Pendientes de práctica"
        }
    }

    func sort<T: TemaSortable>(_ temas: [T]) -> [T] {
        switch self {
        case .natural:
            temas.sorted { $0.numero < $1.numero }
        case .masPracticados:
            temas.sorted {
                $0.intentoCount != $1.intentoCount
                    ? $0.intentoCount > $1.intentoCount
                    : $0.numero < $1.numero
            }
        case .menosPracticados:
            temas.sorted {
                $0.intentoCount != $1.intentoCount
                    ? $0.intentoCount < $1.intentoCount
                    : $0.numero < $1.numero
            }
        case .ultimosPracticados:
            temas.sorted {
                switch ($0.ultimaPractica, $1.ultimaPractica) {
                case let (a?, b?): a != b ? a > b : $0.numero < $1.numero
                case (_?, nil): true
                case (nil, _?): false
                case (nil, nil): $0.numero < $1.numero
                }
            }
        case .pendientes:
            temas.sorted {
                let aPendiente = $0.intentoCount == 0
                let bPendiente = $1.intentoCount == 0
                return aPendiente != bPendiente ? aPendiente : $0.numero < $1.numero
            }
        }
    }
}
