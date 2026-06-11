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
        "Ink", "Slate", "Paper", "Sand", "ElevatedSand",
        "Sage", "Amber", "MutedRed", "AccentColor",
    ]

    @Test(arguments: tokens)
    func semanticColorResolves(name: String) {
        #expect(
            UIColor(named: name) != nil,
            "El colorset '\(name)' no existe en el catálogo"
        )
    }

    @Test func lightAndDarkVariantsDiffer() {
        for name in Self.tokens {
            guard let color = UIColor(named: name) else { continue }
            let light = color.resolvedColor(with: .init(userInterfaceStyle: .light))
            let dark = color.resolvedColor(with: .init(userInterfaceStyle: .dark))
            #expect(light != dark, "'\(name)' no tiene variante oscura propia")
        }
    }
}
