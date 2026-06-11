//
//  Note.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import SwiftData

/// Nota: observación asociada a un intento. Las notas son contexto;
/// no sustituyen al audio.
@Model
final class Note {
    var id: UUID = UUID()
    var content: String = ""
    var createdAt: Date = Date.now

    var attempt: Attempt?

    init(attempt: Attempt, content: String) {
        self.id = UUID()
        self.content = content
        self.createdAt = .now
        self.attempt = attempt
    }
}
