//
//  Syllabus.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import SwiftData

/// Temario: conjunto organizado de temas dentro de una oposición.
/// Civil, Penal o "Bloque I" son temarios; Judicatura es la oposición
/// que los contiene. No almacena grabaciones, métricas ni resultados.
@Model
final class Syllabus {
    var id: UUID = UUID()
    var name: String = ""
    var summary: String?
    var isActive: Bool = true
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    var opposition: Opposition?

    @Relationship(deleteRule: .cascade, inverse: \Topic.syllabus)
    var topics: [Topic]? = []

    init(name: String, summary: String? = nil, opposition: Opposition) {
        self.id = UUID()
        self.name = name
        self.summary = summary
        self.createdAt = .now
        self.updatedAt = .now
        self.opposition = opposition
    }
}
