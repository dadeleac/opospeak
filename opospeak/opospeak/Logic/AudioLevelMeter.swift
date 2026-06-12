//
//  AudioLevelMeter.swift
//  opospeak
//
//  Created by David de León Acosta on 12/06/2026.
//

import Foundation

/// Convierte la potencia del micrófono en el nivel que respira el halo.
/// Pura: el recorder alimenta muestras, toda la calibración vive aquí.
/// El objetivo es presencia, no vúmetro — el suavizado asimétrico hace
/// que el halo responda a la voz sin parpadear nunca.
struct AudioLevelMeter {

    /// Suelo de habla: por debajo de −50 dB es silencio (0); 0 dB es 1.
    /// Mapeo lineal en dB — predecible, sin amplificar el ruido de fondo.
    static let silenceFloorDB: Float = -50

    /// Ataque rápido: el halo alcanza la voz en un par de muestras.
    static let attackAlpha: Double = 0.5
    /// Caída lenta: el halo se relaja, no parpadea.
    static let releaseAlpha: Double = 0.12

    private(set) var level: Double = 0

    /// Potencia en dB (−160…0) → nivel [0, 1].
    static func normalize(power: Float) -> Double {
        guard power > silenceFloorDB else { return 0 }
        return Double(min(1, (power - silenceFloorDB) / -silenceFloorDB))
    }

    /// EMA asimétrica sobre el nivel normalizado; devuelve el suavizado.
    @discardableResult
    mutating func smooth(_ newLevel: Double) -> Double {
        let alpha = newLevel > level ? Self.attackAlpha : Self.releaseAlpha
        level += alpha * (newLevel - level)
        return level
    }

    /// Asienta el nivel a cero al instante (pausa, fin, descarte):
    /// una pantalla en pausa está visiblemente quieta.
    mutating func reset() {
        level = 0
    }
}
