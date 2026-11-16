//
//  EvaluationService.swift
//  POS
//
//  Created by Сергей Зауэрс on 16.11.2026.
//

import Foundation

final class EvaluationService {
    private let studentRepo: StudentRepository
    private let rubricRepo: RubricRepository
    private let evaluationRepo: EvaluationRepository
    private let factory: EvaluationFactory
    
    init(
        studentRepo: StudentRepository,
        rubricRepo: RubricRepository,
        evaluationRepo: EvaluationRepository,
        factory: EvaluationFactory
    ) {
        self.studentRepo = studentRepo
        self.rubricRepo = rubricRepo
        self.evaluationRepo = evaluationRepo
        self.factory = factory
    }
    
    func assign(
        studentID: StudentID,
        criterionID: CriterionID,
        scoreValue: Double
    ) throws -> Evaluation {
        guard studentRepo.find(by: studentID) != nil else { throw DomainError.studentNotFound(studentID) }
        
        if evaluationRepo.find(studentID: studentID, criterionID: criterionID) != nil {
            throw DomainError.evaluationAlreadyExists(studentID, criterionID)
        }
        
        let rubric = rubricRepo.get()
        let evaluation = try factory.make(
            studentID: studentID,
            criterionID: criterionID,
            rubric: rubric,
            scoreValue: scoreValue
        )
        
        try evaluationRepo.save(evaluation)
        return evaluation
    }
    
    func correct(
        studentID: StudentID,
        criterionID: CriterionID,
        newScore: Double
    ) throws -> Evaluation {
        guard let existing = evaluationRepo.find(
            studentID: studentID,
            criterionID: criterionID
        ) else {
            throw DomainError.evaluationNotFound(studentID, criterionID)
        }
        
        let rubric = rubricRepo.get()
        guard let criterion = rubric.criterion(by: criterionID) else {
            throw DomainError.criterionNotFound(criterionID)
        }
        
        let updated = try existing.corrected(
            scoreValue: newScore,
            criterion: criterion
        )
        
        try evaluationRepo.save(updated)
        return updated
    }
    
    func cancel(studentID: StudentID, criterionID: CriterionID) throws {
        guard evaluationRepo.find(studentID: studentID, criterionID: criterionID) != nil else {
            throw DomainError.evaluationNotFound(studentID, criterionID)
        }
        
        try evaluationRepo.delete(studentID: studentID, criterionID: criterionID)
    }
    
    func list(studentID: StudentID) -> [Evaluation] {
        evaluationRepo.findByStudent(studentID)
            .sorted { $0.criterion.name.value < $1.criterion.name.value }
    }
    
    func all() -> [Evaluation] { evaluationRepo.all() }
}
