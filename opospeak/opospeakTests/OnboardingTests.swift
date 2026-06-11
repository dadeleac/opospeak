//
//  OnboardingTests.swift
//  opospeakTests
//
//  Created by David de León Acosta on 11/06/2026.
//

import Testing
@testable import opospeak

struct OnboardingDecisionTests {

    @Test func newUserWithoutDataSeesOnboarding() {
        #expect(
            OnboardingDecision.shouldShow(completed: false, hasData: false) == .show
        )
    }

    @Test func restoredDataSkipsAndMarks() {
        // Dispositivo nuevo con datos de iCloud (oposiciones o temarios
        // pre-refactor): usuario que vuelve.
        #expect(
            OnboardingDecision.shouldShow(completed: false, hasData: true) == .skipAndMark
        )
    }

    @Test func completedNeverReappears() {
        #expect(
            OnboardingDecision.shouldShow(completed: true, hasData: false) == .skip
        )
        #expect(
            OnboardingDecision.shouldShow(completed: true, hasData: true) == .skip
        )
    }
}
