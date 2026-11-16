//
//  EvaluationFactory.swift
//  POS
//
//  Created by Сергей Зауэрс on 16.11.2026.
//

import Foundation

final class EvaluationFactory {
    func make(
        studentID: StudentID,
        criterionID: CriterionID,
        rubric: Rubric,
        scoreValue: Double
    ) throws -> Evaluation {
        guard let criterion = rubric.criterion(by: criterionID) else { throw DomainError.criterionNotFound(criterionID) }
        
        return try Evaluation.create(
            studentID: studentID,
            criterion: criterion,
            scoreValue: scoreValue
        )
    }
}
