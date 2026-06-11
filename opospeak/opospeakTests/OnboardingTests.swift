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
            OnboardingDecision.debeMostrarse(completado: false, tieneTemarios: false) == .mostrar
        )
    }

    @Test func datosRestauradosOmitenYMarcan() {
        // Dispositivo nuevo con datos de iCloud: usuario que vuelve.
        #expect(
            OnboardingDecision.debeMostrarse(completado: false, tieneTemarios: true) == .omitirYMarcar
        )
    }

    @Test func yaCompletadoNuncaReaparece() {
        #expect(
            OnboardingDecision.debeMostrarse(completado: true, tieneTemarios: false) == .omitir
        )
        #expect(
            OnboardingDecision.debeMostrarse(completado: true, tieneTemarios: true) == .omitir
        )
    }
}
