//
//  ShareSheet.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import SwiftUI
import UIKit

/// Share sheet del sistema para URLs generadas bajo demanda
/// (ShareLink exige el item por adelantado; los paquetes de exportación
/// se generan al pulsar, no al cargar la vista).
struct ShareSheet: UIViewControllerRepresentable {
    let url: URL
    var onDismiss: (() -> Void)?

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        controller.completionWithItemsHandler = { _, _, _, _ in
            onDismiss?()
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
