//
//  Oposicion.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import SwiftData

/// Raíz del dominio: la oposición que el opositor prepara.
/// Judicatura, Notarías o Inspección de Hacienda son oposiciones;
/// Civil, Penal o Procesal son temarios dentro de una.
@Model
final class Oposicion {
    var id: UUID = UUID()
    var nombre: String = ""
    var descripcion: String?
    var activo: Bool = true
    var fechaCreacion: Date = Date.now
    var fechaActualizacion: Date = Date.now

    @Relationship(deleteRule: .cascade, inverse: \Temario.oposicion)
    var temarios: [Temario]? = []

    init(nombre: String, descripcion: String? = nil) {
        self.id = UUID()
        self.nombre = nombre
        self.descripcion = descripcion
        self.fechaCreacion = .now
        self.fechaActualizacion = .now
    }
}
