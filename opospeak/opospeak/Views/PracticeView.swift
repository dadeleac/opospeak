//
//  PracticeView.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import SwiftUI
import SwiftData

// La experiencia central del producto (define-practice-session-flow):
// la interfaz desaparece — cronómetro, estado de grabación y finalizar.
struct PracticeView: View {
    let tema: Tema

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppEnvironment.self) private var entorno

    @State private var recorder: PracticeRecorder?
    @State private var resumen: ResumenPractica?

    private struct ResumenPractica {
        let duracion: TimeInterval
        let fecha: Date
    }

    var body: some View {
        NavigationStack {
            Group {
                if let recorder {
                    switch recorder.estado {
                    case .inactivo:
                        ProgressView()
                    case .grabando:
                        grabando(recorder)
                    case .finalizado:
                        if let resumen {
                            resumenView(resumen)
                        }
                    case .permisoDenegado:
                        permisoDenegado
                    case .fallo(let mensaje):
                        fallo(mensaje)
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle(tema.nombreVisible)
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            guard recorder == nil else { return }
            let nuevo = PracticeRecorder(recordingStore: entorno.recordingStore)
            recorder = nuevo
            await nuevo.comenzar()
        }
        .interactiveDismissDisabled(recorder?.estado == .grabando)
        .onChange(of: recorder?.estado == .grabando, initial: true) { _, grabando in
            UIApplication.shared.isIdleTimerDisabled = grabando
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }

    // MARK: - Grabando

    private func grabando(_ recorder: PracticeRecorder) -> some View {
        VStack(spacing: 32) {
            Spacer()

            HStack(spacing: 8) {
                Circle()
                    .fill(.red)
                    .frame(width: 12, height: 12)
                Text("Grabando")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)

            Text(formatearDuracion(recorder.transcurrido))
                .font(.system(.largeTitle, design: .rounded, weight: .light))
                .monospacedDigit()
                .accessibilityLabel("Tiempo transcurrido")
                .accessibilityValue(formatearDuracion(recorder.transcurrido))

            Spacer()

            Button {
                finalizar()
            } label: {
                Label("Finalizar", systemImage: "stop.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal)

            Button("Descartar práctica", role: .destructive) {
                descartar()
            }
            .font(.subheadline)
            .padding(.bottom)
        }
    }

    // MARK: - Resumen

    private func resumenView(_ resumen: ResumenPractica) -> some View {
        List {
            Section {
                LabeledContent("Tema", value: tema.nombreVisible)
                LabeledContent("Duración", value: formatearDuracion(resumen.duracion))
                LabeledContent("Fecha") {
                    Text(resumen.fecha.formatted(date: .long, time: .shortened))
                }
                Label("Grabación guardada", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } header: {
                Text("Práctica completada")
            } footer: {
                Text("El intento ya forma parte del historial de este tema.")
            }

            Section {
                Button {
                    dismiss()
                } label: {
                    Text("Hecho")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    // MARK: - Permiso y errores

    private var permisoDenegado: some View {
        ContentUnavailableView {
            Label("Micrófono no disponible", systemImage: "mic.slash")
        } description: {
            Text("OpoSpeak necesita el micrófono para grabar tu práctica oral. Puedes permitirlo en Ajustes del sistema.")
        } actions: {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                Link("Abrir Ajustes", destination: url)
                    .buttonStyle(.borderedProminent)
            }
            Button("Cerrar") { dismiss() }
        }
    }

    private func fallo(_ mensaje: String) -> some View {
        ContentUnavailableView {
            Label("No se pudo grabar", systemImage: "exclamationmark.triangle")
        } description: {
            Text(mensaje)
        } actions: {
            Button("Cerrar") { dismiss() }
        }
    }

    // MARK: - Acciones

    private func finalizar() {
        guard let recorder else { return }
        recorder.finalizar()
        guard let inicio = recorder.fechaInicio, let fin = recorder.fechaFin else {
            dismiss()
            return
        }

        let service = PracticeService(
            modelContext: modelContext,
            recordingStore: entorno.recordingStore
        )
        do {
            try service.finish(tema: tema, grabacionId: recorder.grabacionId, inicio: inicio, fin: fin)
            resumen = ResumenPractica(duracion: fin.timeIntervalSince(inicio), fecha: fin)
        } catch {
            recorder.descartar()
            dismiss()
        }
    }

    private func descartar() {
        recorder?.descartar()
        dismiss()
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
    let tema = Tema(numero: 42, titulo: "Responsabilidad patrimonial", temario: temario)
    container.mainContext.insert(tema)

    return PracticeView(tema: tema)
        .modelContainer(container)
        .environment(AppEnvironment(modo: .local))
}
