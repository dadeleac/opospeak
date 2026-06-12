//
//  CountdownRing.swift
//  opospeak
//
//  Created by David de León Acosta on 12/06/2026.
//

import SwiftUI

/// El anillo de la cuenta atrás: se vacía con el tiempo grabado, como el
/// Temporizador del sistema, y dibuja las marcas de aviso como ticks —
/// el opositor ve venir el aviso, igual que ve el reloj del tribunal.
/// Vista tonta: toda la aritmética es de CountdownRingGeometry.
struct CountdownRing: View {
    /// Fracción restante [0, 1]; 1 lleno, 0 agotado.
    let fraction: Double
    /// Posiciones de las marcas como fracción restante.
    let markFractions: [Double]
    let isOvertime: Bool

    private let lineWidth: CGFloat = 5
    private let tickDiameter: CGFloat = 9

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    isOvertime ? Color.mutedRed.opacity(0.25) : Color(.quaternaryLabel).opacity(0.4),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )

            // El arco restante nace arriba y se vacía en sentido horario.
            Circle()
                .trim(from: 0, to: fraction)
                .stroke(
                    Color.ink,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: fraction)

            ForEach(markFractions, id: \.self) { mark in
                tick(at: mark)
            }
        }
        .accessibilityHidden(true) // El reloj y los anuncios ya lo cuentan.
    }

    /// Un tick por marca, colocado por ángulo sobre el propio trazo.
    /// Se atenúa cuando el arco lo deja atrás: su aviso ya sonó.
    private func tick(at mark: Double) -> some View {
        let crossed = mark > fraction
        return GeometryReader { proxy in
            let radius = min(proxy.size.width, proxy.size.height) / 2
            let angle = Angle.degrees(-90 + 360 * mark)
            Circle()
                .fill(crossed ? Color(.quaternaryLabel) : Color.amber)
                .frame(width: tickDiameter, height: tickDiameter)
                .position(
                    x: proxy.size.width / 2 + radius * cos(angle.radians),
                    y: proxy.size.height / 2 + radius * sin(angle.radians)
                )
                .animation(.easeOut(duration: 0.4), value: crossed)
        }
    }
}

#Preview("Mediada, marcas a 5 y 1 de 12 min") {
    CountdownRing(
        fraction: 0.55,
        markFractions: [5.0 / 12.0, 1.0 / 12.0],
        isOvertime: false
    )
    .frame(width: 240, height: 240)
    .padding()
}

#Preview("Exceso") {
    CountdownRing(fraction: 0, markFractions: [5.0 / 12.0], isOvertime: true)
        .frame(width: 240, height: 240)
        .padding()
}
