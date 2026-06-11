//
//  SettingsView.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import SwiftUI
import SwiftData

// Ajustes contiene solo lo que no pertenece al flujo de práctica
// (define-information-architecture). No es un cajón de funcionalidades.
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppEnvironment.self) private var environment
    @Query(sort: \Opposition.createdAt) private var oppositions: [Opposition]

    @State private var exporting = false
    @State private var exportURL: URL?
    @State private var exportFailed = false
    @State private var editingOpposition = false
    @State private var oppositionName = ""

    private var activeOpposition: Opposition? {
        if let idString = UserDefaults.standard.string(forKey: ActiveOpposition.storageKey),
           let id = UUID(uuidString: idString),
           let chosen = oppositions.first(where: { $0.id == id }) {
            return chosen
        }
        return oppositions.first
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    var body: some View {
        List {
            Section {
                Label {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tus datos son tuyos")
                            .font(.headline)
                        Text("Todo se guarda en tu dispositivo. Sin cuenta, sin servidores propios. Podrás exportarlo todo, siempre.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "lock.shield")
                }
                .accessibilityElement(children: .combine)
            } header: {
                Text("Privacidad")
            }

            if let opposition = activeOpposition {
                Section {
                    Button {
                        oppositionName = opposition.name
                        editingOpposition = true
                    } label: {
                        LabeledContent {
                            Text(opposition.name)
                                .foregroundStyle(.secondary)
                        } label: {
                            Label("Nombre", systemImage: "graduationcap")
                        }
                    }
                    .accessibilityHint("Cambia el nombre de tu oposición")
                } header: {
                    Text("Oposición")
                } footer: {
                    Text("La oposición agrupa tus temarios. Por ejemplo: Judicatura, con los temarios Civil, Penal y Procesal.")
                }
            }

            Section {
                Button {
                    export()
                } label: {
                    HStack {
                        Label("Exportar mis datos", systemImage: "square.and.arrow.up")
                        Spacer()
                        if exporting {
                            ProgressView()
                        }
                    }
                }
                .disabled(exporting)
                .accessibilityHint("Genera un paquete con todos tus datos y grabaciones")

                LabeledContent {
                    Text(environment.syncStatus.statusDescription)
                        .foregroundStyle(.secondary)
                } label: {
                    Label("Sincronización iCloud", systemImage: "icloud")
                }
                .accessibilityElement(children: .combine)
            } header: {
                Text("Datos")
            } footer: {
                Text("El paquete incluye todos tus temarios, temas, intentos, notas y grabaciones en formatos abiertos (JSON, CSV, m4a).")
            }

            Section("Aplicación") {
                LabeledContent("Versión", value: appVersion)
            }
        }
        .editorialBackground()
        .navigationTitle("Ajustes")
        .sheet(item: $exportURL) { url in
            ShareSheet(url: url) {
                cleanUpTemporary(url)
                exportURL = nil
            }
        }
        .alert("Nombre de la oposición", isPresented: $editingOpposition) {
            TextField("Nombre", text: $oppositionName)
            Button("Guardar") { renameOpposition() }
            Button("Cancelar", role: .cancel) {}
        }
        .alert("No se pudo exportar", isPresented: $exportFailed) {
            Button("Aceptar", role: .cancel) {}
        } message: {
            Text("Inténtalo de nuevo. Si el problema continúa, comprueba el espacio disponible.")
        }
    }

    private func export() {
        exporting = true
        Task {
            defer { exporting = false }
            do {
                let service = ExportService(
                    modelContext: modelContext,
                    recordingStore: environment.recordingStore
                )
                let package = try service.buildFullPackage()
                exportURL = try ExportArchiver.zip(directory: package)
                try? FileManager.default.removeItem(at: package.deletingLastPathComponent())
            } catch {
                exportFailed = true
            }
        }
    }

    private func renameOpposition() {
        let trimmed = oppositionName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let opposition = activeOpposition else { return }
        opposition.name = trimmed
        opposition.updatedAt = .now
    }

    private func cleanUpTemporary(_ url: URL) {
        try? FileManager.default.removeItem(at: url.deletingLastPathComponent())
    }
}

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(AppEnvironment(mode: .local))
}
