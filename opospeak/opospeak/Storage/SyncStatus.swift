//
//  SyncStatus.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import CloudKit
import Observation

/// Estado real de la sincronización para Ajustes: hechos, sin nagging.
/// La app nunca presiona para iniciar sesión en iCloud.
@Observable
final class SyncStatus {

    enum Modo {
        case icloud
        case local
    }

    enum Cuenta: Equatable {
        case desconocida
        case disponible
        case sinCuenta
        case otra
    }

    /// Modo con el que se creó el ModelContainer (no cambia en caliente).
    let modo: Modo
    private(set) var cuenta: Cuenta = .desconocida

    init(modo: Modo) {
        self.modo = modo
    }

    var descripcion: String {
        guard modo == .icloud else { return "No disponible" }
        return switch cuenta {
        case .disponible: "Activa"
        case .sinCuenta: "Sin cuenta de iCloud"
        case .desconocida: "Comprobando…"
        case .otra: "No disponible"
        }
    }

    func actualizarCuenta() async {
        guard modo == .icloud else { return }
        let estado = try? await CKContainer(
            identifier: RecordingLocation.containerIdentifier
        ).accountStatus()
        cuenta = switch estado {
        case .available: .disponible
        case .noAccount: .sinCuenta
        default: .otra
        }
    }
}

/// Dependencias compartidas resueltas al arrancar: el RecordingStore
/// efectivo (local o ubicuo) y el estado de sincronización. Sustituye a
/// las construcciones ad hoc de RecordingStore() en las vistas.
@Observable
final class AppEnvironment {

    private(set) var recordingStore: RecordingStore
    let syncStatus: SyncStatus

    init(modo: SyncStatus.Modo) {
        recordingStore = RecordingStore()
        syncStatus = SyncStatus(modo: modo)
    }

    /// Resuelve el contenedor ubicuo (fuera del hilo principal), migra las
    /// grabaciones locales si procede y actualiza el estado de cuenta.
    /// La migración es idempotente: corre en cada arranque sin coste si
    /// no hay nada que mover.
    func arrancar() async {
        let ubiquity = await Task.detached(priority: .utility) {
            RecordingLocation.ubiquityURL()
        }.value

        if let ubiquity {
            let destino = RecordingLocation.resolve(ubiquity: ubiquity)
            RecordingMigrator.migrate(from: RecordingLocation.localURL, to: destino)
            let store = RecordingStore(directoryURL: destino)
            try? store.ensureDirectoryExists()
            recordingStore = store
        }

        await syncStatus.actualizarCuenta()
    }
}
