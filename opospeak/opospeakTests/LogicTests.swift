//
//  LogicTests.swift
//  opospeakTests
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import Testing
@testable import opospeak

// MARK: - TemaBulkCreator

struct TemaBulkCreatorTests {

    @Test func rangoCompletoEnTemarioVacio() throws {
        let plan = try TemaBulkCreator.plan(existingNumbers: [], desde: 1, hasta: 325)
        #expect(plan.count == 325)
        #expect(plan.first == 1)
        #expect(plan.last == 325)
    }

    @Test func saltaNumerosExistentes() throws {
        let plan = try TemaBulkCreator.plan(existingNumbers: [1, 2], desde: 1, hasta: 5)
        #expect(plan == [3, 4, 5])
    }

    @Test func rangoTotalmenteExistenteDevuelveVacio() throws {
        let plan = try TemaBulkCreator.plan(existingNumbers: [1, 2, 3], desde: 1, hasta: 3)
        #expect(plan.isEmpty)
    }

    @Test func inicioMenorQueUnoFalla() {
        #expect(throws: TemaBulkCreator.BulkError.inicioInvalido) {
            try TemaBulkCreator.plan(existingNumbers: [], desde: 0, hasta: 10)
        }
    }

    @Test func finMenorQueInicioFalla() {
        #expect(throws: TemaBulkCreator.BulkError.rangoInvalido) {
            try TemaBulkCreator.plan(existingNumbers: [], desde: 10, hasta: 5)
        }
    }

    @Test func rangoMayorQueMilFalla() {
        #expect(throws: TemaBulkCreator.BulkError.rangoDemasiadoGrande) {
            try TemaBulkCreator.plan(existingNumbers: [], desde: 1, hasta: 1001)
        }
    }

    @Test func rangoDeExactamenteMilEsValido() throws {
        let plan = try TemaBulkCreator.plan(existingNumbers: [], desde: 1, hasta: 1000)
        #expect(plan.count == 1000)
    }
}

// MARK: - TemaSortOrder

private struct TemaStub: TemaSortable {
    let numero: Int
    let intentoCount: Int
    let ultimaPractica: Date?
}

struct TemaSortOrderTests {

    private let base = Date(timeIntervalSince1970: 1_750_000_000)

    private var temas: [TemaStub] {
        [
            TemaStub(numero: 1, intentoCount: 3, ultimaPractica: base.addingTimeInterval(-86400)),
            TemaStub(numero: 2, intentoCount: 0, ultimaPractica: nil),
            TemaStub(numero: 3, intentoCount: 5, ultimaPractica: base),
            TemaStub(numero: 4, intentoCount: 3, ultimaPractica: base.addingTimeInterval(-3600)),
            TemaStub(numero: 5, intentoCount: 0, ultimaPractica: nil),
        ]
    }

    @Test func ordenNatural() {
        let resultado = TemaSortOrder.natural.sort(temas.shuffled())
        #expect(resultado.map(\.numero) == [1, 2, 3, 4, 5])
    }

    @Test func masPracticados() {
        let resultado = TemaSortOrder.masPracticados.sort(temas)
        #expect(resultado.map(\.numero) == [3, 1, 4, 2, 5])
    }

    @Test func menosPracticados() {
        let resultado = TemaSortOrder.menosPracticados.sort(temas)
        #expect(resultado.map(\.numero) == [2, 5, 1, 4, 3])
    }

    @Test func ultimosPracticados() {
        let resultado = TemaSortOrder.ultimosPracticados.sort(temas)
        // Más recientes primero; sin práctica al final por número.
        #expect(resultado.map(\.numero) == [3, 4, 1, 2, 5])
    }

    @Test func pendientesPrimero() {
        let resultado = TemaSortOrder.pendientes.sort(temas)
        #expect(resultado.map(\.numero) == [2, 5, 1, 3, 4])
    }
}

// MARK: - ProgressSummary

struct ProgressSummaryTests {

    private let referencia = Date(timeIntervalSince1970: 1_750_000_000)

    @Test func sinIntentosNoHayActividad() {
        let resumen = ProgressSummary(intentos: [], temaIds: [UUID(), UUID()], referencia: referencia)
        #expect(!resumen.hayActividad)
        #expect(resumen.totalIntentos == 0)
        #expect(resumen.tiempoAcumulado == 0)
        #expect(resumen.temasPracticados == 0)
        #expect(resumen.temasNuncaPracticados == 2)
        #expect(resumen.temaMasPracticado == nil)
    }

    @Test func volumenYCobertura() {
        let temaA = UUID()
        let temaB = UUID()
        let temaC = UUID()
        let dia: TimeInterval = 86400

        let intentos: [ProgressSummary.IntentoDato] = [
            .init(fecha: referencia.addingTimeInterval(-1 * dia), duracion: 600, temaId: temaA),
            .init(fecha: referencia.addingTimeInterval(-1 * dia + 3600), duracion: 700, temaId: temaA),
            .init(fecha: referencia.addingTimeInterval(-2 * dia), duracion: 800, temaId: temaB),
            .init(fecha: referencia.addingTimeInterval(-20 * dia), duracion: 900, temaId: temaA),
        ]

        let resumen = ProgressSummary(
            intentos: intentos,
            temaIds: [temaA, temaB, temaC],
            referencia: referencia
        )

        #expect(resumen.totalIntentos == 4)
        #expect(resumen.tiempoAcumulado == 3000)
        #expect(resumen.temasTrabajados == 2)
        #expect(resumen.diasActivos == 3)
        #expect(resumen.diasConPracticaUltimos7 == 2)
        #expect(resumen.diasConPracticaUltimos30 == 3)
        #expect(resumen.temasPracticados == 2)
        #expect(resumen.temasNuncaPracticados == 1)
        #expect(resumen.temaMasPracticado?.temaId == temaA)
        #expect(resumen.temaMasPracticado?.intentos == 3)
        #expect(resumen.temaMenosPracticado?.temaId == temaB)
        #expect(resumen.temaMenosPracticado?.intentos == 1)
    }
}

// MARK: - Formato de duración

struct FormatearDuracionTests {

    @Test func minutosYSegundos() {
        #expect(formatearDuracion(708) == "11:48")
    }

    @Test func conHoras() {
        #expect(formatearDuracion(3750) == "1:02:30")
    }

    @Test func cero() {
        #expect(formatearDuracion(0) == "0:00")
    }
}
