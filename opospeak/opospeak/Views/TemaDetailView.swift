//
//  TemaDetailView.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import SwiftUI
import SwiftData

// Centro de gravedad de la aplicación (define-information-architecture):
// info del tema, historial de intentos y la acción Practicar prominente.
struct TemaDetailView: View {
    let tema: Tema

    @State private var practicando = false
    @State private var editando = false

    private var intentosOrdenados: [Intento] {
        (tema.intentos ?? []).sorted { $0.fechaInicio > $1.fechaInicio }
    }

    var body: some View {
        List {
            Section {
                Button {
                    practicando = true
                } label: {
                    Label("Practicar", systemImage: "mic.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .accessibilityHint("Inicia la grabación de una práctica oral de este tema")
            }

            if !intentosOrdenados.isEmpty {
                Section("Historial") {
                    ForEach(intentosOrdenados) { intento in
                        NavigationLink(value: intento) {
                            IntentoRow(intento: intento)
                        }
                    }
                }
            }
        }
        .fondoEditorial()
        .navigationTitle(tema.nombreVisible)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    editando = true
                } label: {
                    Label("Editar tema", systemImage: "pencil")
                }
            }
        }
        .sheet(isPresented: $editando) {
            EditarTemaSheet(tema: tema)
        }
        .fullScreenCover(isPresented: $practicando) {
            PracticeView(tema: tema)
        }
        .overlay {
            if intentosOrdenados.isEmpty {
                ContentUnavailableView {
                    Label("Sin intentos", systemImage: "mic")
                } description: {
                    Text("Cuando practiques este tema, tu historial aparecerá aquí.")
                }
                .allowsHitTesting(false)
            }
        }
    }
}

/// Edición de número y título (tema-editing). El título puede quedar
/// vacío — el tema vuelve a mostrarse como "Tema N". Los títulos nunca
/// son obligatorios para practicar.
struct EditarTemaSheet: View {
    let tema: Tema

    @Environment(\.dismiss) private var dismiss

    @State private var numero: Int = 1
    @State private var titulo = ""

    private var numeroDisponible: Bool {
        guard numero != tema.numero else { return true }
        return !(tema.temario?.numerosExistentes.contains(numero) ?? false)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Stepper(value: $numero, in: 1...9999) {
                        HStack {
                            Text("Número")
                            Spacer()
                            Text("\(numero)")
                                .foregroundStyle(numeroDisponible ? .secondary : Color.rojoApagado)
                        }
                    }
                    .accessibilityLabel("Número de tema")
                    .accessibilityValue("\(numero)")
                } footer: {
                    if !numeroDisponible {
                        Text("Ya existe un tema con el número \(numero) en este temario.")
                    }
                }
                Section {
                    TextField("Título", text: $titulo)
                        .accessibilityLabel("Título del tema")
                } footer: {
                    Text("Puedes dejarlo vacío: el tema se mostrará como \"Tema \(numero)\".")
                }
            }
            .navigationTitle("Editar tema")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { guardar() }
                        .disabled(!numeroDisponible)
                }
            }
            .onAppear {
                numero = tema.numero
                titulo = tema.titulo ?? ""
            }
        }
    }

    private func guardar() {
        let limpio = titulo.trimmingCharacters(in: .whitespacesAndNewlines)
        tema.numero = numero
        tema.titulo = limpio.isEmpty ? nil : limpio
        tema.fechaActualizacion = .now
        dismiss()
    }
}

struct IntentoRow: View {
    let intento: Intento

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(intento.fechaInicio.formatted(date: .abbreviated, time: .shortened))
                    .font(.headline)
                Text(formatearDuracion(intento.duracionReal))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            HStack(spacing: 8) {
                if intento.grabacion != nil {
                    Image(systemName: "waveform")
                        .accessibilityLabel("Con grabación")
                }
                if intento.notas?.isEmpty == false {
                    Image(systemName: "note.text")
                        .accessibilityLabel("Con notas")
                }
            }
            .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Oposicion.self, Temario.self, Tema.self, Sesion.self, Intento.self,
        Grabacion.self, Metrica.self, Nota.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let oposicion = Oposicion(nombre: "Judicatura")
    container.mainContext.insert(oposicion)
    let temario = Temario(nombre: "Civil", oposicion: oposicion)
    container.mainContext.insert(temario)
    let tema = Tema(numero: 42, titulo: "Responsabilidad patrimonial", temario: temario)
    container.mainContext.insert(tema)
    let sesion = Sesion()
    container.mainContext.insert(sesion)
    let intento = Intento(tema: tema, sesion: sesion)
    intento.duracionReal = 708
    intento.completado = true
    container.mainContext.insert(intento)

    return NavigationStack {
        TemaDetailView(tema: tema)
            .navigationDestination(for: Intento.self) { IntentoDetailView(intento: $0) }
    }
    .modelContainer(container)
    .environment(AppEnvironment(modo: .local))
}
