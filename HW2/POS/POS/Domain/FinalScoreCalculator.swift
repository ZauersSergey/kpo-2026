//
//  FinalScoreCalculator.swift
//  POS
//
//  Created by Сергей Зауэрс on 16.11.2026.
//

import Foundation

final class FinalScoreCalculator {
    private let strategy: FinalScoreStrategy
    
    init(strategy: FinalScoreStrategy) { self.strategy = strategy }
    
    func calculate(evaluations: [Evaluation], rubric: Rubric) throws -> FinalScore {
        try strategy.calculate(evaluations: evaluations, rubric: rubric)
    }
}
