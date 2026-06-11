//
//  Nota.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import SwiftData

/// Observación asociada a un intento. Las notas son contexto;
/// no sustituyen al audio.
@Model
final class Nota {
    var id: UUID = UUID()
    var contenido: String = ""
    var fechaCreacion: Date = Date.now

    var intento: Intento?

    init(intento: Intento, contenido: String) {
        self.id = UUID()
        self.contenido = contenido
        self.fechaCreacion = .now
        self.intento = intento
    }
}
