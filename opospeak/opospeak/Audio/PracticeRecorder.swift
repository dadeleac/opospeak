//
//  PracticeRecorder.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import AVFoundation
import Observation
import Foundation

/// Único dueño de la sesión de audio y del AVAudioRecorder durante una
/// práctica. La vista solo renderiza sus estados; nunca toca AVFoundation.
/// Graba directamente en la URL final de RecordingStore: sin copias,
/// sin archivos temporales que migrar.
@Observable
final class PracticeRecorder {

    enum State: Equatable {
        case idle
        case recording
        case paused
        case finished
        case permissionDenied
        case failed(String)
    }

    private(set) var state: State = .idle
    private(set) var elapsed: TimeInterval = 0
    private(set) var startedAt: Date?
    private(set) var endedAt: Date?

    /// Nivel de voz suavizado [0, 1] para la presencia visual. Efímero:
    /// solo vive mientras se graba; la pausa lo asienta a cero.
    private(set) var level: Double = 0

    /// Identidad de la grabación, asignada al crear el recorder.
    /// El archivo y el futuro modelo Recording comparten este id.
    let recordingID = UUID()

    private let recordingStore: RecordingStore
    private var recorder: AVAudioRecorder?
    private var timer: Timer?
    private var meterTimer: Timer?
    private var levelMeter = AudioLevelMeter()
    private var interruptionObserver: NSObjectProtocol?

    /// Voz, un solo hablante: AAC mono a 64 kbps (~30 MB/hora).
    private static let recordingSettings: [String: Any] = [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVSampleRateKey: 44_100.0,
        AVNumberOfChannelsKey: 1,
        AVEncoderBitRateKey: 64_000,
    ]

    var fileURL: URL {
        recordingStore.url(forRecordingID: recordingID)
    }

    init(recordingStore: RecordingStore = RecordingStore()) {
        self.recordingStore = recordingStore
    }

    /// Pide el permiso de micrófono sin grabar nada. Se invoca al entrar
    /// en la práctica (Continuar) para que el diálogo del sistema no
    /// interrumpa al usuario después de colocar el móvil en un soporte.
    func requestPermission() async {
        let granted = await AVAudioApplication.requestRecordPermission()
        if !granted {
            state = .permissionDenied
        }
    }

    func start() async {
        guard state == .idle else { return }

        // Idempotente: si el permiso ya se concedió en requestPermission(),
        // el sistema responde al instante sin diálogo.
        let granted = await AVAudioApplication.requestRecordPermission()
        guard granted else {
            state = .permissionDenied
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker])
            try session.setActive(true)

            try recordingStore.ensureDirectoryExists()
            let audioRecorder = try AVAudioRecorder(url: fileURL, settings: Self.recordingSettings)
            // Solo activa la medición de nivel; no altera el archivo.
            audioRecorder.isMeteringEnabled = true
            guard audioRecorder.record() else {
                state = .failed(String(localized: "No se pudo iniciar la grabación."))
                return
            }

            recorder = audioRecorder
            startedAt = .now
            state = .recording
            startTimer()
            startMeterTimer()
            observeInterruptions()
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    /// Pausa la grabación: el audio continúa después en el mismo archivo,
    /// sin hueco ni fragmento; el cronómetro queda congelado.
    func pause() {
        guard state == .recording, let recorder else { return }
        recorder.pause()
        elapsed = recorder.currentTime
        timer?.invalidate()
        timer = nil
        stopMetering()
        state = .paused
    }

    /// Reanuda tras una pausa, re-asegurando la sesión de audio (otra app
    /// pudo tomarla durante una llamada).
    func resume() {
        guard state == .paused, let recorder else { return }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            state = .failed(error.localizedDescription)
            return
        }
        guard recorder.record() else {
            state = .failed(String(localized: "No se pudo reanudar la grabación."))
            return
        }
        state = .recording
        startTimer()
        startMeterTimer()
    }

    /// Detiene la grabación y deja el archivo en su ubicación final.
    /// Válido grabando o en pausa.
    func finish() {
        guard state == .recording || state == .paused else { return }
        stopRecorder()
        endedAt = .now
        state = .finished
    }

    /// Abandona la práctica: detiene y borra el archivo parcial.
    func discard() {
        stopRecorder()
        try? recordingStore.deleteRecording(id: recordingID)
        state = .idle
        elapsed = 0
        startedAt = nil
        endedAt = nil
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self, let recorder = self.recorder else { return }
                self.elapsed = recorder.currentTime
            }
        }
    }

    /// Timer de medición propio (~15 Hz): el reloj no necesita esta
    /// frecuencia y el halo no puede vivir con la de elapsed. Solo corre
    /// grabando; la calibración (suelo, suavizado) vive en AudioLevelMeter.
    private func startMeterTimer() {
        meterTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 15.0, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self, let recorder = self.recorder else { return }
                recorder.updateMeters()
                let normalized = AudioLevelMeter.normalize(power: recorder.averagePower(forChannel: 0))
                self.level = self.levelMeter.smooth(normalized)
            }
        }
    }

    private func stopMetering() {
        meterTimer?.invalidate()
        meterTimer = nil
        levelMeter.reset()
        level = 0
    }

    /// Una interrupción del sistema (llamada, Siri) pausa en lugar de
    /// perder la práctica. Nunca se reanuda sola: el usuario decide
    /// cuándo está listo.
    private func observeInterruptions() {
        interruptionObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance(),
            queue: .main
        ) { [weak self] notification in
            MainActor.assumeIsolated {
                guard let self,
                      let rawType = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                      let type = AVAudioSession.InterruptionType(rawValue: rawType)
                else { return }
                if type == .began, self.state == .recording {
                    self.pause()
                }
                // .ended: permanecer en pausa; reanudación manual.
            }
        }
    }

    private func stopRecorder() {
        timer?.invalidate()
        timer = nil
        stopMetering()
        if let interruptionObserver {
            NotificationCenter.default.removeObserver(interruptionObserver)
            self.interruptionObserver = nil
        }
        if let recorder {
            elapsed = recorder.currentTime
            recorder.stop()
        }
        recorder = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
