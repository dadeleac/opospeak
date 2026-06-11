//
//  PlaybackController.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import AVFoundation
import Observation
import Foundation

/// Reproducción local de grabaciones (AVAudioPlayer es suficiente para
/// archivos m4a en disco). La vista debe llamar a stop() al desaparecer.
@Observable
final class PlaybackController {

    private(set) var isPlaying = false
    private(set) var progress: TimeInterval = 0
    private(set) var duration: TimeInterval = 0
    private(set) var isAvailable = false

    private var player: AVAudioPlayer?
    private var timer: Timer?

    func load(url: URL) {
        stop()
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            self.player = player
            duration = player.duration
            progress = 0
            isAvailable = true
        } catch {
            player = nil
            isAvailable = false
        }
    }

    func toggle() {
        guard let player else { return }
        if isPlaying {
            player.pause()
            isPlaying = false
            timer?.invalidate()
            timer = nil
        } else {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
            try? AVAudioSession.sharedInstance().setActive(true)
            player.play()
            isPlaying = true
            timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
                MainActor.assumeIsolated {
                    self?.update()
                }
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        player?.stop()
        player = nil
        isPlaying = false
        progress = 0
        duration = 0
        isAvailable = false
    }

    private func update() {
        guard let player else { return }
        progress = player.currentTime
        // AVAudioPlayer se detiene solo al llegar al final.
        if !player.isPlaying, isPlaying {
            isPlaying = false
            progress = 0
            player.currentTime = 0
            timer?.invalidate()
            timer = nil
        }
    }
}
