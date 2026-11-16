//
//  FinalScoreService.swift
//  POS
//
//  Created by Сергей Зауэрс on 16.11.2026.
//

import Foundation

final class FinalScoreService {
    private let studentRepo: StudentRepository
    private let rubricRepo: RubricRepository
    private let evaluationRepo: EvaluationRepository
    private let calculator: FinalScoreCalculator
    
    init(
        studentRepo: StudentRepository,
        rubricRepo: RubricRepository,
        evaluationRepo: EvaluationRepository,
        calculator: FinalScoreCalculator
    ) {
        self.studentRepo = studentRepo
        self.rubricRepo = rubricRepo
        self.evaluationRepo = evaluationRepo
        self.calculator = calculator
    }
    
    func finalScore(for studentID: StudentID) throws -> FinalScore {
        guard studentRepo.find(by: studentID) != nil else { throw DomainError.studentNotFound(studentID) }
        
        let rubric = rubricRepo.get()
        let evaluations = evaluationRepo.findByStudent(studentID)

        return try calculator.calculate(
            evaluations: evaluations,
            rubric: rubric
        )
    }

    func report() throws -> FinalReport {
        var rows: [FinalReportRow] = []

        let students = studentRepo.all().sorted { $0.name.value < $1.name.value }
        
        for student in students {
            let score = try finalScore(for: student.id)
            rows.append(
                FinalReportRow(
                    studentID: student.id.value,
                    studentName: student.name.value,
                    finalScore: score.value
                )
            )
        }
        
        return FinalReport(rows: rows)
    }
}
