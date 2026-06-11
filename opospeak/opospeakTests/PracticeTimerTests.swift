//
//  PracticeTimerTests.swift
//  opospeakTests
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import Testing
@testable import opospeak

struct WarningScheduleTests {

    // Objetivo de 15 minutos, avisos a 5 y 1 minuto restantes.
    private let target: TimeInterval = 15 * 60
    private let marks: [TimeInterval] = [300, 60]

    @Test func noCrossingBeforeAnyMark() {
        let crossed = WarningSchedule.crossedMarks(
            target: target, marks: marks, previousElapsed: 0, elapsed: 300
        )
        #expect(crossed.isEmpty)
    }

    @Test func crossingExactBoundaryFires() {
        // La marca de 5 min restantes se cruza en elapsed = 600.
        let crossed = WarningSchedule.crossedMarks(
            target: target, marks: marks, previousElapsed: 599.5, elapsed: 600
        )
        #expect(crossed == [300])
    }

    @Test func markFiresOnlyOnce() {
        // Tick siguiente al cruce: la frontera ya quedó atrás.
        let crossed = WarningSchedule.crossedMarks(
            target: target, marks: marks, previousElapsed: 600, elapsed: 600.5
        )
        #expect(crossed.isEmpty)
    }

    @Test func multipleMarksInOneTick() {
        // Un salto grande (p. ej. tras suspensión) cruza 5 min, 1 min y cero.
        let crossed = WarningSchedule.crossedMarks(
            target: target, marks: marks, previousElapsed: 500, elapsed: 1000
        )
        #expect(crossed == [300, 60, 0])
    }

    @Test func zeroCrossingIsOvertime() {
        let crossed = WarningSchedule.crossedMarks(
            target: target, marks: marks, previousElapsed: 899.5, elapsed: 900.2
        )
        #expect(crossed == [0])
    }

    @Test func marksOutOfRangeAreIgnored() {
        // Marca de 20 min restantes con objetivo de 15: imposible, se ignora.
        let crossed = WarningSchedule.crossedMarks(
            target: target, marks: [20 * 60], previousElapsed: 0, elapsed: 900
        )
        #expect(crossed == [0])
    }

    @Test func frozenElapsedFiresNothing() {
        // Pausa: elapsed no avanza → ningún aviso.
        let crossed = WarningSchedule.crossedMarks(
            target: target, marks: marks, previousElapsed: 600, elapsed: 600
        )
        #expect(crossed.isEmpty)
    }
}

struct PracticeTimerConfigTests {

    @Test func roundTripsThroughUserDefaults() {
        let defaults = UserDefaults(suiteName: "PracticeTimerConfigTests-\(UUID().uuidString)")!
        var config = PracticeTimerConfig()
        config.mode = .countdown
        config.targetDuration = 20 * 60
        config.warningMarks = [600, 120]

        config.save(to: defaults)
        let loaded = PracticeTimerConfig.load(from: defaults)

        #expect(loaded == config)
    }

    @Test func missingDataYieldsDefaults() {
        let defaults = UserDefaults(suiteName: "PracticeTimerConfigTests-\(UUID().uuidString)")!
        let loaded = PracticeTimerConfig.load(from: defaults)
        #expect(loaded.mode == .countUp)
        #expect(loaded.targetDuration == 15 * 60)
    }
}
