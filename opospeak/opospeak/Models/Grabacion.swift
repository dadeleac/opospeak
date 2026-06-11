//
//  Grabacion.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import SwiftData

/// Archivo de audio asociado a un intento.
/// El modelo solo guarda metadatos: el audio vive en disco y su URL
/// se deriva del identificador (los paths absolutos cambian entre
/// dispositivos y restauraciones).
@Model
final class Grabacion {
    var id: UUID = UUID()
    var duracion: TimeInterval = 0
    var tamano: Int64 = 0
    var formato: String = "m4a"
    var fechaCreacion: Date = Date.now

    var intento: Intento?

    init(intento: Intento, duracion: TimeInterval, tamano: Int64, formato: String = "m4a") {
        self.id = UUID()
        self.duracion = duracion
        self.tamano = tamano
        self.formato = formato
        self.fechaCreacion = .now
        self.intento = intento
    }
}
