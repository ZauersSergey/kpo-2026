//
//  POSFacade.swift
//  POS
//
//  Created by Сергей Зауэрс on 16.11.2026.
//

import Foundation

final class POSFacade {
    private let studentService: StudentService
    private let rubricService: RubricService
    private let evaluationService: EvaluationService
    private let finalScoreService: FinalScoreService
    private let exporter: FinalReportExporter
    
    init(
        studentService: StudentService,
        rubricService: RubricService,
        evaluationService: EvaluationService,
        finalScoreService: FinalScoreService,
        exporter: FinalReportExporter
    ) {
        self.studentService = studentService
        self.rubricService = rubricService
        self.evaluationService = evaluationService
        self.finalScoreService = finalScoreService
        self.exporter = exporter
    }
    
    func addStudent(name: String) throws -> StudentDTO {
        let student = try studentService.addStudent(name: name)
        return StudentDTO(
            id: student.id.value,
            name: student.name.value
        )
    }
    
    func listStudents() -> [StudentDTO] {
        studentService.list().map { StudentDTO(id: $0.id.value, name: $0.name.value) }
    }
    
    func addCriterion(name: String, maxScore: Double, weight: Double) throws -> CriterionDTO {
        let criterion = try rubricService.addCriterion(
            name: name,
            maxScore: maxScore,
            weight: weight
        )
        
        return CriterionDTO(
            id: criterion.id.value,
            name: criterion.name.value,
            maxScore: criterion.maxScore.value,
            weight: criterion.weight.value
        )
    }
    
    func listCriteria() -> [CriterionDTO] {
        rubricService.list().map {
            CriterionDTO(
                id: $0.id.value,
                name: $0.name.value,
                maxScore: $0.maxScore.value,
                weight: $0.weight.value
            )
        }
    }
    
    @discardableResult
    func assignEvaluation(
        studentID: String,
        criterionID: String,
        score: Double
    ) throws -> EvaluationDTO {
        let evaluation = try evaluationService.assign(
            studentID: StudentID(studentID),
            criterionID: CriterionID(criterionID),
            scoreValue: score
        )
        
        return evaluationDTO(evaluation)
    }
    
    func correctEvaluation(
        studentID: String,
        criterionID: String,
        newScore: Double
    ) throws -> EvaluationDTO {
        let evaluation = try evaluationService.correct(
            studentID: StudentID(studentID),
            criterionID: CriterionID(criterionID),
            newScore: newScore
        )
        
        return evaluationDTO(evaluation)
    }
    
    func cancelEvaluation(studentID: String, criterionID: String) throws {
        try evaluationService.cancel(
            studentID: StudentID(studentID),
            criterionID: CriterionID(criterionID)
        )
    }
    
    func listEvaluations(studentID: String) throws -> [EvaluationDTO] {
        let sid = StudentID(studentID)

        guard studentService.find(sid) != nil else {
            throw DomainError.studentNotFound(sid)
        }

        return evaluationService.list(studentID: sid).map(evaluationDTO)
    }
    
    func finalScore(for studentID: String) throws -> Double { try finalScoreService.finalScore(for: StudentID(studentID)).value }
    
    func exportReportJSON() throws -> String {
        let report = try finalScoreService.report()
        return try exporter.export(report)
    }
    
    private func evaluationDTO(_ evaluation: Evaluation) -> EvaluationDTO {
        let studentName = studentService.find(evaluation.studentID)?.name.value ?? "<unknown>"
        
        return EvaluationDTO(
            studentID: evaluation.studentID.value,
            studentName: studentName,
            criterionID: evaluation.criterion.id.value,
            criterionName: evaluation.criterion.name.value,
            score: evaluation.score.value,
            maxScore: evaluation.criterion.maxScore.value
        )
    }
}
