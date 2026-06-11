//
//  ThemeTests.swift
//  opospeakTests
//
//  Created by David de León Acosta on 11/06/2026.
//

import UIKit
import Testing
@testable import opospeak

/// Guarda contra el fallo silencioso clásico: un colorset renombrado o un
/// token con errata renderiza colores de sistema sin avisar.
struct ThemeTests {

    private static let tokens = [
        "Tinta", "Pizarra", "Arena", "ArenaElevada",
        "Salvia", "Ambar", "RojoApagado", "AccentColor",
    ]

    @Test(arguments: tokens)
    func colorSemanticoResuelve(nombre: String) {
        #expect(
            UIColor(named: nombre) != nil,
            "El colorset '\(nombre)' no existe en el catálogo"
        )
    }

    @Test func variantesClaroYOscuroSonDistintas() {
        for nombre in Self.tokens {
            guard let color = UIColor(named: nombre) else { continue }
            let claro = color.resolvedColor(with: .init(userInterfaceStyle: .light))
            let oscuro = color.resolvedColor(with: .init(userInterfaceStyle: .dark))
            #expect(claro != oscuro, "'\(nombre)' no tiene variante oscura propia")
        }
    }
}
