//
//  Attempt.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import SwiftData

/// Intento: ejecución concreta de un tema dentro de una sesión.
/// Es la entidad central del producto: todo análisis histórico
/// se construye alrededor de los intentos.
@Model
final class Attempt {
    var id: UUID = UUID()
    var startedAt: Date = Date.now
    var endedAt: Date?
    var duration: TimeInterval = 0
    var isCompleted: Bool = false
    /// Destacado por el usuario: curación, no juicio — ninguna lógica
    /// deriva recomendaciones ni presión de este campo.
    var isHighlighted: Bool = false

    var topic: Topic?
    var session: PracticeSession?

    @Relationship(deleteRule: .cascade, inverse: \Recording.attempt)
    var recording: Recording?

    @Relationship(deleteRule: .cascade, inverse: \Metric.attempt)
    var metrics: [Metric]? = []

    @Relationship(deleteRule: .cascade, inverse: \Note.attempt)
    var notes: [Note]? = []

    init(topic: Topic, session: PracticeSession, startedAt: Date = .now) {
        self.id = UUID()
        self.startedAt = startedAt
        self.topic = topic
        self.session = session
    }
}
