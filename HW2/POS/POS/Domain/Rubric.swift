//
//  Rubric.swift
//  POS
//
//  Created by Сергей Зауэрс on 16.11.2026.
//

import Foundation

struct Rubric {
    private var criteriaByID: [CriterionID: Criterion] = [:]
    
    init() {}
    
    mutating func add(_ criterion: Criterion) throws {
        if criteriaByID[criterion.id] != nil { throw DomainError.duplicateCriterion(criterion.id) }
        criteriaByID[criterion.id] = criterion
    }
    
    func criterion(by id: CriterionID) -> Criterion? { criteriaByID[id] }
    var all: [Criterion] { criteriaByID.values.sorted { $0.name.value < $1.name.value } }
    var isEmpty: Bool { criteriaByID.isEmpty }
}
