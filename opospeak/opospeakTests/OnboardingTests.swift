//
//  OnboardingTests.swift
//  opospeakTests
//
//  Created by David de León Acosta on 11/06/2026.
//

import Testing
@testable import opospeak

struct OnboardingDecisionTests {

    @Test func usuarioNuevoSinDatosVeOnboarding() {
        #expect(
            OnboardingDecision.debeMostrarse(completado: false, tieneDatos: false) == .mostrar
        )
    }

    @Test func datosRestauradosOmitenYMarcan() {
        // Dispositivo nuevo con datos de iCloud (oposiciones o temarios
        // pre-refactor): usuario que vuelve.
        #expect(
            OnboardingDecision.debeMostrarse(completado: false, tieneDatos: true) == .omitirYMarcar
        )
    }

    @Test func yaCompletadoNuncaReaparece() {
        #expect(
            OnboardingDecision.debeMostrarse(completado: true, tieneDatos: false) == .omitir
        )
        #expect(
            OnboardingDecision.debeMostrarse(completado: true, tieneDatos: true) == .omitir
        )
    }
}
