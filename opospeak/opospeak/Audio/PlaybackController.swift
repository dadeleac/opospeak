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
/// archivos m4a en disco). La vista debe llamar a detener() al desaparecer.
@Observable
final class PlaybackController {

    private(set) var reproduciendo = false
    private(set) var progreso: TimeInterval = 0
    private(set) var duracion: TimeInterval = 0
    private(set) var disponible = false

    private var player: AVAudioPlayer?
    private var timer: Timer?

    func cargar(url: URL) {
        detener()
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            self.player = player
            duracion = player.duration
            progreso = 0
            disponible = true
        } catch {
            player = nil
            disponible = false
        }
    }

    func alternar() {
        guard let player else { return }
        if reproduciendo {
            player.pause()
            reproduciendo = false
            timer?.invalidate()
            timer = nil
        } else {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
            try? AVAudioSession.sharedInstance().setActive(true)
            player.play()
            reproduciendo = true
            timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
                MainActor.assumeIsolated {
                    self?.actualizar()
                }
            }
        }
    }

    func detener() {
        timer?.invalidate()
        timer = nil
        player?.stop()
        player = nil
        reproduciendo = false
        progreso = 0
        duracion = 0
        disponible = false
    }

    private func actualizar() {
        guard let player else { return }
        progreso = player.currentTime
        // AVAudioPlayer se detiene solo al llegar al final.
        if !player.isPlaying, reproduciendo {
            reproduciendo = false
            progreso = 0
            player.currentTime = 0
            timer?.invalidate()
            timer = nil
        }
    }
}
