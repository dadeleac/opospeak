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

    enum Estado: Equatable {
        case inactivo
        case grabando
        case finalizado
        case permisoDenegado
        case fallo(String)
    }

    private(set) var estado: Estado = .inactivo
    private(set) var transcurrido: TimeInterval = 0
    private(set) var fechaInicio: Date?
    private(set) var fechaFin: Date?

    /// Identidad de la grabación, asignada al crear el recorder.
    /// El archivo y el futuro modelo Grabacion comparten este id.
    let grabacionId = UUID()

    private let recordingStore: RecordingStore
    private var recorder: AVAudioRecorder?
    private var timer: Timer?

    /// Voz, un solo hablante: AAC mono a 64 kbps (~30 MB/hora).
    private static let ajustesGrabacion: [String: Any] = [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVSampleRateKey: 44_100.0,
        AVNumberOfChannelsKey: 1,
        AVEncoderBitRateKey: 64_000,
    ]

    var fileURL: URL {
        recordingStore.url(forGrabacionId: grabacionId)
    }

    init(recordingStore: RecordingStore = RecordingStore()) {
        self.recordingStore = recordingStore
    }

    func comenzar() async {
        guard estado == .inactivo else { return }

        let permitido = await AVAudioApplication.requestRecordPermission()
        guard permitido else {
            estado = .permisoDenegado
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker])
            try session.setActive(true)

            try recordingStore.ensureDirectoryExists()
            let grabador = try AVAudioRecorder(url: fileURL, settings: Self.ajustesGrabacion)
            guard grabador.record() else {
                estado = .fallo("No se pudo iniciar la grabación.")
                return
            }

            recorder = grabador
            fechaInicio = .now
            estado = .grabando

            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
                MainActor.assumeIsolated {
                    guard let self, let recorder = self.recorder else { return }
                    self.transcurrido = recorder.currentTime
                }
            }
        } catch {
            estado = .fallo(error.localizedDescription)
        }
    }

    /// Detiene la grabación y deja el archivo en su ubicación final.
    func finalizar() {
        guard estado == .grabando else { return }
        detenerGrabador()
        fechaFin = .now
        estado = .finalizado
    }

    /// Abandona la práctica: detiene y borra el archivo parcial.
    func descartar() {
        detenerGrabador()
        try? recordingStore.deleteRecording(id: grabacionId)
        estado = .inactivo
        transcurrido = 0
        fechaInicio = nil
        fechaFin = nil
    }

    private func detenerGrabador() {
        timer?.invalidate()
        timer = nil
        if let recorder {
            transcurrido = recorder.currentTime
            recorder.stop()
        }
        recorder = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
