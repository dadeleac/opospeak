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
        var result: URL?
        var coordinationError: NSError?
        var copyError: Error?

        let coordinator = NSFileCoordinator()
        coordinator.coordinate(
            readingItemAt: directory,
            options: .forUploading,
            error: &coordinationError
        ) { temporaryZip in
            do {
                let targetDir = FileManager.default.temporaryDirectory
                    .appending(path: "zip-\(UUID().uuidString)")
                try FileManager.default.createDirectory(
                    at: targetDir, withIntermediateDirectories: true
                )
                let target = targetDir.appending(path: "\(directory.lastPathComponent).zip")
                // El zip del coordinador vive solo dentro del bloque: copiar fuera.
                try FileManager.default.copyItem(at: temporaryZip, to: target)
                result = target
            } catch {
                copyError = error
            }
        }

        if let coordinationError {
            throw ArchiveError.zipFailed(coordinationError.localizedDescription)
        }
        if let copyError {
            throw ArchiveError.zipFailed(copyError.localizedDescription)
        }
        guard let result else {
            throw ArchiveError.zipFailed("No zip produced.")
        }
        return result
    }
}
