//
//  ContentView.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import SwiftUI
import SwiftData

// Placeholder hasta que llegue la change de arquitectura de información
// (tres pestañas: Temarios, Progreso, Ajustes).
struct ContentView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "mic.circle")
                .font(.system(size: 56))
            Text("OpoSpeak")
                .font(.title)
        }
    }
}

#Preview {
    ContentView()
}
