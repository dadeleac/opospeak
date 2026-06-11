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
// símbolos automáticamente (`Color.ink`, `.paper`, `.sage`…).
// Las vistas referencian tokens, nunca valores hex.
//
//   Ink          Deep Ink — principal e interactivo (concentración)
//   Slate        acentos secundarios
//   Paper        fondo de pantalla: página limpia en claro, lectura
//                nocturna en oscuro
//   Sand         Warm Sand — superficies cálidas destacadas sobre Paper
//                (bloques, tarjetas); no es el fondo de pantalla
//   ElevatedSand superficies elevadas sobre Sand
//   Sage         avance y confirmación positiva
//   Amber        atención y repaso (archivar)
//   MutedRed     grabación y destructivo — serio, no alarmante

/// Fondo de cuaderno para las pantallas persistentes. Las hojas de
/// creación (herramientas transitorias) conservan el fondo de sistema.
struct EditorialBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background(Color.paper)
    }
}

extension View {
    func editorialBackground() -> some View {
        modifier(EditorialBackground())
    }
}
