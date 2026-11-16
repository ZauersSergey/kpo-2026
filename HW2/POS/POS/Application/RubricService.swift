//
//  RubricService.swift
//  POS
//
//  Created by Сергей Зауэрс on 16.11.2026.
//

import Foundation

final class RubricService {
    private let repo: RubricRepository
    
    init(repo: RubricRepository) { self.repo = repo }
    
    func addCriterion(name: String, maxScore: Double, weight: Double) throws -> Criterion {
        let nameVO = try CriterionName(name)
        let maxScoreVO = try MaxScore(maxScore)
        let weightVO = try Weight(weight)
        
        let criterion = Criterion(
            id: CriterionID(UUID().uuidString),
            name: nameVO,
            maxScore: maxScoreVO,
            weight: weightVO
        )
        
        var rubric = repo.get()
        try rubric.add(criterion)
        try repo.save(rubric)
        
        return criterion
    }
    
    func list() -> [Criterion] { repo.get().all }
    func rubric() -> Rubric { repo.get() }
}
