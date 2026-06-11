//
//  Theme.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import SwiftUI

// Sistema de color (define-color-system-and-visual-identity).
//
// Los tokens semánticos viven como colorsets en Assets.xcassets — única
// fuente de verdad, con variantes claro/oscuro — y Xcode genera sus
// símbolos automáticamente (`Color.tinta`, `.arena`, `.salvia`…).
// Las vistas referencian tokens, nunca valores hex.
//
//   Tinta        Deep Ink — principal e interactivo (concentración)
//   Pizarra      Slate — acentos secundarios
//   Papel        fondo de pantalla: página limpia en claro, lectura
//                nocturna en oscuro
//   Arena        Warm Sand — superficies cálidas destacadas sobre Papel
//                (bloques, tarjetas); no es el fondo de pantalla
//   ArenaElevada superficies elevadas sobre Arena
//   Salvia       Sage — avance y confirmación positiva
//   Ambar        atención y repaso (archivar)
//   RojoApagado  grabación y destructivo — serio, no alarmante

/// Fondo de cuaderno para las pantallas persistentes. Las hojas de
/// creación (herramientas transitorias) conservan el fondo de sistema.
struct FondoEditorial: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background(Color.papel)
    }
}

extension View {
    func fondoEditorial() -> some View {
        modifier(FondoEditorial())
    }
}
