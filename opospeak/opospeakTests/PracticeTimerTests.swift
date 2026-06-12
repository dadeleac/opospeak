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
        config.halfTimeWarning = true

        config.save(to: defaults)
        let loaded = PracticeTimerConfig.load(from: defaults)

        #expect(loaded == config)
    }

    @Test func missingDataYieldsDefaults() {
        let defaults = UserDefaults(suiteName: "PracticeTimerConfigTests-\(UUID().uuidString)")!
        let loaded = PracticeTimerConfig.load(from: defaults)
        #expect(loaded.mode == .countUp)
        #expect(loaded.targetDuration == 15 * 60)
        #expect(loaded.halfTimeWarning == false)
    }

    @Test func legacyPayloadWithoutHalfTimeKeyStillDecodes() throws {
        // Config guardada por una versión sin halfTimeWarning: la clave
        // ausente cae a false en vez de invalidar toda la configuración.
        let legacy = #"{"mode":"countdown","targetDuration":1200,"warningMarks":[600,120]}"#
        let loaded = try JSONDecoder().decode(
            PracticeTimerConfig.self, from: Data(legacy.utf8)
        )
        #expect(loaded.mode == .countdown)
        #expect(loaded.targetDuration == 1200)
        #expect(loaded.warningMarks == [600, 120])
        #expect(loaded.halfTimeWarning == false)
    }
}

struct CountdownRingGeometryTests {

    @Test func fullAtStartEmptyAtTarget() {
        #expect(CountdownRingGeometry.remainingFraction(target: 720, elapsed: 0) == 1)
        #expect(CountdownRingGeometry.remainingFraction(target: 720, elapsed: 360) == 0.5)
        #expect(CountdownRingGeometry.remainingFraction(target: 720, elapsed: 720) == 0)
    }

    @Test func overtimeDoesNotUnfillTheRing() {
        // El exceso no "des-vacía" el anillo: fijado a cero.
        #expect(CountdownRingGeometry.remainingFraction(target: 720, elapsed: 900) == 0)
    }

    @Test func nonPositiveTargetIsEmpty() {
        #expect(CountdownRingGeometry.remainingFraction(target: 0, elapsed: 10) == 0)
        #expect(CountdownRingGeometry.markFractions(target: 0, marks: [60]).isEmpty)
    }

    @Test func markFractionsArePositionsOnTheRing() {
        // Marcas a 5 y 1 min de un objetivo de 12: fracciones restantes.
        let fractions = CountdownRingGeometry.markFractions(
            target: 12 * 60, marks: [300, 60]
        )
        #expect(fractions == [300.0 / 720.0, 60.0 / 720.0])
    }

    @Test func outOfRangeMarksDrawNoTicks() {
        // Cero (el agotamiento no es tick: es el final del anillo) y
        // marcas iguales o mayores que el objetivo.
        let fractions = CountdownRingGeometry.markFractions(
            target: 600, marks: [0, 600, 900, 300]
        )
        #expect(fractions == [0.5])
    }
}

struct EffectiveWarningMarksTests {

    @Test func halfTimeMarkScalesWithTarget() {
        var config = PracticeTimerConfig()
        config.mode = .countdown
        config.targetDuration = 75 * 60
        config.warningMarks = [300]
        config.halfTimeWarning = true

        // Un simulacro de 75 min avisa al quedar 37,5 min.
        #expect(config.effectiveWarningMarks() == [37.5 * 60, 300])
    }

    @Test func disabledHalfTimeAddsNothing() {
        var config = PracticeTimerConfig()
        config.warningMarks = [300, 60]
        config.halfTimeWarning = false

        #expect(config.effectiveWarningMarks() == [300, 60])
    }

    @Test func halfTimeCoincidingWithPresetIsDeduplicated() {
        var config = PracticeTimerConfig()
        config.targetDuration = 10 * 60
        config.warningMarks = [300, 60]
        config.halfTimeWarning = true

        // Objetivo de 10 min: la mitad coincide con el preset de 5 min.
        #expect(config.effectiveWarningMarks() == [300, 60])
    }

    @Test func marksAtOrBeyondTargetAreFiltered() {
        var config = PracticeTimerConfig()
        config.targetDuration = 4 * 60
        config.warningMarks = [600, 300, 60]
        config.halfTimeWarning = true

        // Solo sobreviven las marcas por debajo del objetivo.
        #expect(config.effectiveWarningMarks() == [120, 60])
    }
}
