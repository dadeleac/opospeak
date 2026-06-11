//
//  PracticeService.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import SwiftData

/// Único punto de escritura al finalizar una práctica: sesión (reutilizada
/// o nueva según SesionPolicy), Intento, Grabación y Métrica se guardan en
/// una sola transacción. El archivo de audio ya debe existir en disco.
struct PracticeService {
    let modelContext: ModelContext
    let recordingStore: RecordingStore

    @discardableResult
    func finish(tema: Tema, grabacionId: UUID, inicio: Date, fin: Date) throws -> Intento {
        let duracion = fin.timeIntervalSince(inicio)
        let sesion = try sesionActiva(en: fin)

        let intento = Intento(tema: tema, sesion: sesion, fechaInicio: inicio)
        intento.fechaFin = fin
        intento.duracionReal = duracion
        intento.completado = true
        modelContext.insert(intento)

        let fileURL = recordingStore.url(forGrabacionId: grabacionId)
        let atributos = try? FileManager.default.attributesOfItem(
            atPath: fileURL.path(percentEncoded: false)
        )
        let tamano = (atributos?[.size] as? Int64) ?? 0

        let grabacion = Grabacion(intento: intento, duracion: duracion, tamano: tamano)
        grabacion.id = grabacionId
        modelContext.insert(grabacion)

        modelContext.insert(Metrica(intento: intento, tipo: .duracionTotal, valor: duracion, fecha: fin))

        sesion.fechaFin = fin
        try modelContext.save()
        return intento
    }

    /// Abandona una práctica: borra el archivo parcial, no persiste nada.
    func discard(grabacionId: UUID) {
        try? recordingStore.deleteRecording(id: grabacionId)
    }

    private func sesionActiva(en fecha: Date) throws -> Sesion {
        var descriptor = FetchDescriptor<Sesion>(
            sortBy: [SortDescriptor(\.fechaInicio, order: .reverse)]
        )
        descriptor.fetchLimit = 5
        let recientes = try modelContext.fetch(descriptor)

        if let reutilizable = recientes.first(where: {
            SesionPolicy.esReutilizable(ultimaActividad: $0.fechaFin ?? $0.fechaInicio, ahora: fecha)
        }) {
            return reutilizable
        }

        let nueva = Sesion(fechaInicio: fecha)
        modelContext.insert(nueva)
        return nueva
    }
}
