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
enum ExportSchema {

    static let formato = "opospeak-export"
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
        let oposiciones: Int
        let temarios: Int
        let temas: Int
        let sesiones: Int
        let intentos: Int
        let grabaciones: Int
        let notas: Int
    }

    let format: String
    let version: Int
    let exportedAt: Date
    let appVersion: String
    let counts: Counts
    let recordingFormat: String
}

struct OposicionExport: Codable {
    let id: UUID
    let nombre: String
    let descripcion: String?
    let activo: Bool
    let fechaCreacion: Date
    let fechaActualizacion: Date

    init(_ oposicion: Oposicion) {
        id = oposicion.id
        nombre = oposicion.nombre
        descripcion = oposicion.descripcion
        activo = oposicion.activo
        fechaCreacion = oposicion.fechaCreacion
        fechaActualizacion = oposicion.fechaActualizacion
    }
}

struct TemarioExport: Codable {
    let id: UUID
    let oposicionId: UUID?
    let nombre: String
    let descripcion: String?
    let activo: Bool
    let fechaCreacion: Date
    let fechaActualizacion: Date

    init(_ temario: Temario) {
        id = temario.id
        oposicionId = temario.oposicion?.id
        nombre = temario.nombre
        descripcion = temario.descripcion
        activo = temario.activo
        fechaCreacion = temario.fechaCreacion
        fechaActualizacion = temario.fechaActualizacion
    }
}

struct TemaExport: Codable {
    let id: UUID
    let temarioId: UUID?
    let numero: Int
    let titulo: String?
    let activo: Bool
    let fechaCreacion: Date
    let fechaActualizacion: Date

    init(_ tema: Tema) {
        id = tema.id
        temarioId = tema.temario?.id
        numero = tema.numero
        titulo = tema.titulo
        activo = tema.activo
        fechaCreacion = tema.fechaCreacion
        fechaActualizacion = tema.fechaActualizacion
    }
}

struct SesionExport: Codable {
    let id: UUID
    let fechaInicio: Date
    let fechaFin: Date?
    let tipo: String
    let observaciones: String?

    init(_ sesion: Sesion) {
        id = sesion.id
        fechaInicio = sesion.fechaInicio
        fechaFin = sesion.fechaFin
        tipo = sesion.tipoRaw
        observaciones = sesion.observaciones
    }
}

struct GrabacionExport: Codable {
    let grabacionId: UUID
    let archivo: String
    let duracion: TimeInterval
    let tamano: Int64
    let formato: String
    let fechaCreacion: Date

    init(_ grabacion: Grabacion) {
        grabacionId = grabacion.id
        archivo = "recordings/\(grabacion.id.uuidString).\(grabacion.formato)"
        duracion = grabacion.duracion
        tamano = grabacion.tamano
        formato = grabacion.formato
        fechaCreacion = grabacion.fechaCreacion
    }
}

struct IntentoExport: Codable {
    let id: UUID
    let temaId: UUID?
    let sesionId: UUID?
    let fechaInicio: Date
    let fechaFin: Date?
    let duracionReal: TimeInterval
    let completado: Bool
    let grabacion: GrabacionExport?

    init(_ intento: Intento) {
        id = intento.id
        temaId = intento.tema?.id
        sesionId = intento.sesion?.id
        fechaInicio = intento.fechaInicio
        fechaFin = intento.fechaFin
        duracionReal = intento.duracionReal
        completado = intento.completado
        grabacion = intento.grabacion.map(GrabacionExport.init)
    }
}

struct MetricaExport: Codable {
    let id: UUID
    let intentoId: UUID?
    let tipo: String
    let valor: Double
    let fecha: Date

    init(_ metrica: Metrica) {
        id = metrica.id
        intentoId = metrica.intento?.id
        tipo = metrica.tipoRaw
        valor = metrica.valor
        fecha = metrica.fecha
    }
}

struct NotaExport: Codable {
    let id: UUID
    let intentoId: UUID?
    let contenido: String
    let fechaCreacion: Date

    init(_ nota: Nota) {
        id = nota.id
        intentoId = nota.intento?.id
        contenido = nota.contenido
        fechaCreacion = nota.fechaCreacion
    }
}

// MARK: - CSV

/// Proyección plana de intentos para hojas de cálculo. No contiene nada
/// que no esté ya en los JSON.
enum IntentosCSV {

    static let cabecera = "intentoId,oposicion,temario,tema,numero,fecha,duracionSegundos,completado,tieneGrabacion,tieneNotas"

    static func build(intentos: [Intento]) -> String {
        var lineas = [cabecera]
        for intento in intentos {
            let campos = [
                intento.id.uuidString,
                escape(intento.tema?.temario?.oposicion?.nombre ?? ""),
                escape(intento.tema?.temario?.nombre ?? ""),
                escape(intento.tema?.nombreVisible ?? ""),
                String(intento.tema?.numero ?? 0),
                fechaCorta(intento.fechaInicio),
                String(Int(intento.duracionReal.rounded())),
                String(intento.completado),
                String(intento.grabacion != nil),
                String(intento.notas?.isEmpty == false),
            ]
            lineas.append(campos.joined(separator: ","))
        }
        return lineas.joined(separator: "\n") + "\n"
    }

    /// Escapado RFC 4180: comillas dobles alrededor de campos con comas,
    /// comillas o saltos de línea; las comillas internas se duplican.
    static func escape(_ campo: String) -> String {
        guard campo.contains(",") || campo.contains("\"") || campo.contains("\n") else {
            return campo
        }
        return "\"\(campo.replacingOccurrences(of: "\"", with: "\"\""))\""
    }

    private static func fechaCorta(_ fecha: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: fecha)
    }
}
