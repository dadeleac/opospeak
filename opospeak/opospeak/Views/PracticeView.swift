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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var recorder: PracticeRecorder?
    @State private var summary: PracticeSummary?
    @State private var config = PracticeTimerConfig.load()
    @State private var showingConfigSheet = false
    @State private var lastSeenElapsed: TimeInterval = 0
    @State private var flashingMark: TimeInterval?
    @State private var clockPulse = false
    @State private var confirmingDiscard = false

    private struct PracticeSummary {
        let duration: TimeInterval
        let date: Date
    }

    var body: some View {
        NavigationStack {
            Group {
                if let recorder {
                    switch recorder.state {
                    case .idle, .recording, .paused:
                        sessionView(recorder)
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
                // Lo destructivo no merece sitio permanente en pantalla:
                // descartar vive en el menú y pide confirmación (borra
                // el audio de forma irreversible).
                if recorder?.state == .recording || recorder?.state == .paused {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            // Plantearse descartar pausa la grabación: los
                            // minutos no corren mientras el usuario decide.
                            // Si cancela, sigue en pausa hasta Reanudar.
                            Button("Descartar práctica", systemImage: "trash", role: .destructive) {
                                if recorder?.state == .recording {
                                    recorder?.pause()
                                }
                                confirmingDiscard = true
                            }
                        } label: {
                            Label("Más opciones", systemImage: "ellipsis.circle")
                        }
                    }
                }
            }
            // Alerta y no action sheet: lanzada desde un menú de toolbar,
            // la hoja se ancla al botón "···" como popover flotante. La
            // alerta centrada es el patrón HIG para confirmar una pérdida
            // irreversible, con Cancelar explícito.
            .alert(
                "¿Descartar esta práctica?",
                isPresented: $confirmingDiscard
            ) {
                Button("Descartar práctica", role: .destructive) { discard() }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("La grabación se eliminará y no se puede recuperar.")
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

    /// El chip resume la decisión en dos líneas deliberadas, como una fila
    /// de Ajustes: la principal en titular, los avisos en caption. Nunca
    /// un salto de línea accidental.
    private var configTitle: String {
        config.mode == .countdown
            ? String(localized: "Cuenta atrás · \(Int(config.targetDuration / 60)) min")
            : String(localized: "Cronómetro")
    }

    /// "Avisos a mitad y al quedar 5, 2 y 1 min" — lista española real,
    /// singular cuidado, y "al quedar" porque "a los 1 min" no es español.
    private var configDetail: String? {
        guard config.mode == .countdown else { return nil }
        let markMinutes = config.warningMarks
            .filter { $0 < config.targetDuration }
            .sorted(by: >)
            .map { "\(Int($0 / 60))" }
        let list = spanishList(markMinutes)
        switch (config.halfTimeWarning, markMinutes.isEmpty) {
        case (false, true):
            return nil
        case (true, true):
            return String(localized: "Aviso a mitad de tiempo")
        case (false, false):
            return markMinutes.count == 1
                ? String(localized: "Aviso al quedar \(list) min")
                : String(localized: "Avisos al quedar \(list) min")
        case (true, false):
            return String(localized: "Avisos a mitad y al quedar \(list) min")
        }
    }

    /// "5", "5 y 1", "5, 2 y 1": comas y la conjunción solo al final.
    private func spanishList(_ items: [String]) -> String {
        guard items.count > 1 else { return items.first ?? "" }
        return items.dropLast().joined(separator: ", ")
            + String(localized: " y ")
            + items[items.count - 1]
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
                    HStack(spacing: 12) {
                        Image(systemName: "timer")
                        VStack(alignment: .leading, spacing: 2) {
                            Text(configTitle)
                            if let detail = configDetail {
                                Text(detail)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .accessibilityElement(children: .combine)
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

    /// Listo y Grabando comparten un único esqueleto: el reloj ocupa
    /// exactamente el mismo sitio en ambos momentos y cada ranura (estado,
    /// cápsula, controles) tiene altura fija. Al pulsar Grabar solo
    /// cambia el contenido de las ranuras — nada salta.
    private func sessionView(_ recorder: PracticeRecorder) -> some View {
        let isIdle = recorder.state == .idle
        let isPaused = recorder.state == .paused

        return VStack(spacing: 24) {
            Spacer()

            statusArea(recorder)
                .frame(height: 48)

            // Reloj dentro del anillo (solo cuenta atrás); el conjunto
            // late una vez al cruzar cualquier marca. En reposo, el
            // anillo lleno con sus ticks anticipa la práctica.
            ZStack {
                // La presencia de la voz: solo grabando — una pantalla
                // en pausa o en reposo está visiblemente quieta.
                if recorder.state == .recording {
                    AudioPresenceHalo(level: recorder.level)
                        .frame(width: 220, height: 220)
                }
                if config.mode == .countdown {
                    CountdownRing(
                        fraction: CountdownRingGeometry.remainingFraction(
                            target: config.targetDuration, elapsed: recorder.elapsed
                        ),
                        markFractions: ringMarkFractions,
                        isOvertime: isOvertime
                    )
                    .frame(width: 240, height: 240)
                } else {
                    // El escenario circular es común a ambos modos: en
                    // cronómetro, solo la pista (fracción 0, sin marcas)
                    // — un círculo vacío no afirma nada sobre el tiempo;
                    // la cuenta atrás le añade la información real.
                    CountdownRing(fraction: 0, markFractions: [], isOvertime: false)
                        .frame(width: 240, height: 240)
                }
                VStack(spacing: 4) {
                    Text(timerText(recorder.elapsed))
                        .font(.system(.largeTitle, design: .rounded, weight: .light))
                        .monospacedDigit()
                        .foregroundStyle(
                            isIdle || isPaused ? AnyShapeStyle(.secondary)
                                : isOvertime ? AnyShapeStyle(Color.mutedRed)
                                : AnyShapeStyle(.primary)
                        )
                    if config.mode == .countdown {
                        Text("objetivo \(Int(config.targetDuration / 60)) min")
                            .font(.footnote)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            // Marco fijo: el escenario mide lo mismo en ambos modos y en
            // todos los estados — el halo entra y sale sin mover nada.
            .frame(width: 240, height: 240)
            .scaleEffect(clockPulse ? 1.04 : 1)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                isIdle
                    ? (config.mode == .countdown ? "Tiempo objetivo" : "Cronómetro")
                    : config.mode == .countdown
                        ? (isOvertime ? "Tiempo excedido" : "Tiempo restante")
                        : "Tiempo transcurrido"
            )
            .accessibilityValue(timerText(recorder.elapsed))

            // Hueco reservado: la cápsula del aviso entra y sale sin
            // mover el reloj ni los controles.
            ZStack {
                if let mark = flashingMark {
                    HStack(spacing: 6) {
                        Image(systemName: "bell.fill")
                            .foregroundStyle(Color.amber)
                        Text(warningFlashLabel(mark))
                    }
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.regularMaterial, in: Capsule())
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                }
            }
            .frame(height: 44)
            .animation(.spring(duration: 0.4), value: flashingMark)

            Spacer()

            controlsArea(recorder)
                .padding(.horizontal)
                .padding(.bottom)
        }
        .animation(.snappy(duration: 0.3), value: recorder.state)
    }

    /// Ranura de estado: la invitación a colocarse en reposo, el estado
    /// de grabación después. Estados inequívocos: color + icono + texto,
    /// nunca solo color. Los avisos no pasan por aquí: tienen su cápsula.
    @ViewBuilder
    private func statusArea(_ recorder: PracticeRecorder) -> some View {
        if recorder.state == .idle {
            Text("Coloca el móvil donde quieras.\nPulsa cuando estés preparado.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)
        } else {
            HStack(spacing: 8) {
                if recorder.state == .paused {
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
                } else {
                    // El punto de grabación late suavemente con la voz:
                    // la confirmación de "me está recogiendo" justo donde
                    // el ojo va a comprobar que graba.
                    Circle()
                        .fill(Color.mutedRed)
                        .frame(width: 12, height: 12)
                        .scaleEffect(reduceMotion ? 1 : 1 + 0.35 * recorder.level)
                        .animation(reduceMotion ? nil : .easeOut(duration: 0.1), value: recorder.level)
                    Text("Grabando")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityElement(children: .combine)
        }
    }

    /// Ranura de controles: Grabar en reposo; Pausar (prominente) y
    /// Finalizar después. Misma altura y posición — solo cambian botones.
    @ViewBuilder
    private func controlsArea(_ recorder: PracticeRecorder) -> some View {
        if recorder.state == .idle {
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
            .accessibilityHint("Enciende el micrófono y empieza a grabar")
        } else {
            let isPaused = recorder.state == .paused

            // Un solo gesto prominente: el que no destruye nada.
            HStack(spacing: 12) {
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
            }
        }
    }

    // MARK: - Avisos

    /// La marca de mitad de tiempo es la única relativa: puede caer en
    /// medio minuto (objetivo de 15 → quedan 7,5), así que su etiqueta
    /// es el hito ("Mitad de tiempo"), no una cifra redondeada.
    private func isHalfTimeMark(_ mark: TimeInterval) -> Bool {
        config.halfTimeWarning && mark == config.targetDuration / 2
    }

    private func warningFlashLabel(_ mark: TimeInterval) -> String {
        isHalfTimeMark(mark)
            ? String(localized: "Mitad de tiempo")
            : String(localized: "Quedan \(Int(mark / 60)) min")
    }

    private var ringMarkFractions: [Double] {
        CountdownRingGeometry.markFractions(
            target: config.targetDuration,
            marks: config.effectiveWarningMarks()
        )
    }

    /// Un latido del reloj: escala 1.0 → 1.04 → 1.0 con muelle corto.
    private func pulseClock() {
        withAnimation(.spring(duration: 0.25)) { clockPulse = true }
        Task {
            try? await Task.sleep(for: .milliseconds(250))
            withAnimation(.spring(duration: 0.35)) { clockPulse = false }
        }
    }

    /// Háptica + señal visual + anuncio de VoiceOver al cruzar cada marca.
    /// Nunca sonido: el micrófono está abierto. Las marcas corren sobre
    /// tiempo grabado, así que la pausa las congela sola.
    private func handleWarnings(elapsed: TimeInterval) {
        defer { lastSeenElapsed = elapsed }
        guard config.mode == .countdown else { return }

        let crossed = WarningSchedule.crossedMarks(
            target: config.targetDuration,
            marks: config.effectiveWarningMarks(),
            previousElapsed: lastSeenElapsed,
            elapsed: elapsed
        )
        guard let mark = crossed.last else { return }

        pulseClock()

        if mark == 0 {
            // El agotamiento pesa más que una marca intermedia.
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            AccessibilityNotification.Announcement(
                String(localized: "Tiempo agotado")
            ).post()
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            AccessibilityNotification.Announcement(
                isHalfTimeMark(mark)
                    ? String(localized: "Mitad de tiempo")
                    : String(localized: "Quedan \(Int(mark / 60)) minutos")
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
                // Centrada: no es un par etiqueta-valor como las demás
                // filas, es la confirmación — el sello de la tarjeta.
                // HStack explícito: Label + frame(maxWidth:) descentra
                // por el espacio fantasma del icono.
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Grabación guardada")
                }
                .foregroundStyle(Color.sage)
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .combine)
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
                        // Rueda como el Temporizador del sistema: el gesto
                        // que todo usuario conoce para "poner el reloj".
                        Picker("Duración objetivo", selection: targetMinutes) {
                            ForEach(1...120, id: \.self) { minutes in
                                Text("\(minutes) min").tag(minutes)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 120)
                        .accessibilityLabel("Duración objetivo")
                        .accessibilityValue("\(Int(config.targetDuration / 60)) minutos")
                    }

                    Section {
                        // Marca relativa: escala con el objetivo, así
                        // cubre igual un tema de 12 min y un simulacro de 75.
                        Toggle(isOn: $config.halfTimeWarning) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("A mitad de tiempo")
                                Text("Con este objetivo, cuando queden \(halfTimeDetail)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
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

    /// "7 min" o "7 min 30 s": la mitad de un objetivo impar cae en
    /// medio minuto y la cifra debe decirlo, no redondearlo.
    private var halfTimeDetail: String {
        let half = Int(config.targetDuration / 2)
        let minutes = half / 60
        let seconds = half % 60
        return seconds == 0
            ? String(localized: "\(minutes) min")
            : String(localized: "\(minutes) min \(seconds) s")
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
