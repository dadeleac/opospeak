//
//  ExportModels.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation

/// DTOs del paquete de exportación (define-export-format).
/// Son un contrato público: deben permanecer estables aunque los modelos
/// SwiftData evolucionen — por eso no se serializan los modelos directamente.
/// Las claves JSON y los nombres de archivo están en español por contrato
/// (datos de cara al opositor); las propiedades Swift, en inglés, con
/// CodingKeys explícitas como puente.
enum ExportSchema {

    static let packageFormat = "opospeak-export"
    /// v2: oposiciones.json + oposicionId en temarios + columna oposicion en CSV.
    static let version = 2

    /// Encoder único del paquete: ISO 8601 y salida legible y determinista.
    static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}

struct ManifestExport: Codable {
    struct Counts: Codable {
        let oppositions: Int
        let syllabi: Int
        let topics: Int
        let sessions: Int
        let attempts: Int
        let recordings: Int
        let notes: Int

        enum CodingKeys: String, CodingKey {
            case oppositions = "oposiciones"
            case syllabi = "temarios"
            case topics = "temas"
            case sessions = "sesiones"
            case attempts = "intentos"
            case recordings = "grabaciones"
            case notes = "notas"
        }
    }

    let format: String
    let version: Int
    let exportedAt: Date
    let appVersion: String
    let counts: Counts
    let recordingFormat: String
}

struct OppositionExport: Codable {
    let id: UUID
    let name: String
    let summary: String?
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case name = "nombre"
        case summary = "descripcion"
        case isActive = "activo"
        case createdAt = "fechaCreacion"
        case updatedAt = "fechaActualizacion"
    }

    init(_ opposition: Opposition) {
        id = opposition.id
        name = opposition.name
        summary = opposition.summary
        isActive = opposition.isActive
        createdAt = opposition.createdAt
        updatedAt = opposition.updatedAt
    }
}

struct SyllabusExport: Codable {
    let id: UUID
    let oppositionID: UUID?
    let name: String
    let summary: String?
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case oppositionID = "oposicionId"
        case name = "nombre"
        case summary = "descripcion"
        case isActive = "activo"
        case createdAt = "fechaCreacion"
        case updatedAt = "fechaActualizacion"
    }

    init(_ syllabus: Syllabus) {
        id = syllabus.id
        oppositionID = syllabus.opposition?.id
        name = syllabus.name
        summary = syllabus.summary
        isActive = syllabus.isActive
        createdAt = syllabus.createdAt
        updatedAt = syllabus.updatedAt
    }
}

struct TopicExport: Codable {
    let id: UUID
    let syllabusID: UUID?
    let number: Int
    let title: String?
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case syllabusID = "temarioId"
        case number = "numero"
        case title = "titulo"
        case isActive = "activo"
        case createdAt = "fechaCreacion"
        case updatedAt = "fechaActualizacion"
    }

    init(_ topic: Topic) {
        id = topic.id
        syllabusID = topic.syllabus?.id
        number = topic.number
        title = topic.title
        isActive = topic.isActive
        createdAt = topic.createdAt
        updatedAt = topic.updatedAt
    }
}

struct SessionExport: Codable {
    let id: UUID
    let startedAt: Date
    let endedAt: Date?
    let kind: String
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case id
        case startedAt = "fechaInicio"
        case endedAt = "fechaFin"
        case kind = "tipo"
        case notes = "observaciones"
    }

    init(_ session: PracticeSession) {
        id = session.id
        startedAt = session.startedAt
        endedAt = session.endedAt
        kind = session.kindRaw
        notes = session.notes
    }
}

struct RecordingExport: Codable {
    let recordingID: UUID
    let file: String
    let duration: TimeInterval
    let fileSize: Int64
    let format: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case recordingID = "grabacionId"
        case file = "archivo"
        case duration = "duracion"
        case fileSize = "tamano"
        case format = "formato"
        case createdAt = "fechaCreacion"
    }

    init(_ recording: Recording) {
        recordingID = recording.id
        file = "recordings/\(recording.id.uuidString).\(recording.format)"
        duration = recording.duration
        fileSize = recording.fileSize
        format = recording.format
        createdAt = recording.createdAt
    }
}

struct AttemptExport: Codable {
    let id: UUID
    let topicID: UUID?
    let sessionID: UUID?
    let startedAt: Date
    let endedAt: Date?
    let duration: TimeInterval
    let isCompleted: Bool
    /// Curación del usuario; clave aditiva al contrato v2.
    let isHighlighted: Bool
    let recording: RecordingExport?

    enum CodingKeys: String, CodingKey {
        case id
        case topicID = "temaId"
        case sessionID = "sesionId"
        case startedAt = "fechaInicio"
        case endedAt = "fechaFin"
        case duration = "duracionReal"
        case isCompleted = "completado"
        case isHighlighted = "destacado"
        case recording = "grabacion"
    }

    init(_ attempt: Attempt) {
        id = attempt.id
        topicID = attempt.topic?.id
        sessionID = attempt.session?.id
        startedAt = attempt.startedAt
        endedAt = attempt.endedAt
        duration = attempt.duration
        isCompleted = attempt.isCompleted
        isHighlighted = attempt.isHighlighted
        recording = attempt.recording.map(RecordingExport.init)
    }
}

struct MetricExport: Codable {
    let id: UUID
    let attemptID: UUID?
    let kind: String
    let value: Double
    let date: Date

    enum CodingKeys: String, CodingKey {
        case id
        case attemptID = "intentoId"
        case kind = "tipo"
        case value = "valor"
        case date = "fecha"
    }

    init(_ metric: Metric) {
        id = metric.id
        attemptID = metric.attempt?.id
        kind = metric.kindRaw
        value = metric.value
        date = metric.date
    }
}

struct NoteExport: Codable {
    let id: UUID
    let attemptID: UUID?
    let content: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case attemptID = "intentoId"
        case content = "contenido"
        case createdAt = "fechaCreacion"
    }

    init(_ note: Note) {
        id = note.id
        attemptID = note.attempt?.id
        content = note.content
        createdAt = note.createdAt
    }
}

// MARK: - CSV

/// Proyección plana de intentos para hojas de cálculo. No contiene nada
/// que no esté ya en los JSON. Cabecera en español por contrato (v2).
enum AttemptsCSV {

    static let header = "intentoId,oposicion,temario,tema,numero,fecha,duracionSegundos,completado,tieneGrabacion,tieneNotas"

    static func build(attempts: [Attempt]) -> String {
        var lines = [header]
        for attempt in attempts {
            let fields = [
                attempt.id.uuidString,
                escape(attempt.topic?.syllabus?.opposition?.name ?? ""),
                escape(attempt.topic?.syllabus?.name ?? ""),
                escape(attempt.topic?.displayName ?? ""),
                String(attempt.topic?.number ?? 0),
                shortDate(attempt.startedAt),
                String(Int(attempt.duration.rounded())),
                String(attempt.isCompleted),
                String(attempt.recording != nil),
                String(attempt.notes?.isEmpty == false),
            ]
            lines.append(fields.joined(separator: ","))
        }
        return lines.joined(separator: "\n") + "\n"
    }

    /// Escapado RFC 4180: comillas dobles alrededor de campos con comas,
    /// comillas o saltos de línea; las comillas internas se duplican.
    static func escape(_ field: String) -> String {
        guard field.contains(",") || field.contains("\"") || field.contains("\n") else {
            return field
        }
        return "\"\(field.replacingOccurrences(of: "\"", with: "\"\""))\""
    }

    private static func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
}
