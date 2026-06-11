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
        case finished
        case permissionDenied
        case failed(String)
    }

    private(set) var state: State = .idle
    private(set) var elapsed: TimeInterval = 0
    private(set) var startedAt: Date?
    private(set) var endedAt: Date?

    /// Identidad de la grabación, asignada al crear el recorder.
    /// El archivo y el futuro modelo Recording comparten este id.
    let recordingID = UUID()

    private let recordingStore: RecordingStore
    private var recorder: AVAudioRecorder?
    private var timer: Timer?

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

    func start() async {
        guard state == .idle else { return }

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
            guard audioRecorder.record() else {
                state = .failed(String(localized: "No se pudo iniciar la grabación."))
                return
            }

            recorder = audioRecorder
            startedAt = .now
            state = .recording

            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
                MainActor.assumeIsolated {
                    guard let self, let recorder = self.recorder else { return }
                    self.elapsed = recorder.currentTime
                }
            }
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    /// Detiene la grabación y deja el archivo en su ubicación final.
    func finish() {
        guard state == .recording else { return }
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

    private func stopRecorder() {
        timer?.invalidate()
        timer = nil
        if let recorder {
            elapsed = recorder.currentTime
            recorder.stop()
        }
        recorder = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
