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

    enum Mode {
        case icloud
        case local
    }

    enum AccountState: Equatable {
        case unknown
        case available
        case noAccount
        case other
    }

    /// Modo con el que se creó el ModelContainer (no cambia en caliente).
    let mode: Mode
    private(set) var accountState: AccountState = .unknown

    init(mode: Mode) {
        self.mode = mode
    }

    var statusDescription: String {
        guard mode == .icloud else { return String(localized: "No disponible") }
        return switch accountState {
        case .available: String(localized: "Activa")
        case .noAccount: String(localized: "Sin cuenta de iCloud")
        case .unknown: String(localized: "Comprobando…")
        case .other: String(localized: "No disponible")
        }
    }

    func refreshAccount() async {
        guard mode == .icloud else { return }
        let status = try? await CKContainer(
            identifier: RecordingLocation.containerIdentifier
        ).accountStatus()
        accountState = switch status {
        case .available: .available
        case .noAccount: .noAccount
        default: .other
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

    init(mode: SyncStatus.Mode) {
        recordingStore = RecordingStore()
        syncStatus = SyncStatus(mode: mode)
    }

    /// Resuelve el contenedor ubicuo (fuera del hilo principal), migra las
    /// grabaciones locales si procede y actualiza el estado de cuenta.
    /// La migración es idempotente: corre en cada arranque sin coste si
    /// no hay nada que mover.
    func bootstrap() async {
        let ubiquity = await Task.detached(priority: .utility) {
            RecordingLocation.ubiquityURL()
        }.value

        if let ubiquity {
            let target = RecordingLocation.resolve(ubiquity: ubiquity)
            RecordingMigrator.migrate(from: RecordingLocation.localURL, to: target)
            let store = RecordingStore(directoryURL: target)
            try? store.ensureDirectoryExists()
            recordingStore = store
        }

        await syncStatus.refreshAccount()
    }
}
