//
//  AjustesView.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import SwiftUI
import SwiftData

// Ajustes contiene solo lo que no pertenece al flujo de práctica
// (define-information-architecture). No es un cajón de funcionalidades.
struct AjustesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppEnvironment.self) private var entorno
    @Query(sort: \Oposicion.fechaCreacion) private var oposiciones: [Oposicion]

    @State private var exportando = false
    @State private var exportURL: URL?
    @State private var exportError = false
    @State private var editandoOposicion = false
    @State private var nombreOposicion = ""

    private var oposicionActiva: Oposicion? {
        if let idString = UserDefaults.standard.string(forKey: OposicionActiva.storageKey),
           let id = UUID(uuidString: idString),
           let elegida = oposiciones.first(where: { $0.id == id }) {
            return elegida
        }
        return oposiciones.first
    }

    private var version: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(build))"
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

            if let oposicion = oposicionActiva {
                Section {
                    Button {
                        nombreOposicion = oposicion.nombre
                        editandoOposicion = true
                    } label: {
                        LabeledContent {
                            Text(oposicion.nombre)
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
                    exportar()
                } label: {
                    HStack {
                        Label("Exportar mis datos", systemImage: "square.and.arrow.up")
                        Spacer()
                        if exportando {
                            ProgressView()
                        }
                    }
                }
                .disabled(exportando)
                .accessibilityHint("Genera un paquete con todos tus datos y grabaciones")

                LabeledContent {
                    Text(entorno.syncStatus.descripcion)
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
                LabeledContent("Versión", value: version)
            }
        }
        .fondoEditorial()
        .navigationTitle("Ajustes")
        .sheet(item: $exportURL) { url in
            ShareSheet(url: url) {
                limpiarTemporal(url)
                exportURL = nil
            }
        }
        .alert("Nombre de la oposición", isPresented: $editandoOposicion) {
            TextField("Nombre", text: $nombreOposicion)
            Button("Guardar") { renombrarOposicion() }
            Button("Cancelar", role: .cancel) {}
        }
        .alert("No se pudo exportar", isPresented: $exportError) {
            Button("Aceptar", role: .cancel) {}
        } message: {
            Text("Inténtalo de nuevo. Si el problema continúa, comprueba el espacio disponible.")
        }
    }

    private func exportar() {
        exportando = true
        Task {
            defer { exportando = false }
            do {
                let service = ExportService(modelContext: modelContext, recordingStore: entorno.recordingStore)
                let paquete = try service.buildFullPackage()
                exportURL = try ExportArchiver.zip(directory: paquete)
                try? FileManager.default.removeItem(at: paquete.deletingLastPathComponent())
            } catch {
                exportError = true
            }
        }
    }

    private func renombrarOposicion() {
        let limpio = nombreOposicion.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !limpio.isEmpty, let oposicion = oposicionActiva else { return }
        oposicion.nombre = limpio
        oposicion.fechaActualizacion = .now
    }

    private func limpiarTemporal(_ url: URL) {
        try? FileManager.default.removeItem(at: url.deletingLastPathComponent())
    }
}

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}

#Preview {
    NavigationStack {
        AjustesView()
    }
    .environment(AppEnvironment(modo: .local))
}
