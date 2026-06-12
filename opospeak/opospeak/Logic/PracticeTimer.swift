//
//  PracticeTimer.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation

/// Modo del cronómetro de práctica. La cuenta atrás replica el reloj del
/// examen oral: el opositor ve el tiempo restante, como en el tribunal.
enum TimerMode: String, Codable, CaseIterable {
    case countUp
    case countdown
}

/// Configuración del cronómetro elegida en la preparación. Estado de UX
/// local del dispositivo (como el puntero de oposición activa): se
/// recuerda entre prácticas y no sincroniza.
struct PracticeTimerConfig: Equatable, Codable {
    var mode: TimerMode = .countUp
    /// Objetivo en segundos (solo cuenta atrás).
    var targetDuration: TimeInterval = 15 * 60
    /// Marcas de aviso en segundos RESTANTES (p. ej. [300, 60]).
    var warningMarks: [TimeInterval] = [300, 60]
    /// Aviso relativo "a mitad de tiempo": escala solo con el objetivo
    /// (un tema de 12 min avisa al 6; un simulacro de 75, al 37,5) y
    /// cubre los ejercicios largos sin configurabilidad total.
    var halfTimeWarning: Bool = false

    static let storageKey = "practiceTimerConfig"

    init() {}

    /// Decodificación tolerante: las claves ausentes (configs guardadas
    /// por versiones anteriores) caen a sus valores por defecto.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mode = try container.decodeIfPresent(TimerMode.self, forKey: .mode) ?? .countUp
        targetDuration = try container.decodeIfPresent(TimeInterval.self, forKey: .targetDuration) ?? 15 * 60
        warningMarks = try container.decodeIfPresent([TimeInterval].self, forKey: .warningMarks) ?? [300, 60]
        halfTimeWarning = try container.decodeIfPresent(Bool.self, forKey: .halfTimeWarning) ?? false
    }

    /// Las marcas efectivas de una práctica: las absolutas elegidas más
    /// la mitad del objetivo si está activada — deduplicadas (la mitad
    /// puede coincidir con un preset) y filtradas por debajo del objetivo.
    func effectiveWarningMarks() -> [TimeInterval] {
        var marks = warningMarks
        if halfTimeWarning {
            marks.append(targetDuration / 2)
        }
        return Array(Set(marks))
            .filter { $0 > 0 && $0 < targetDuration }
            .sorted(by: >)
    }

    static func load(from defaults: UserDefaults = .standard) -> PracticeTimerConfig {
        guard let data = defaults.data(forKey: storageKey),
              let config = try? JSONDecoder().decode(PracticeTimerConfig.self, from: data)
        else {
            return PracticeTimerConfig()
        }
        return config
    }

    func save(to defaults: UserDefaults = .standard) {
        if let data = try? JSONEncoder().encode(self) {
            defaults.set(data, forKey: Self.storageKey)
        }
    }
}

/// Cruce de marcas de aviso. Lógica pura sobre tiempo GRABADO (elapsed),
/// no de pared: la pausa congela elapsed, así que los avisos se congelan
/// solos y ninguna marca puede dispararse dos veces (elapsed es monótono).
enum WarningSchedule {

    /// Marcas restantes cruzadas en el intervalo (previousElapsed, elapsed].
    /// Una marca m se cruza cuando previousElapsed < target − m ≤ elapsed.
    /// Devuelve las marcas en orden descendente (la más lejana primero).
    /// El cero (agotamiento del tiempo) se incluye como marca 0.
    static func crossedMarks(
        target: TimeInterval,
        marks: [TimeInterval],
        previousElapsed: TimeInterval,
        elapsed: TimeInterval
    ) -> [TimeInterval] {
        guard elapsed > previousElapsed else { return [] }
        let candidates = (marks + [0]).filter { $0 >= 0 && $0 < target }
        return candidates
            .filter { mark in
                let boundary = target - mark
                return previousElapsed < boundary && boundary <= elapsed
            }
            .sorted(by: >)
    }
}
