//
//  Tema.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import SwiftData

/// Unidad de estudio individual que puede ser cantada.
/// El título es opcional: muchos opositores trabajan solo con "Tema 1", "Tema 2"…
@Model
final class Tema {
    var id: UUID = UUID()
    var numero: Int = 0
    var titulo: String?
    var activo: Bool = true
    var fechaCreacion: Date = Date.now
    var fechaActualizacion: Date = Date.now

    var temario: Temario?

    @Relationship(deleteRule: .cascade, inverse: \Intento.tema)
    var intentos: [Intento]? = []

    init(numero: Int, titulo: String? = nil, temario: Temario) {
        self.id = UUID()
        self.numero = numero
        self.titulo = titulo
        self.activo = true
        self.fechaCreacion = .now
        self.fechaActualizacion = .now
        self.temario = temario
    }
}
