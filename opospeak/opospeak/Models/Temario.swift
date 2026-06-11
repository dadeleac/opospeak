//
//  Temario.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import SwiftData

/// Conjunto organizado de temas pertenecientes a una oposición.
/// No almacena grabaciones, métricas ni resultados.
@Model
final class Temario {
    var id: UUID = UUID()
    var nombre: String = ""
    var descripcion: String?
    var activo: Bool = true
    var fechaCreacion: Date = Date.now
    var fechaActualizacion: Date = Date.now

    @Relationship(deleteRule: .cascade, inverse: \Tema.temario)
    var temas: [Tema]? = []

    init(nombre: String, descripcion: String? = nil) {
        self.id = UUID()
        self.nombre = nombre
        self.descripcion = descripcion
        self.fechaCreacion = .now
        self.fechaActualizacion = .now
    }
}
