//
//  AttemptDetailView.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import SwiftUI
import SwiftData

struct AttemptDetailView: View {
    let attempt: Attempt

    @Environment(\.modelContext) private var modelContext
    @Environment(AppEnvironment.self) private var environment
    @State private var newNoteText = ""
    @State private var editingNoteID: UUID?
    @State private var editingNoteText = ""
    @State private var playback = PlaybackController()
    @State private var exporting = false
    @State private var exportURL: URL?
    @State private var recordingState: RecordingStore.Availability = .missing

    private var sortedNotes: [Note] {
        (attempt.notes ?? []).sorted { $0.createdAt < $1.createdAt }
    }

    var body: some View {
        List {
            Section("Intento") {
                LabeledContent("Fecha") {
                    Text(attempt.startedAt.formatted(date: .long, time: .shortened))
                }
                LabeledContent("Duración") {
                    Text(formatDuration(attempt.duration))
                }
                LabeledContent("Estado") {
                    Text(attempt.isCompleted ? "Completado" : "Sin completar")
                }
            }

            if attempt.recording != nil {
                Section("Grabación") {
                    switch recordingState {
                    case .available:
                        if playback.isAvailable {
                            HStack(spacing: 16) {
                                Button {
                                    playback.toggle()
                                } label: {
                                    Image(systemName: playback.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                        .font(.system(size: 44))
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(playback.isPlaying ? "Pausar" : "Reproducir")

                                VStack(alignment: .leading, spacing: 6) {
                                    ProgressView(value: playback.progress, total: max(playback.duration, 1))
                                    HStack {
                                        Text(formatDuration(playback.progress))
                                        Spacer()
                                        Text(formatDuration(playback.duration))
                                    }
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .monospacedDigit()
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    case .downloading:
                        HStack(spacing: 12) {
                            ProgressView()
                            Text("Descargando de iCloud…")
                                .foregroundStyle(.secondary)
                        }
                        .accessibilityElement(children: .combine)
                    case .missing:
                        Label("Grabación no disponible", systemImage: "waveform.slash")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Notas") {
                ForEach(sortedNotes) { note in
                    if editingNoteID == note.id {
                        // Edición en línea: createdAt no cambia — la nota
                        // registra cuándo se hizo la observación, no
                        // cuándo se corrigió la errata.
                        HStack {
                            TextField("Nota", text: $editingNoteText, axis: .vertical)
                                .accessibilityLabel("Editar nota")
                            Button {
                                saveEditedNote(note)
                            } label: {
                                Image(systemName: "checkmark.circle.fill")
                            }
                            .accessibilityLabel("Guardar cambios")
                            .disabled(editingNoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    } else {
                        Button {
                            editingNoteID = note.id
                            editingNoteText = note.content
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(note.content)
                                    .foregroundStyle(.primary)
                                Text(note.createdAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityHint("Toca para editar la nota")
                    }
                }
                // Swipe sin alerta: la pérdida es una nota, proporcional
                // al gesto (contraste deliberado con descartar grabación).
                .onDelete(perform: deleteNotes)
                HStack {
                    TextField("Añadir nota…", text: $newNoteText, axis: .vertical)
                        .accessibilityLabel("Nueva nota")
                    Button {
                        addNote()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityLabel("Guardar nota")
                    .disabled(newNoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .editorialBackground()
        .navigationTitle(attempt.topic?.displayName ?? String(localized: "Intento"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Curación del usuario, no juicio: el destacado vive donde
            // se escucha y se decide "esta es la buena".
            ToolbarItem(placement: .primaryAction) {
                Button {
                    attempt.isHighlighted.toggle()
                } label: {
                    Label(
                        attempt.isHighlighted ? "Quitar destacado" : "Destacar intento",
                        systemImage: attempt.isHighlighted ? "star.fill" : "star"
                    )
                }
                .tint(attempt.isHighlighted ? Color.amber : nil)
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    export()
                } label: {
                    if exporting {
                        ProgressView()
                    } else {
                        Label("Compartir intento", systemImage: "square.and.arrow.up")
                    }
                }
                .disabled(exporting)
            }
        }
        .sheet(item: $exportURL) { url in
            ShareSheet(url: url) {
                try? FileManager.default.removeItem(at: url.deletingLastPathComponent())
                exportURL = nil
            }
        }
        .task {
            await watchRecording()
        }
        .onDisappear {
            playback.stop()
        }
    }

    /// Evalúa la disponibilidad de la grabación; si está descargándose de
    /// iCloud, sondea hasta que aparezca el archivo (la tarea se cancela
    /// sola al salir de la vista).
    private func watchRecording() async {
        guard let recording = attempt.recording else { return }
        while !Task.isCancelled {
            let state = environment.recordingStore.availability(
                forRecordingID: recording.id,
                format: recording.format
            )
            recordingState = state
            switch state {
            case .available(let url):
                if !playback.isAvailable {
                    playback.load(url: url)
                }
                return
            case .missing:
                return
            case .downloading:
                try? await Task.sleep(for: .milliseconds(600))
            }
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
                let package = try service.buildAttemptPackage(attempt: attempt)
                exportURL = try ExportArchiver.zip(directory: package)
                try? FileManager.default.removeItem(at: package.deletingLastPathComponent())
            } catch {
                // Sin alerta dedicada: el botón vuelve a estar disponible.
            }
        }
    }

    private func saveEditedNote(_ note: Note) {
        let content = editingNoteText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }
        note.content = content
        editingNoteID = nil
        editingNoteText = ""
    }

    private func deleteNotes(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sortedNotes[index])
        }
    }

    private func addNote() {
        let content = newNoteText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }
        modelContext.insert(Note(attempt: attempt, content: content))
        newNoteText = ""
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
    let topic = Topic(number: 42, syllabus: syllabus)
    container.mainContext.insert(topic)
    let session = PracticeSession()
    container.mainContext.insert(session)
    let attempt = Attempt(topic: topic, session: session)
    attempt.duration = 708
    container.mainContext.insert(attempt)
    container.mainContext.insert(Note(attempt: attempt, content: "Demasiado rápido al inicio."))

    return NavigationStack {
        AttemptDetailView(attempt: attempt)
    }
    .modelContainer(container)
    .environment(AppEnvironment(mode: .local))
}
