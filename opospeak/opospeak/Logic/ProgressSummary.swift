//
//  ProgressSummary.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation

/// Resumen de progreso derivado de los intentos. Nunca se persiste:
/// las estadísticas son vistas derivadas (define-core-domain-model).
/// Muestra hechos, no juicios (define-progress-and-history-model).
struct ProgressSummary {

    /// Proyección plana de un intento, para que el cálculo sea testable
    /// sin contenedor SwiftData.
    struct IntentoDato {
        let fecha: Date
        let duracion: TimeInterval
        let temaId: UUID
    }

    // Volumen
    let totalIntentos: Int
    let tiempoAcumulado: TimeInterval
    let temasTrabajados: Int
    let diasActivos: Int

    // Consistencia (hechos, sin presión de racha)
    let diasConPracticaUltimos7: Int
    let diasConPracticaUltimos30: Int

    // Cobertura
    let totalTemas: Int
    let temasPracticados: Int
    var temasNuncaPracticados: Int { totalTemas - temasPracticados }

    // Distribución
    let temaMasPracticado: (temaId: UUID, intentos: Int)?
    let temaMenosPracticado: (temaId: UUID, intentos: Int)?

    var hayActividad: Bool { totalIntentos > 0 }

    init(intentos: [IntentoDato], temaIds: [UUID], referencia: Date = .now, calendar: Calendar = .current) {
        totalIntentos = intentos.count
        tiempoAcumulado = intentos.reduce(0) { $0 + $1.duracion }

        let porTema = Dictionary(grouping: intentos, by: \.temaId)
        temasTrabajados = porTema.count

        let dias = Set(intentos.map { calendar.startOfDay(for: $0.fecha) })
        diasActivos = dias.count

        func diasConPractica(ultimos n: Int) -> Int {
            guard let limite = calendar.date(byAdding: .day, value: -n, to: referencia) else { return 0 }
            return dias.filter { $0 > limite && $0 <= referencia }.count
        }
        diasConPracticaUltimos7 = diasConPractica(ultimos: 7)
        diasConPracticaUltimos30 = diasConPractica(ultimos: 30)

        totalTemas = temaIds.count
        let idsConocidos = Set(temaIds)
        temasPracticados = porTema.keys.filter { idsConocidos.contains($0) }.count

        let conteos = porTema
            .filter { idsConocidos.contains($0.key) }
            .map { (temaId: $0.key, intentos: $0.value.count) }
        temaMasPracticado = conteos.max { $0.intentos < $1.intentos }
        temaMenosPracticado = conteos.min { $0.intentos < $1.intentos }
    }
}
