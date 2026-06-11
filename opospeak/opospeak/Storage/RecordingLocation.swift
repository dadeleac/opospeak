//
//  RecordingLocation.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation

/// Resuelve dónde viven las grabaciones: en el contenedor ubicuo de iCloud
/// Drive cuando hay sesión de iCloud (los archivos sincronizan solos),
/// en Application Support local en caso contrario.
enum RecordingLocation {

    static let containerIdentifier = "iCloud.com.daviddeleonacosta.opospeak"

    /// Directorio local de siempre (el de RecordingStore por defecto).
    static var localURL: URL {
        URL.applicationSupportDirectory.appending(path: "Recordings", directoryHint: .isDirectory)
    }

    /// Consulta el contenedor ubicuo. Documentado para llamarse fuera del
    /// hilo principal (puede hacer I/O la primera vez).
    nonisolated static func ubiquityURL() -> URL? {
        FileManager.default
            .url(forUbiquityContainerIdentifier: containerIdentifier)?
            .appending(path: "Documents", directoryHint: .isDirectory)
            .appending(path: "Recordings", directoryHint: .isDirectory)
    }

    /// Directorio efectivo: ubicuo si existe, local si no.
    static func resolve(ubiquity: URL?) -> URL {
        ubiquity ?? localURL
    }
}

/// Migra grabaciones locales al contenedor ubicuo una vez que iCloud está
/// disponible. Idempotente: copiar-verificar-borrar por archivo, nunca
/// destructivo — ante cualquier fallo el archivo local queda intacto.
enum RecordingMigrator {

    struct MigrationResult: Equatable {
        var migrated = 0
        var skipped = 0
        var failed = 0
    }

    @discardableResult
    static func migrate(from source: URL, to destination: URL) -> MigrationResult {
        let fm = FileManager.default
        var result = MigrationResult()

        guard let files = try? fm.contentsOfDirectory(
            at: source, includingPropertiesForKeys: nil
        ) else {
            return result
        }

        let audioFiles = files.filter { $0.pathExtension == "m4a" }
        guard !audioFiles.isEmpty else { return result }

        try? fm.createDirectory(at: destination, withIntermediateDirectories: true)

        for file in audioFiles {
            let target = destination.appending(path: file.lastPathComponent)
            if fm.fileExists(atPath: target.path(percentEncoded: false)) {
                // Ya migrado en un pase anterior: solo retirar el duplicado local.
                try? fm.removeItem(at: file)
                result.skipped += 1
                continue
            }
            do {
                try fm.copyItem(at: file, to: target)
                guard fm.fileExists(atPath: target.path(percentEncoded: false)) else {
                    result.failed += 1
                    continue
                }
                try fm.removeItem(at: file)
                result.migrated += 1
            } catch {
                result.failed += 1
            }
        }
        return result
    }
}
