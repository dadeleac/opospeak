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
    let topic: Topic

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppEnvironment.self) private var environment

    @State private var recorder: PracticeRecorder?
    @State private var summary: PracticeSummary?

    private struct PracticeSummary {
        let duration: TimeInterval
        let date: Date
    }

    var body: some View {
        NavigationStack {
            Group {
                if let recorder {
                    switch recorder.state {
                    case .idle:
                        ProgressView()
                    case .recording, .paused:
                        recordingView(recorder)
                    case .finished:
                        if let summary {
                            summaryView(summary)
                        }
                    case .permissionDenied:
                        permissionDeniedView
                    case .failed(let message):
                        failureView(message)
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle(topic.displayName)
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            guard recorder == nil else { return }
            let newRecorder = PracticeRecorder(recordingStore: environment.recordingStore)
            recorder = newRecorder
            await newRecorder.start()
        }
        .interactiveDismissDisabled(recorder?.state == .recording || recorder?.state == .paused)
        // La pantalla solo se mantiene despierta grabando; en pausa puede
        // dormirse (la práctica sobrevive en el archivo).
        .onChange(of: recorder?.state == .recording, initial: true) { _, isRecording in
            UIApplication.shared.isIdleTimerDisabled = isRecording
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }

    // MARK: - Grabando

    private func recordingView(_ recorder: PracticeRecorder) -> some View {
        let isPaused = recorder.state == .paused

        return VStack(spacing: 32) {
            Spacer()

            // Dos temperaturas inequívocas: color + icono + texto,
            // nunca solo color.
            HStack(spacing: 8) {
                if isPaused {
                    Image(systemName: "pause.fill")
                        .font(.caption)
                        .foregroundStyle(Color.amber)
                    Text("En pausa")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Circle()
                        .fill(Color.mutedRed)
                        .frame(width: 12, height: 12)
                    Text("Grabando")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityElement(children: .combine)

            Text(formatDuration(recorder.elapsed))
                .font(.system(.largeTitle, design: .rounded, weight: .light))
                .monospacedDigit()
                .foregroundStyle(isPaused ? .secondary : .primary)
                .accessibilityLabel(isPaused ? "Tiempo grabado, en pausa" : "Tiempo transcurrido")
                .accessibilityValue(formatDuration(recorder.elapsed))

            Spacer()

            Button {
                isPaused ? recorder.resume() : recorder.pause()
            } label: {
                Label(
                    isPaused ? "Reanudar" : "Pausar",
                    systemImage: isPaused ? "play.fill" : "pause.fill"
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal)

            Button {
                finish()
            } label: {
                Label("Finalizar", systemImage: "stop.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .padding(.horizontal)

            Button("Descartar práctica", role: .destructive) {
                discard()
            }
            .tint(.mutedRed)
            .font(.subheadline)
            .padding(.bottom)
        }
    }

    // MARK: - Resumen

    private func summaryView(_ summary: PracticeSummary) -> some View {
        List {
            Section {
                LabeledContent("Tema", value: topic.displayName)
                LabeledContent("Duración", value: formatDuration(summary.duration))
                LabeledContent("Fecha") {
                    Text(summary.date.formatted(date: .long, time: .shortened))
                }
                Label("Grabación guardada", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(Color.sage)
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

    private var permissionDeniedView: some View {
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

    private func failureView(_ message: String) -> some View {
        ContentUnavailableView {
            Label("No se pudo grabar", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Cerrar") { dismiss() }
        }
    }

    // MARK: - Acciones

    private func finish() {
        guard let recorder else { return }
        recorder.finish()
        guard let startedAt = recorder.startedAt, let endedAt = recorder.endedAt else {
            dismiss()
            return
        }

        let service = PracticeService(
            modelContext: modelContext,
            recordingStore: environment.recordingStore
        )
        do {
            // Duración = tiempo realmente grabado, no tiempo de pared:
            // una práctica con pausas dura lo que dura su audio.
            try service.finish(
                topic: topic,
                recordingID: recorder.recordingID,
                startedAt: startedAt,
                endedAt: endedAt,
                duration: recorder.elapsed
            )
            summary = PracticeSummary(duration: recorder.elapsed, date: endedAt)
        } catch {
            recorder.discard()
            dismiss()
        }
    }

    private func discard() {
        recorder?.discard()
        dismiss()
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Opposition.self, Syllabus.self, Topic.self, PracticeSession.self,
        Attempt.self, Recording.self, Metric.self, Note.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let opposition = Opposition(name: "Judicatura")
    container.mainContext.insert(opposition)
    let syllabus = Syllabus(name: "Civil", opposition: opposition)
    container.mainContext.insert(syllabus)
    let topic = Topic(number: 42, title: "Responsabilidad patrimonial", syllabus: syllabus)
    container.mainContext.insert(topic)

    return PracticeView(topic: topic)
        .modelContainer(container)
        .environment(AppEnvironment(mode: .local))
}
