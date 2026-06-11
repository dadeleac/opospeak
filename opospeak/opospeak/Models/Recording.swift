//
//  Recording.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import SwiftData

/// Grabación: archivo de audio asociado a un intento.
/// El modelo solo guarda metadatos: el audio vive en disco y su URL
/// se deriva del identificador (los paths absolutos cambian entre
/// dispositivos y restauraciones).
@Model
final class Recording {
    var id: UUID = UUID()
    var duration: TimeInterval = 0
    var fileSize: Int64 = 0
    var format: String = "m4a"
    var createdAt: Date = Date.now

    var attempt: Attempt?

    init(attempt: Attempt, duration: TimeInterval, fileSize: Int64, format: String = "m4a") {
        self.id = UUID()
        self.duration = duration
        self.fileSize = fileSize
        self.format = format
        self.createdAt = .now
        self.attempt = attempt
    }
}
