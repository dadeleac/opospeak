//
//  LogicTests.swift
//  opospeakTests
//
//  Created by David de León Acosta on 11/06/2026.
//

import Foundation
import Testing
@testable import opospeak

// MARK: - TopicBulkCreator

struct TopicBulkCreatorTests {

    @Test func fullRangeInEmptySyllabus() throws {
        let plan = try TopicBulkCreator.plan(existingNumbers: [], from: 1, to: 325)
        #expect(plan.count == 325)
        #expect(plan.first == 1)
        #expect(plan.last == 325)
    }

    @Test func skipsExistingNumbers() throws {
        let plan = try TopicBulkCreator.plan(existingNumbers: [1, 2], from: 1, to: 5)
        #expect(plan == [3, 4, 5])
    }

    @Test func fullyExistingRangeReturnsEmpty() throws {
        let plan = try TopicBulkCreator.plan(existingNumbers: [1, 2, 3], from: 1, to: 3)
        #expect(plan.isEmpty)
    }

    @Test func startBelowOneFails() {
        #expect(throws: TopicBulkCreator.BulkError.invalidStart) {
            try TopicBulkCreator.plan(existingNumbers: [], from: 0, to: 10)
        }
    }

    @Test func endBelowStartFails() {
        #expect(throws: TopicBulkCreator.BulkError.invalidRange) {
            try TopicBulkCreator.plan(existingNumbers: [], from: 10, to: 5)
        }
    }

    @Test func rangeOverThousandFails() {
        #expect(throws: TopicBulkCreator.BulkError.rangeTooLarge) {
            try TopicBulkCreator.plan(existingNumbers: [], from: 1, to: 1001)
        }
    }

    @Test func rangeOfExactlyThousandIsValid() throws {
        let plan = try TopicBulkCreator.plan(existingNumbers: [], from: 1, to: 1000)
        #expect(plan.count == 1000)
    }
}

// MARK: - TopicSortOrder

private struct TopicStub: TopicSortable {
    let number: Int
    let attemptCount: Int
    let lastPracticedAt: Date?
}

struct TopicSortOrderTests {

    private let base = Date(timeIntervalSince1970: 1_750_000_000)

    private var topics: [TopicStub] {
        [
            TopicStub(number: 1, attemptCount: 3, lastPracticedAt: base.addingTimeInterval(-86400)),
            TopicStub(number: 2, attemptCount: 0, lastPracticedAt: nil),
            TopicStub(number: 3, attemptCount: 5, lastPracticedAt: base),
            TopicStub(number: 4, attemptCount: 3, lastPracticedAt: base.addingTimeInterval(-3600)),
            TopicStub(number: 5, attemptCount: 0, lastPracticedAt: nil),
        ]
    }

    @Test func naturalOrder() {
        let result = TopicSortOrder.natural.sort(topics.shuffled())
        #expect(result.map(\.number) == [1, 2, 3, 4, 5])
    }

    @Test func mostPracticed() {
        let result = TopicSortOrder.mostPracticed.sort(topics)
        #expect(result.map(\.number) == [3, 1, 4, 2, 5])
    }

    @Test func leastPracticed() {
        let result = TopicSortOrder.leastPracticed.sort(topics)
        #expect(result.map(\.number) == [2, 5, 1, 4, 3])
    }

    @Test func recentlyPracticed() {
        let result = TopicSortOrder.recentlyPracticed.sort(topics)
        // Más recientes primero; sin práctica al final por número.
        #expect(result.map(\.number) == [3, 4, 1, 2, 5])
    }

    @Test func pendingFirst() {
        let result = TopicSortOrder.pending.sort(topics)
        #expect(result.map(\.number) == [2, 5, 1, 3, 4])
    }
}

// MARK: - ProgressSummary

struct ProgressSummaryTests {

    private let reference = Date(timeIntervalSince1970: 1_750_000_000)

    @Test func noAttemptsMeansNoActivity() {
        let summary = ProgressSummary(attempts: [], topicIDs: [UUID(), UUID()], reference: reference)
        #expect(!summary.hasActivity)
        #expect(summary.totalAttempts == 0)
        #expect(summary.totalTime == 0)
        #expect(summary.practicedTopics == 0)
        #expect(summary.neverPracticedTopics == 2)
        #expect(summary.mostPracticedTopic == nil)
    }

    @Test func volumeAndCoverage() {
        let topicA = UUID()
        let topicB = UUID()
        let topicC = UUID()
        let day: TimeInterval = 86400

        let attempts: [ProgressSummary.AttemptData] = [
            .init(date: reference.addingTimeInterval(-1 * day), duration: 600, topicID: topicA),
            .init(date: reference.addingTimeInterval(-1 * day + 3600), duration: 700, topicID: topicA),
            .init(date: reference.addingTimeInterval(-2 * day), duration: 800, topicID: topicB),
            .init(date: reference.addingTimeInterval(-20 * day), duration: 900, topicID: topicA),
        ]

        let summary = ProgressSummary(
            attempts: attempts,
            topicIDs: [topicA, topicB, topicC],
            reference: reference
        )

        #expect(summary.totalAttempts == 4)
        #expect(summary.totalTime == 3000)
        #expect(summary.topicsWorked == 2)
        #expect(summary.activeDays == 3)
        #expect(summary.daysPracticedLast7 == 2)
        #expect(summary.daysPracticedLast30 == 3)
        #expect(summary.practicedTopics == 2)
        #expect(summary.neverPracticedTopics == 1)
        #expect(summary.mostPracticedTopic?.topicID == topicA)
        #expect(summary.mostPracticedTopic?.attempts == 3)
        #expect(summary.leastPracticedTopic?.topicID == topicB)
        #expect(summary.leastPracticedTopic?.attempts == 1)
    }
}

// MARK: - Formato de duración

struct FormatDurationTests {

    @Test func minutesAndSeconds() {
        #expect(formatDuration(708) == "11:48")
    }

    @Test func withHours() {
        #expect(formatDuration(3750) == "1:02:30")
    }

    @Test func zero() {
        #expect(formatDuration(0) == "0:00")
    }
}
