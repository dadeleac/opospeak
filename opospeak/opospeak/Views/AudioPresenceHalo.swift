//
//  AudioPresenceHalo.swift
//  opospeak
//
//  Created by David de León Acosta on 12/06/2026.
//

import SwiftUI

/// El halo que respira con la voz: presencia, no vúmetro. Vive detrás
/// del reloj — dentro del anillo en cuenta atrás, como única presencia
/// en cronómetro. El suavizado real lo hizo AudioLevelMeter; aquí la
/// animación solo cose los fotogramas.
struct AudioPresenceHalo: View {
    /// Nivel suavizado [0, 1] del recorder.
    let level: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Con Reduce Motion el halo no sigue la voz: estado suave fijo.
    /// La curva perceptual (^0,7) levanta el rango conversacional: a
    /// volumen normal el nivel medio ronda 0,4–0,5 y en lineal apenas
    /// se veía sobre Paper.
    private var effectiveLevel: Double {
        reduceMotion ? 0.35 : pow(max(0, level), 0.7)
    }

    /// Opacidad central: Sage es un color apagado y necesita techo alto
    /// para leerse como presencia sobre Paper, no como tinte.
    private var coreOpacity: Double {
        0.18 + 0.42 * effectiveLevel
    }

    var body: some View {
        Circle()
            .fill(
                // El color aguanta hasta dos tercios del radio antes de
                // desvanecerse: cuerpo, no un punto diluido en el centro.
                RadialGradient(
                    stops: [
                        .init(color: Color.sage.opacity(coreOpacity), location: 0),
                        .init(color: Color.sage.opacity(coreOpacity * 0.55), location: 0.65),
                        .init(color: Color.sage.opacity(0), location: 1),
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 110
                )
            )
            .scaleEffect(0.78 + 0.34 * effectiveLevel)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.1), value: level)
            .accessibilityHidden(true) // Presencia, no información.
    }
}

#Preview("Hablando") {
    AudioPresenceHalo(level: 0.7)
        .frame(width: 220, height: 220)
        .padding()
}

#Preview("Silencio") {
    AudioPresenceHalo(level: 0)
        .frame(width: 220, height: 220)
        .padding()
}
