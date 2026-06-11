//
//  PracticeSession.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import SwiftData

/// Tipo de sesión. Se persiste como String para que la lista sea extensible
/// sin migraciones y tolere valores desconocidos de versiones futuras.
/// Los raw values son contrato de datos (export v2): no traducir.
enum SessionKind: String, CaseIterable {
    case soloPractice = "practica_individual"
    case withTrainer = "preparador"
    case mockExam = "simulacro"
}

/// Sesión: bloque de entrenamiento realizado por el opositor.
/// Las sesiones se crean y cierran automáticamente; el usuario nunca
/// las gestiona.
@Model
final class PracticeSession {
    var id: UUID = UUID()
    var startedAt: Date = Date.now
    var endedAt: Date?
    var kindRaw: String = SessionKind.soloPractice.rawValue
    var notes: String?

    // Borrar una sesión nunca borra el historial de práctica.
    @Relationship(deleteRule: .nullify, inverse: \Attempt.session)
    var attempts: [Attempt]? = []

    var kind: SessionKind? {
        get { SessionKind(rawValue: kindRaw) }
        set { if let newValue { kindRaw = newValue.rawValue } }
    }

    init(kind: SessionKind = .soloPractice, startedAt: Date = .now) {
        self.id = UUID()
        self.startedAt = startedAt
        self.kindRaw = kind.rawValue
    }
}
