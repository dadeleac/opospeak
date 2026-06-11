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

    @Test func withoutUbiquityResolvesLocal() {
        #expect(RecordingLocation.resolve(ubiquity: nil) == RecordingLocation.localURL)
    }

    @Test func withUbiquityUsesIt() {
        let ubiquity = URL(fileURLWithPath: "/ubiquity/Documents/Recordings")
        #expect(RecordingLocation.resolve(ubiquity: ubiquity) == ubiquity)
    }
}

// MARK: - RecordingMigrator

struct RecordingMigratorTests {

    private func makeDirs() throws -> (source: URL, destination: URL) {
        let base = FileManager.default.temporaryDirectory
            .appending(path: "MigratorTests-\(UUID().uuidString)")
        let source = base.appending(path: "local", directoryHint: .isDirectory)
        let destination = base.appending(path: "ubiquity", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: source, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
        return (source, destination)
    }

    private func createAudio(_ name: String, in dir: URL, content: String = "audio") throws {
        try Data(content.utf8).write(to: dir.appending(path: name))
    }

    @Test func migratesM4aFiles() throws {
        let (source, destination) = try makeDirs()
        try createAudio("a.m4a", in: source)
        try createAudio("b.m4a", in: source)
        try createAudio("other.txt", in: source)

        let result = RecordingMigrator.migrate(from: source, to: destination)

        #expect(result.migrated == 2)
        #expect(result.failed == 0)
        let fm = FileManager.default
        #expect(fm.fileExists(atPath: destination.appending(path: "a.m4a").path(percentEncoded: false)))
        #expect(fm.fileExists(atPath: destination.appending(path: "b.m4a").path(percentEncoded: false)))
        // Los m4a desaparecen del origen; otros archivos no se tocan.
        #expect(!fm.fileExists(atPath: source.appending(path: "a.m4a").path(percentEncoded: false)))
        #expect(fm.fileExists(atPath: source.appending(path: "other.txt").path(percentEncoded: false)))
    }

    @Test func isIdempotent() throws {
        let (source, destination) = try makeDirs()
        try createAudio("a.m4a", in: source)

        let firstPass = RecordingMigrator.migrate(from: source, to: destination)
        #expect(firstPass.migrated == 1)

        let secondPass = RecordingMigrator.migrate(from: source, to: destination)
        #expect(secondPass == RecordingMigrator.MigrationResult())
    }

    @Test func alreadyMigratedDuplicateIsRemovedWithoutOverwriting() throws {
        let (source, destination) = try makeDirs()
        try createAudio("a.m4a", in: destination, content: "icloud-version")
        try createAudio("a.m4a", in: source, content: "local-version")

        let result = RecordingMigrator.migrate(from: source, to: destination)

        #expect(result.skipped == 1)
        #expect(result.migrated == 0)
        // El destino conserva su versión; el duplicado local se retira.
        let content = try String(
            contentsOf: destination.appending(path: "a.m4a"), encoding: .utf8
        )
        #expect(content == "icloud-version")
        #expect(!FileManager.default.fileExists(
            atPath: source.appending(path: "a.m4a").path(percentEncoded: false)
        ))
    }

    @Test func missingSourceDoesNotFail() {
        let missing = FileManager.default.temporaryDirectory
            .appending(path: "missing-\(UUID().uuidString)")
        let result = RecordingMigrator.migrate(from: missing, to: missing)
        #expect(result == RecordingMigrator.MigrationResult())
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

    @Test func presentFileIsAvailable() throws {
        let store = try makeStore()
        let id = UUID()
        try Data("audio".utf8).write(to: store.url(forRecordingID: id))

        let state = store.availability(forRecordingID: id)
        #expect(state == .available(store.url(forRecordingID: id)))
    }

    @Test func icloudPlaceholderIsDownloading() throws {
        let store = try makeStore()
        let id = UUID()
        // Un archivo evictado del contenedor ubicuo aparece como
        // ".<nombre>.icloud" hasta que se descarga.
        let placeholder = store.directoryURL.appending(path: ".\(id.uuidString).m4a.icloud")
        try Data().write(to: placeholder)

        #expect(store.availability(forRecordingID: id) == .downloading)
    }

    @Test func neitherFileNorPlaceholderIsMissing() throws {
        let store = try makeStore()
        #expect(store.availability(forRecordingID: UUID()) == .missing)
    }
}
