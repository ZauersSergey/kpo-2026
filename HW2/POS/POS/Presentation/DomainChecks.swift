//
//  DomainChecks.swift
//  POS
//
//  Created by Сергей Зауэрс on 16.11.2026.
//

import Foundation

enum DomainChecks {
    static func run() {
        do {
            var rubric = Rubric()
            
            let criterionName = try CriterionName("ДЗ")
            let maxScore = try MaxScore(10)
            let weight = try Weight(0.5)
            
            let criterion = Criterion(
                id: CriterionID("c1"),
                name: criterionName,
                maxScore: maxScore,
                weight: weight
            )
            
            try rubric.add(criterion)
            
            let evaluation = try Evaluation.create(
                studentID: StudentID("s1"),
                criterion: criterion,
                scoreValue: 9
            )
            
            assert(evaluation.score.value == 9)
            
            do {
                try Evaluation.create(
                    studentID: StudentID("s1"),
                    criterion: criterion,
                    scoreValue: 11
                )
                print("ОШИБКА: балл больше максимума был принят")
            } catch {
                print("ОК: балл больше максимума отклонён")
            }
            
            let calculator = FinalScoreCalculator(strategy: WeightedTenPointStrategy())
            let final = try calculator.calculate(
                evaluations: [evaluation],
                rubric: rubric
            )
            
            assert(abs(final.value - 9.0) < 0.0001)
            print("ОК: итог = \(final.value)")
            print("Проверки домена пройдены.")
        } catch { print("Проверки домена не пройдены: \(error)") }
    }
}
