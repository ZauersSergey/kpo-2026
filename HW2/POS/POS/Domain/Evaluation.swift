//
//  Evaluation.swift
//  POS
//
//  Created by Сергей Зауэрс on 16.11.2026.
//

import Foundation

struct Evaluation: Equatable {
    let studentID: StudentID
    let criterion: Criterion
    let score: Score
    
    private init(studentID: StudentID, criterion: Criterion, score: Score) {
        self.studentID = studentID
        self.criterion = criterion
        self.score = score
    }
    
    @discardableResult
    static func create(
        studentID: StudentID,
        criterion: Criterion,
        scoreValue: Double
    ) throws -> Evaluation {
        let score = try Score.create(value: scoreValue, maxScore: criterion.maxScore)
        return Evaluation(studentID: studentID, criterion: criterion, score: score)
    }
    
    func corrected(scoreValue: Double, criterion: Criterion) throws -> Evaluation {
        let score = try Score.create(value: scoreValue, maxScore: criterion.maxScore)
        return Evaluation(studentID: studentID, criterion: criterion, score: score)
    }
}
