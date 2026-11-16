//
//  DTOs.swift
//  POS
//
//  Created by Сергей Зауэрс on 16.11.2026.
//

import Foundation

struct StudentDTO {
    let id: String
    let name: String
}

struct CriterionDTO {
    let id: String
    let name: String
    let maxScore: Double
    let weight: Double
}

struct EvaluationDTO {
    let studentID: String
    let studentName: String
    let criterionID: String
    let criterionName: String
    let score: Double
    let maxScore: Double
}

struct FinalReportRow: Codable {
    let studentID: String
    let studentName: String
    let finalScore: Double
}

struct FinalReport: Codable {
    let rows: [FinalReportRow]
}
