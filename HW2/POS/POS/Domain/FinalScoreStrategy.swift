//
//  FinalScoreStrategy.swift
//  POS
//
//  Created by Сергей Зауэрс on 16.11.2026.
//

import Foundation

protocol FinalScoreStrategy {
    func calculate(evaluations: [Evaluation], rubric: Rubric) throws -> FinalScore
}

struct WeightedTenPointStrategy: FinalScoreStrategy {
    func calculate(evaluations: [Evaluation], rubric: Rubric) throws -> FinalScore {
        let criteria = rubric.all
        guard !criteria.isEmpty else { throw DomainError.noCriteria }
        
        let totalWeight = criteria.reduce(0.0) { $0 + $1.weight.value }
        guard totalWeight > 0 else { throw DomainError.invalidWeight(totalWeight) }
        
        var weightedSum = 0.0
        
        for criterion in criteria {
            let evaluation = evaluations.first { $0.criterion.id == criterion.id }
            let scoreValue = evaluation?.score.value ?? 0.0
            weightedSum += (scoreValue / criterion.maxScore.value) * criterion.weight.value
        }
        
        let raw = (weightedSum / totalWeight) * 10.0
        let rounded = (raw * 100).rounded() / 100
        return try FinalScore(rounded)
    }
}
