//
//  Topic.swift
//  opospeak
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import SwiftData

/// Tema: unidad de estudio individual que puede ser cantada.
/// El título es opcional: muchos opositores trabajan solo con
/// "Tema 1", "Tema 2"…
@Model
final class Topic {
    var id: UUID = UUID()
    var number: Int = 0
    var title: String?
    var isActive: Bool = true
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    var syllabus: Syllabus?

    @Relationship(deleteRule: .cascade, inverse: \Attempt.topic)
    var attempts: [Attempt]? = []

    init(number: Int, title: String? = nil, syllabus: Syllabus) {
        self.id = UUID()
        self.number = number
        self.title = title
        self.isActive = true
        self.createdAt = .now
        self.updatedAt = .now
        self.syllabus = syllabus
    }
}
