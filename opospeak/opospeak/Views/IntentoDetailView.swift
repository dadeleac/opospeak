//
//  IntentoDetailView.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import SwiftUI
import SwiftData

struct IntentoDetailView: View {
    let intento: Intento

    @Environment(\.modelContext) private var modelContext
    @State private var nuevaNota = ""
    @State private var playback = PlaybackController()
    @State private var exportando = false
    @State private var exportURL: URL?

    private let recordingStore = RecordingStore()

    private var notasOrdenadas: [Nota] {
        (intento.notas ?? []).sorted { $0.fechaCreacion < $1.fechaCreacion }
    }

    var body: some View {
        List {
            Section("Intento") {
                LabeledContent("Fecha") {
                    Text(intento.fechaInicio.formatted(date: .long, time: .shortened))
                }
                LabeledContent("Duración") {
                    Text(formatearDuracion(intento.duracionReal))
                }
                LabeledContent("Estado") {
                    Text(intento.completado ? "Completado" : "Sin completar")
                }
            }

            if let grabacion = intento.grabacion {
                Section("Grabación") {
                    if playback.disponible {
                        HStack(spacing: 16) {
                            Button {
                                playback.alternar()
                            } label: {
                                Image(systemName: playback.reproduciendo ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 44))
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(playback.reproduciendo ? "Pausar" : "Reproducir")

                            VStack(alignment: .leading, spacing: 6) {
                                ProgressView(value: playback.progreso, total: max(playback.duracion, 1))
                                HStack {
                                    Text(formatearDuracion(playback.progreso))
                                    Spacer()
                                    Text(formatearDuracion(playback.duracion))
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                            }
                        }
                        .padding(.vertical, 4)
                    } else {
                        Label("Grabación no disponible", systemImage: "waveform.slash")
                            .foregroundStyle(.secondary)
                    }
                }
                .onAppear {
                    if let url = recordingStore.existingURL(
                        forGrabacionId: grabacion.id,
                        formato: grabacion.formato
                    ) {
                        playback.cargar(url: url)
                    }
                }
            }

            Section("Notas") {
                ForEach(notasOrdenadas) { nota in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(nota.contenido)
                        Text(nota.fechaCreacion.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                }
                HStack {
                    TextField("Añadir nota…", text: $nuevaNota, axis: .vertical)
                        .accessibilityLabel("Nueva nota")
                    Button {
                        anadirNota()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityLabel("Guardar nota")
                    .disabled(nuevaNota.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .navigationTitle(intento.tema?.nombreVisible ?? "Intento")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    exportar()
                } label: {
                    if exportando {
                        ProgressView()
                    } else {
                        Label("Compartir intento", systemImage: "square.and.arrow.up")
                    }
                }
                .disabled(exportando)
            }
        }
        .sheet(item: $exportURL) { url in
            ShareSheet(url: url) {
                try? FileManager.default.removeItem(at: url.deletingLastPathComponent())
                exportURL = nil
            }
        }
        .onDisappear {
            playback.detener()
        }
    }

    private func exportar() {
        exportando = true
        Task {
            defer { exportando = false }
            do {
                let service = ExportService(modelContext: modelContext, recordingStore: recordingStore)
                let paquete = try service.buildIntentoPackage(intento: intento)
                exportURL = try ExportArchiver.zip(directory: paquete)
                try? FileManager.default.removeItem(at: paquete.deletingLastPathComponent())
            } catch {
                // Sin alerta dedicada: el botón vuelve a estar disponible.
            }
        }
    }

    private func anadirNota() {
        let contenido = nuevaNota.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !contenido.isEmpty else { return }
        modelContext.insert(Nota(intento: intento, contenido: contenido))
        nuevaNota = ""
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Temario.self, Tema.self, Sesion.self, Intento.self,
        Grabacion.self, Metrica.self, Nota.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let temario = Temario(nombre: "Judicatura")
    container.mainContext.insert(temario)
    let tema = Tema(numero: 42, temario: temario)
    container.mainContext.insert(tema)
    let sesion = Sesion()
    container.mainContext.insert(sesion)
    let intento = Intento(tema: tema, sesion: sesion)
    intento.duracionReal = 708
    container.mainContext.insert(intento)
    container.mainContext.insert(Nota(intento: intento, contenido: "Demasiado rápido al inicio."))

    return NavigationStack {
        IntentoDetailView(intento: intento)
    }
    .modelContainer(container)
}
