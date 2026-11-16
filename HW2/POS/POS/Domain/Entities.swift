//
//  Entities.swift
//  POS
//
//  Created by Сергей Зауэрс on 16.11.2026.
//

import Foundation

struct Student: Equatable {
    let id: StudentID
    let name: StudentName
}

struct Criterion: Equatable {
    let id: CriterionID
    let name: CriterionName
    let maxScore: MaxScore
    let weight: Weight
}
