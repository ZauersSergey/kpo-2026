//
//  DemoRunner.swift
//  POS
//
//  Created by Сергей Зауэрс on 16.11.2026.
//

import Foundation

final class DemoRunner {
    private let facade: POSFacade
    
    init(facade: POSFacade) { self.facade = facade }
    
    func run() {
        do {
            print("ДЕМО")
            
            let sergey = try facade.addStudent(name: "Сергей")
            let andrey = try facade.addStudent(name: "Андрей")
            
            let hw = try facade.addCriterion(name: "ДЗ", maxScore: 10, weight: 0.4)
            let exam = try facade.addCriterion(name: "Экзамен", maxScore: 10, weight: 0.6)
            
            print("Студенты: \(sergey.name) [\(sergey.id)], \(andrey.name) [\(andrey.id)]")
            print("Критерии: \(hw.name) [\(hw.id)], \(exam.name) [\(exam.id)]")
            
            try facade.assignEvaluation(
                studentID: sergey.id,
                criterionID: hw.id,
                score: 9
            )
            
            try facade.assignEvaluation(
                studentID: sergey.id,
                criterionID: exam.id,
                score: 8
            )
            
            try facade.assignEvaluation(
                studentID: andrey.id,
                criterionID: hw.id,
                score: 6
            )
            
            print("Оценки Сергея:")
            for evaluation in try facade.listEvaluations(studentID: sergey.id) {
                print("  \(evaluation.criterionName): \(evaluation.score)/\(evaluation.maxScore)")
            }
            
            let sergeyFinal = try facade.finalScore(for: sergey.id)
            print(String(format: "Итог Сергея: %.2f", sergeyFinal))
            
            print("Экспорт итогов:")
            print(try facade.exportReportJSON())
        } catch { print("Демо остановлено: \(error)") }
    }
}
