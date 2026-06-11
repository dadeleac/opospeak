//
//  Opposition.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import SwiftData

/// Raíz del dominio: la oposición que el opositor prepara.
/// Judicatura, Notarías o Inspección de Hacienda son oposiciones;
/// Civil, Penal o Procesal son temarios (Syllabus) dentro de una.
@Model
final class Opposition {
    var id: UUID = UUID()
    var name: String = ""
    var summary: String?
    var isActive: Bool = true
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    @Relationship(deleteRule: .cascade, inverse: \Syllabus.opposition)
    var syllabi: [Syllabus]? = []

    init(name: String, summary: String? = nil) {
        self.id = UUID()
        self.name = name
        self.summary = summary
        self.createdAt = .now
        self.updatedAt = .now
    }
}
