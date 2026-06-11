//
//  ICloudSyncTests.swift
//  opospeakTests
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import Testing
@testable import opospeak

// MARK: - RecordingLocation

struct RecordingLocationTests {

    @Test func sinContenedorUbicuoResuelveLocal() {
        #expect(RecordingLocation.resolve(ubiquity: nil) == RecordingLocation.localURL)
    }

    @Test func conContenedorUbicuoLoUsa() {
        let ubicuo = URL(fileURLWithPath: "/ubiquity/Documents/Recordings")
        #expect(RecordingLocation.resolve(ubiquity: ubicuo) == ubicuo)
    }
}

// MARK: - RecordingMigrator

struct RecordingMigratorTests {

    private func makeDirs() throws -> (origen: URL, destino: URL) {
        let base = FileManager.default.temporaryDirectory
            .appending(path: "MigratorTests-\(UUID().uuidString)")
        let origen = base.appending(path: "local", directoryHint: .isDirectory)
        let destino = base.appending(path: "ubiquity", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: origen, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: destino, withIntermediateDirectories: true)
        return (origen, destino)
    }

    private func crearAudio(_ nombre: String, en dir: URL, contenido: String = "audio") throws {
        try Data(contenido.utf8).write(to: dir.appending(path: nombre))
    }

    @Test func migraArchivosM4a() throws {
        let (origen, destino) = try makeDirs()
        try crearAudio("a.m4a", en: origen)
        try crearAudio("b.m4a", en: origen)
        try crearAudio("otros.txt", en: origen)

        let resultado = RecordingMigrator.migrate(from: origen, to: destino)

        #expect(resultado.migrados == 2)
        #expect(resultado.fallidos == 0)
        let fm = FileManager.default
        #expect(fm.fileExists(atPath: destino.appending(path: "a.m4a").path(percentEncoded: false)))
        #expect(fm.fileExists(atPath: destino.appending(path: "b.m4a").path(percentEncoded: false)))
        // Los m4a desaparecen del origen; otros archivos no se tocan.
        #expect(!fm.fileExists(atPath: origen.appending(path: "a.m4a").path(percentEncoded: false)))
        #expect(fm.fileExists(atPath: origen.appending(path: "otros.txt").path(percentEncoded: false)))
    }

    @Test func esIdempotente() throws {
        let (origen, destino) = try makeDirs()
        try crearAudio("a.m4a", en: origen)

        let primera = RecordingMigrator.migrate(from: origen, to: destino)
        #expect(primera.migrados == 1)

        let segunda = RecordingMigrator.migrate(from: origen, to: destino)
        #expect(segunda == RecordingMigrator.Resultado())
    }

    @Test func duplicadoYaMigradoSeRetiraSinPisarDestino() throws {
        let (origen, destino) = try makeDirs()
        try crearAudio("a.m4a", en: destino, contenido: "version-icloud")
        try crearAudio("a.m4a", en: origen, contenido: "version-local")

        let resultado = RecordingMigrator.migrate(from: origen, to: destino)

        #expect(resultado.omitidos == 1)
        #expect(resultado.migrados == 0)
        // El destino conserva su versión; el duplicado local se retira.
        let contenido = try String(
            contentsOf: destino.appending(path: "a.m4a"), encoding: .utf8
        )
        #expect(contenido == "version-icloud")
        #expect(!FileManager.default.fileExists(
            atPath: origen.appending(path: "a.m4a").path(percentEncoded: false)
        ))
    }

    @Test func origenInexistenteNoFalla() {
        let inexistente = FileManager.default.temporaryDirectory
            .appending(path: "no-existe-\(UUID().uuidString)")
        let resultado = RecordingMigrator.migrate(from: inexistente, to: inexistente)
        #expect(resultado == RecordingMigrator.Resultado())
    }
}

// MARK: - Disponibilidad con placeholder .icloud

struct RecordingAvailabilityTests {

    private func makeStore() throws -> RecordingStore {
        let dir = FileManager.default.temporaryDirectory
            .appending(path: "AvailabilityTests-\(UUID().uuidString)")
        let store = RecordingStore(directoryURL: dir)
        try store.ensureDirectoryExists()
        return store
    }

    @Test func archivoPresenteEsDisponible() throws {
        let store = try makeStore()
        let id = UUID()
        try Data("audio".utf8).write(to: store.url(forGrabacionId: id))

        let estado = store.availability(forGrabacionId: id)
        #expect(estado == .disponible(store.url(forGrabacionId: id)))
    }

    @Test func placeholderICloudEsDescargando() throws {
        let store = try makeStore()
        let id = UUID()
        // Un archivo evictado del contenedor ubicuo aparece como
        // ".<nombre>.icloud" hasta que se descarga.
        let placeholder = store.directoryURL.appending(path: ".\(id.uuidString).m4a.icloud")
        try Data().write(to: placeholder)

        #expect(store.availability(forGrabacionId: id) == .descargando)
    }

    @Test func sinArchivoNiPlaceholderEsAusente() throws {
        let store = try makeStore()
        #expect(store.availability(forGrabacionId: UUID()) == .ausente)
    }
}
