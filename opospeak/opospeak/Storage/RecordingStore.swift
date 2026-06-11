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

    /// URL del archivo de audio de una grabación: `Recordings/<id>.<format>`.
    func url(forRecordingID id: UUID, format: String = "m4a") -> URL {
        directoryURL.appending(path: "\(id.uuidString).\(format)")
    }

    /// Crea el directorio de grabaciones si no existe.
    func ensureDirectoryExists() throws {
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    }

    /// URL del archivo si existe en disco; nil en caso contrario.
    /// Permite distinguir "grabación disponible" de metadatos huérfanos.
    func existingURL(forRecordingID id: UUID, format: String = "m4a") -> URL? {
        let fileURL = url(forRecordingID: id, format: format)
        // percentEncoded: false — "Application Support" contiene un espacio
        // y la versión codificada haría fallar a FileManager.
        guard FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) else {
            return nil
        }
        return fileURL
    }

    /// Elimina el archivo de audio de una grabación. No falla si ya no existe.
    func deleteRecording(id: UUID, format: String = "m4a") throws {
        guard let fileURL = existingURL(forRecordingID: id, format: format) else { return }
        try FileManager.default.removeItem(at: fileURL)
    }

    // MARK: - iCloud

    enum Availability: Equatable {
        case available(URL)
        case downloading
        case missing
    }

    /// Estado de una grabación contemplando iCloud: si el archivo no está
    /// en disco pero existe su placeholder `.icloud` (archivo evictado del
    /// contenedor ubicuo), lanza la descarga y reporta `.downloading`.
    func availability(forRecordingID id: UUID, format: String = "m4a") -> Availability {
        if let url = existingURL(forRecordingID: id, format: format) {
            return .available(url)
        }
        let placeholder = directoryURL.appending(path: ".\(id.uuidString).\(format).icloud")
        if FileManager.default.fileExists(atPath: placeholder.path(percentEncoded: false)) {
            let target = url(forRecordingID: id, format: format)
            try? FileManager.default.startDownloadingUbiquitousItem(at: target)
            return .downloading
        }
        return .missing
    }
}
