//
//  RecordingStore.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation

/// Resuelve la ubicación en disco de los archivos de audio a partir de la
/// identidad de la grabación. No se persisten paths absolutos: el contenedor
/// de la app cambia entre dispositivos y restauraciones.
struct RecordingStore {
    let directoryURL: URL

    init(directoryURL: URL? = nil) {
        if let directoryURL {
            self.directoryURL = directoryURL
        } else {
            let support = URL.applicationSupportDirectory
            self.directoryURL = support.appending(path: "Recordings", directoryHint: .isDirectory)
        }
    }

    /// URL del archivo de audio de una grabación: `Recordings/<id>.<formato>`.
    func url(forGrabacionId id: UUID, formato: String = "m4a") -> URL {
        directoryURL.appending(path: "\(id.uuidString).\(formato)")
    }

    /// Crea el directorio de grabaciones si no existe.
    func ensureDirectoryExists() throws {
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    }

    /// URL del archivo si existe en disco; nil en caso contrario.
    /// Permite distinguir "grabación disponible" de metadatos huérfanos.
    func existingURL(forGrabacionId id: UUID, formato: String = "m4a") -> URL? {
        let fileURL = url(forGrabacionId: id, formato: formato)
        // percentEncoded: false — "Application Support" contiene un espacio
        // y la versión codificada haría fallar a FileManager.
        guard FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) else {
            return nil
        }
        return fileURL
    }

    /// Elimina el archivo de audio de una grabación. No falla si ya no existe.
    func deleteRecording(id: UUID, formato: String = "m4a") throws {
        guard let fileURL = existingURL(forGrabacionId: id, formato: formato) else { return }
        try FileManager.default.removeItem(at: fileURL)
    }
}
