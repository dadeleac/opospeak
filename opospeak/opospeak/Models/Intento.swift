//
//  Intento.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import SwiftData

/// Ejecución concreta de un tema dentro de una sesión.
/// Es la entidad central del producto: todo análisis histórico
/// se construye alrededor de los intentos.
@Model
final class Intento {
    var id: UUID = UUID()
    var fechaInicio: Date = Date.now
    var fechaFin: Date?
    var duracionReal: TimeInterval = 0
    var completado: Bool = false

    var tema: Tema?
    var sesion: Sesion?

    @Relationship(deleteRule: .cascade, inverse: \Grabacion.intento)
    var grabacion: Grabacion?

    @Relationship(deleteRule: .cascade, inverse: \Metrica.intento)
    var metricas: [Metrica]? = []

    @Relationship(deleteRule: .cascade, inverse: \Nota.intento)
    var notas: [Nota]? = []

    init(tema: Tema, sesion: Sesion, fechaInicio: Date = .now) {
        self.id = UUID()
        self.fechaInicio = fechaInicio
        self.tema = tema
        self.sesion = sesion
    }
}
