//
//  ValueObjects.swift
//  POS
//
//  Created by Сергей Зауэрс on 16.11.2026.
//

import Foundation

struct StudentName: Equatable {
    let value: String

    init(_ raw: String) throws {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw DomainError.emptyName("student.name") }
        self.value = trimmed
    }
}

struct CriterionName: Equatable {
    let value: String
    
    init(_ raw: String) throws {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw DomainError.emptyName("criterion.name") }
        self.value = trimmed
    }
}

struct MaxScore: Equatable {
    let value: Double
    
    init(_ value: Double) throws {
        guard value.isFinite, value > 0 else { throw DomainError.invalidMaxScore(value) }
        self.value = value
    }
}

struct Weight: Equatable {
    let value: Double
    
    init(_ value: Double) throws {
        guard value.isFinite, value > 0 else { throw DomainError.invalidWeight(value) }
        self.value = value
    }
}

struct Score: Equatable {
    let value: Double
    
    private init(value: Double) { self.value = value }
    
    static func create(value: Double, maxScore: MaxScore) throws -> Score {
        guard value.isFinite, value >= 0, value <= maxScore.value else {
            throw DomainError.scoreOutOfRange(value: value, max: maxScore.value)
        }
        
        return Score(value: value)
    }
}

struct FinalScore: Equatable {
    let value: Double
    
    init(_ value: Double) throws {
        guard value.isFinite, value >= 0, value <= 10 else { throw DomainError.invalidFinalScore(value) }
        self.value = value
    }
}
