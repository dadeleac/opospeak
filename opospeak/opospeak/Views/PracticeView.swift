//
//  PracticeView.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import SwiftUI
import SwiftData

// La experiencia central del producto (define-practice-session-flow):
// preparación explícita (modo de cronómetro, avisos) → Empezar → la
// interfaz desaparece. La grabación nunca arranca sin el toque del usuario.
struct PracticeView: View {
    let topic: Topic

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppEnvironment.self) private var environment

    @State private var recorder: PracticeRecorder?
    @State private var summary: PracticeSummary?
    @State private var config = PracticeTimerConfig.load()
    @State private var showingConfigSheet = false
    @State private var lastSeenElapsed: TimeInterval = 0
    @State private var flashingMark: TimeInterval?

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
                        readyView
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
                    preparationView
                }
            }
            .navigationTitle(topic.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancelar es libre mientras no se haya grabado nada.
                if recorder == nil || recorder?.state == .idle {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancelar") { dismiss() }
                    }
                }
            }
        }
        .interactiveDismissDisabled(recorder?.state == .recording || recorder?.state == .paused)
        // La pantalla solo se mantiene despierta grabando; en pausa puede
        // dormirse (la práctica sobrevive en el archivo).
        .onChange(of: recorder?.state == .recording, initial: true) { _, isRecording in
            UIApplication.shared.isIdleTimerDisabled = isRecording
        }
        .onChange(of: recorder?.elapsed ?? 0) { _, elapsed in
            handleWarnings(elapsed: elapsed)
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }

    // MARK: - Preparación (decidir)

    /// El resumen de la configuración en una línea, p. ej.
    /// "Cuenta atrás · 15 min · avisos 5′ y 1′".
    private var configSummary: String {
        guard config.mode == .countdown else {
            return String(localized: "Cronómetro")
        }
        let minutes = Int(config.targetDuration / 60)
        let marks = config.warningMarks
            .filter { $0 < config.targetDuration }
            .sorted(by: >)
            .map { "\(Int($0 / 60))′" }
        if marks.isEmpty {
            return String(localized: "Cuenta atrás · \(minutes) min")
        }
        return String(localized: "Cuenta atrás · \(minutes) min · avisos \(marks.joined(separator: " y "))")
    }

    /// Decisión habitual sin coste: chip de resumen + Continuar.
    /// El editor de configuración sube desde abajo como hoja del sistema
    /// (la modal nativa de las HIG) solo si el usuario quiere cambiar algo.
    private var preparationView: some View {
        List {
            Section {
                Button {
                    showingConfigSheet = true
                } label: {
                    HStack {
                        Label(configSummary, systemImage: "timer")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .accessibilityHint("Abre la configuración del cronómetro")
            }

            Section {
                Button {
                    continueToReady()
                } label: {
                    Text("Continuar")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .accessibilityHint("Pasa a la pantalla de grabación; todavía no se graba nada")
            }
        }
        .sheet(isPresented: $showingConfigSheet) {
            TimerConfigSheet(config: $config)
        }
    }

    // MARK: - Listo (colocar)

    /// El móvil puede colocarse en un soporte con calma: aquí no se graba
    /// nada todavía. Grabar es el único botón que enciende el micrófono.
    private var readyView: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("Coloca el móvil donde quieras.\nPulsa cuando estés preparado.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)

            Text(config.mode == .countdown ? formatDuration(config.targetDuration) : formatDuration(0))
                .font(.system(.largeTitle, design: .rounded, weight: .light))
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .accessibilityLabel(config.mode == .countdown ? "Tiempo objetivo" : "Cronómetro")
                .accessibilityValue(
                    config.mode == .countdown ? formatDuration(config.targetDuration) : formatDuration(0)
                )

            Spacer()

            Button {
                beginRecording()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "record.circle")
                    Text("Grabar")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal)
            .padding(.bottom)
            .accessibilityHint("Enciende el micrófono y empieza a grabar")
        }
    }

    /// Continuar: guarda la configuración, crea el recorder y pide el
    /// permiso de micrófono — para que el diálogo del sistema no
    /// interrumpa después de colocar el móvil. Todavía no se graba nada.
    private func continueToReady() {
        config.save()
        lastSeenElapsed = 0
        let newRecorder = PracticeRecorder(recordingStore: environment.recordingStore)
        recorder = newRecorder
        Task {
            await newRecorder.requestPermission()
        }
    }

    /// Grabar: el único botón que enciende el micrófono.
    private func beginRecording() {
        guard let recorder else { return }
        Task {
            await recorder.start()
        }
    }

    // MARK: - Grabando

    private var isOvertime: Bool {
        guard let recorder, config.mode == .countdown else { return false }
        return recorder.elapsed > config.targetDuration
    }

    private func timerText(_ elapsed: TimeInterval) -> String {
        guard config.mode == .countdown else { return formatDuration(elapsed) }
        let remaining = config.targetDuration - elapsed
        return remaining >= 0
            ? formatDuration(remaining)
            : "+" + formatDuration(-remaining)
    }

    private func recordingView(_ recorder: PracticeRecorder) -> some View {
        let isPaused = recorder.state == .paused

        return VStack(spacing: 32) {
            Spacer()

            // Estados inequívocos: color + icono + texto, nunca solo color.
            HStack(spacing: 8) {
                if isPaused {
                    Image(systemName: "pause.fill")
                        .font(.caption)
                        .foregroundStyle(Color.amber)
                    Text("En pausa")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else if isOvertime {
                    Image(systemName: "clock.badge.exclamationmark")
                        .font(.caption)
                        .foregroundStyle(Color.mutedRed)
                    Text("Tiempo agotado")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else if let mark = flashingMark {
                    Image(systemName: "bell.fill")
                        .font(.caption)
                        .foregroundStyle(Color.amber)
                    Text("Quedan \(Int(mark / 60)) min")
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

            Text(timerText(recorder.elapsed))
                .font(.system(.largeTitle, design: .rounded, weight: .light))
                .monospacedDigit()
                .foregroundStyle(
                    isPaused ? AnyShapeStyle(.secondary)
                        : isOvertime ? AnyShapeStyle(Color.mutedRed)
                        : AnyShapeStyle(.primary)
                )
                .accessibilityLabel(
                    config.mode == .countdown
                        ? (isOvertime ? "Tiempo excedido" : "Tiempo restante")
                        : "Tiempo transcurrido"
                )
                .accessibilityValue(timerText(recorder.elapsed))

            Spacer()

            Button {
                isPaused ? recorder.resume() : recorder.pause()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                    Text(isPaused ? "Reanudar" : "Pausar")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal)

            Button {
                finish()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "stop.fill")
                    Text("Finalizar")
                }
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

    // MARK: - Avisos

    /// Háptica + señal visual + anuncio de VoiceOver al cruzar cada marca.
    /// Nunca sonido: el micrófono está abierto. Las marcas corren sobre
    /// tiempo grabado, así que la pausa las congela sola.
    private func handleWarnings(elapsed: TimeInterval) {
        defer { lastSeenElapsed = elapsed }
        guard config.mode == .countdown else { return }

        let crossed = WarningSchedule.crossedMarks(
            target: config.targetDuration,
            marks: config.warningMarks,
            previousElapsed: lastSeenElapsed,
            elapsed: elapsed
        )
        guard let mark = crossed.last else { return }

        UINotificationFeedbackGenerator().notificationOccurred(.warning)

        if mark == 0 {
            AccessibilityNotification.Announcement(
                String(localized: "Tiempo agotado")
            ).post()
        } else {
            AccessibilityNotification.Announcement(
                String(localized: "Quedan \(Int(mark / 60)) minutos")
            ).post()
            flashingMark = mark
            Task {
                try? await Task.sleep(for: .seconds(4))
                if flashingMark == mark { flashingMark = nil }
            }
        }
    }

    // MARK: - Resumen

    private func summaryView(_ summary: PracticeSummary) -> some View {
        List {
            Section {
                LabeledContent("Tema", value: topic.displayName)
                LabeledContent("Duración", value: formatDuration(summary.duration))
                if config.mode == .countdown {
                    LabeledContent("Objetivo") {
                        Text(formatDuration(config.targetDuration))
                    }
                }
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
                duration: recorder.elapsed,
                targetDuration: config.mode == .countdown ? config.targetDuration : nil
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

/// Editor de la configuración del cronómetro. Sube desde abajo como hoja
/// del sistema (detent medio) sobre la preparación: la modal nativa de
/// las HIG para una decisión acotada.
struct TimerConfigSheet: View {
    @Binding var config: PracticeTimerConfig
    @Environment(\.dismiss) private var dismiss

    private static let availableMarks: [TimeInterval] = [600, 300, 120, 60]
    private static let durationQuickPicks = [10, 15, 20, 30]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Modo", selection: $config.mode) {
                        Text("Cronómetro").tag(TimerMode.countUp)
                        Text("Cuenta atrás").tag(TimerMode.countdown)
                    }
                    .pickerStyle(.segmented)
                } footer: {
                    if config.mode == .countdown {
                        Text("Como en el examen: verás el tiempo restante.")
                    }
                }

                if config.mode == .countdown {
                    Section("Duración") {
                        Stepper(value: targetMinutes, in: 1...120) {
                            HStack {
                                Text("Objetivo")
                                Spacer()
                                Text("\(Int(config.targetDuration / 60)) min")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .accessibilityLabel("Duración objetivo")
                        .accessibilityValue("\(Int(config.targetDuration / 60)) minutos")

                        HStack {
                            ForEach(Self.durationQuickPicks, id: \.self) { minutes in
                                Button("\(minutes)′") {
                                    config.targetDuration = TimeInterval(minutes * 60)
                                }
                                .buttonStyle(.bordered)
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                    }

                    Section {
                        ForEach(visibleMarks, id: \.self) { mark in
                            Toggle(isOn: bindingForMark(mark)) {
                                Text("Cuando queden \(Int(mark / 60)) min")
                            }
                        }
                    } header: {
                        Text("Avisos")
                    } footer: {
                        Text("Vibración y señal visual, sin sonido: el micrófono está abierto y un pitido quedaría en la grabación.")
                    }
                }
            }
            .navigationTitle("Cronómetro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Hecho") { dismiss() }
                }
            }
        }
    }

    private var targetMinutes: Binding<Int> {
        Binding(
            get: { Int(config.targetDuration / 60) },
            set: { config.targetDuration = TimeInterval($0 * 60) }
        )
    }

    private var visibleMarks: [TimeInterval] {
        Self.availableMarks.filter { $0 < config.targetDuration }
    }

    private func bindingForMark(_ mark: TimeInterval) -> Binding<Bool> {
        Binding(
            get: { config.warningMarks.contains(mark) },
            set: { enabled in
                if enabled {
                    config.warningMarks.append(mark)
                } else {
                    config.warningMarks.removeAll { $0 == mark }
                }
            }
        )
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
