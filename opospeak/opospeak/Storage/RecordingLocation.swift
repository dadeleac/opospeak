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

    struct Resultado: Equatable {
        var migrados = 0
        var omitidos = 0
        var fallidos = 0
    }

    @discardableResult
    static func migrate(from origen: URL, to destino: URL) -> Resultado {
        let fm = FileManager.default
        var resultado = Resultado()

        guard let archivos = try? fm.contentsOfDirectory(
            at: origen, includingPropertiesForKeys: nil
        ) else {
            return resultado
        }

        let audios = archivos.filter { $0.pathExtension == "m4a" }
        guard !audios.isEmpty else { return resultado }

        try? fm.createDirectory(at: destino, withIntermediateDirectories: true)

        for archivo in audios {
            let destinoArchivo = destino.appending(path: archivo.lastPathComponent)
            if fm.fileExists(atPath: destinoArchivo.path(percentEncoded: false)) {
                // Ya migrado en un pase anterior: solo retirar el duplicado local.
                try? fm.removeItem(at: archivo)
                resultado.omitidos += 1
                continue
            }
            do {
                try fm.copyItem(at: archivo, to: destinoArchivo)
                guard fm.fileExists(atPath: destinoArchivo.path(percentEncoded: false)) else {
                    resultado.fallidos += 1
                    continue
                }
                try fm.removeItem(at: archivo)
                resultado.migrados += 1
            } catch {
                resultado.fallidos += 1
            }
        }
        return resultado
    }
}
