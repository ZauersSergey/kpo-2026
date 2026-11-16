//
//  DomainError.swift
//  POS
//
//  Created by Сергей Зауэрс on 16.11.2026.
//

import Foundation

enum DomainError: Error, CustomStringConvertible {
    case emptyName(String)
    case invalidMaxScore(Double)
    case invalidWeight(Double)
    case scoreOutOfRange(value: Double, max: Double)
    case invalidFinalScore(Double)
    case duplicateCriterion(CriterionID)
    case criterionNotFound(CriterionID)
    case studentNotFound(StudentID)
    case evaluationNotFound(StudentID, CriterionID)
    case evaluationAlreadyExists(StudentID, CriterionID)
    case noCriteria
    case invalidNumber(String)
    
    var description: String {
        switch self {
        case .emptyName(let field): "Пустое имя: \(field)"
        case .invalidMaxScore(let value): "Некорректный maxScore: \(value). Должен быть > 0."
        case .invalidWeight(let value): "Некорректный вес: \(value). Должен быть > 0."
        case .scoreOutOfRange(let value, let max): "Балл \(value) вне диапазона 0...\(max)."
        case .invalidFinalScore(let value): "Итог \(value) вне диапазона 0...10."
        case .duplicateCriterion(let id): "Критерий \(id.value) уже существует."
        case .criterionNotFound(let id): "Критерий \(id.value) не найден в рубрикаторе."
        case .studentNotFound(let id): "Студент \(id.value) не найден."
        case .evaluationNotFound(let studentID, let criterionID): "Оценка студента \(studentID.value) по критерию \(criterionID.value) не найдена."
        case .evaluationAlreadyExists(let studentID, let criterionID): "Оценка студента \(studentID.value) по критерию \(criterionID.value) уже существует."
        case .noCriteria: "Рубрикатор пуст: нельзя посчитать итог."
        case .invalidNumber(let raw): "Ожидалось число, получено: \(raw)"
        }
    }
}
