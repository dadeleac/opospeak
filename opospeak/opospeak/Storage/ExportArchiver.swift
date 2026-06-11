//
//  ExportArchiver.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation

/// Comprime un directorio en un zip usando el mecanismo nativo de
/// coordinación de archivos (.forUploading): el sistema produce el zip,
/// sin dependencias de terceros.
enum ExportArchiver {

    enum ArchiveError: Error {
        case zipFailed(String)
    }

    /// Comprime `directory` y deja el resultado en una URL estable con el
    /// nombre `<directory>.zip` dentro de un directorio temporal propio.
    static func zip(directory: URL) throws -> URL {
        var resultado: URL?
        var errorCoordinacion: NSError?
        var errorCopia: Error?

        let coordinator = NSFileCoordinator()
        coordinator.coordinate(
            readingItemAt: directory,
            options: .forUploading,
            error: &errorCoordinacion
        ) { zipTemporal in
            do {
                let destinoDir = FileManager.default.temporaryDirectory
                    .appending(path: "zip-\(UUID().uuidString)")
                try FileManager.default.createDirectory(
                    at: destinoDir, withIntermediateDirectories: true
                )
                let destino = destinoDir.appending(path: "\(directory.lastPathComponent).zip")
                // El zip del coordinador vive solo dentro del bloque: copiar fuera.
                try FileManager.default.copyItem(at: zipTemporal, to: destino)
                resultado = destino
            } catch {
                errorCopia = error
            }
        }

        if let errorCoordinacion {
            throw ArchiveError.zipFailed(errorCoordinacion.localizedDescription)
        }
        if let errorCopia {
            throw ArchiveError.zipFailed(errorCopia.localizedDescription)
        }
        guard let resultado else {
            throw ArchiveError.zipFailed("No se generó el archivo.")
        }
        return resultado
    }
}
