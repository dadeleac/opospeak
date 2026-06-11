//
//  AjustesView.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import SwiftUI

// Ajustes contiene solo lo que no pertenece al flujo de práctica
// (define-information-architecture). No es un cajón de funcionalidades.
struct AjustesView: View {
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

            Section("Datos") {
                LabeledContent {
                    Text("Próximamente")
                        .foregroundStyle(.secondary)
                } label: {
                    Label("Exportar mis datos", systemImage: "square.and.arrow.up")
                }
                LabeledContent {
                    Text("Próximamente")
                        .foregroundStyle(.secondary)
                } label: {
                    Label("Sincronización iCloud", systemImage: "icloud")
                }
            }

            Section("Aplicación") {
                LabeledContent("Versión", value: version)
            }
        }
        .navigationTitle("Ajustes")
    }
}

#Preview {
    NavigationStack {
        AjustesView()
    }
}
