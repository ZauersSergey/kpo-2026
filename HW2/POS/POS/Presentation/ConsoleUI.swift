//
//  ConsoleUI.swift
//  POS
//
//  Created by Сергей Зауэрс on 16.11.2026.
//

import Foundation

final class ConsoleUI {
    private let facade: POSFacade
    
    init(facade: POSFacade) { self.facade = facade }
    
    func run() {
        print("Преподавательская Оценка Студентов")
        
        while true {
            printMenu()
            print("Выберите пункт: ", terminator: "")
            
            guard let line = readLine() else {
                print("\nВыход.")
                return
            }
            
            let choice = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            do {
                switch choice {
                case "1": try addStudent()
                case "2": try addCriterion()
                case "3": listStudents()
                case "4": listCriteria()
                case "5": try assignEvaluation()
                case "6": try listEvaluations()
                case "7": try correctEvaluation()
                case "8": try cancelEvaluation()
                case "9": try showFinalScore()
                case "10": try exportReport()
                case "11": DemoRunner(facade: facade).run()
                case "0": print("Конец."); return
                default: print("Неизвестная команда.") }
            } catch { print("Ошибка: \(error)") }
        }
    }
    
    private func printMenu() {
        print(
            """
            1. Добавить студента
            2. Добавить критерий
            3. Показать студентов
            4. Показать критерии
            5. Выставить оценку
            6. Показать оценки студента
            7. Исправить оценку
            8. Отменить оценку
            9. Посчитать итог студенту
            10. Экспорт итогов в JSON
            11. Демо-сценарий
            0. Выход
            """
        )
    }
    
    private func ask(_ prompt: String) -> String {
        print(prompt, terminator: " ")
        return readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    private func askDouble(_ prompt: String) throws -> Double {
        let raw = ask(prompt).replacingOccurrences(of: ",", with: ".")
        guard let value = Double(raw), value.isFinite else { throw DomainError.invalidNumber(raw) }
        return value
    }
    
    private func addStudent() throws {
        let name = ask("Имя студента:")
        let dto = try facade.addStudent(name: name)
        print("Добавлен студент: \(dto.id) - \(dto.name)")
    }
    
    private func addCriterion() throws {
        let name = ask("Название критерия:")
        let maxScore = try askDouble("maxScore:")
        let weight = try askDouble("Вес:")
        
        let dto = try facade.addCriterion(
            name: name,
            maxScore: maxScore,
            weight: weight
        )
        
        print("Добавлен критерий: \(dto.id) - \(dto.name), max=\(dto.maxScore), weight=\(dto.weight)")
    }
    
    private func listStudents() {
        let students = facade.listStudents()
        
        if students.isEmpty {
            print("Студентов нет.")
        } else {
            for student in students {
                print("\(student.id) - \(student.name)")
            }
        }
    }
    
    private func listCriteria() {
        let criteria = facade.listCriteria()
        
        if criteria.isEmpty {
            print("Критериев нет.")
        } else {
            for criterion in criteria {
                print("\(criterion.id) - \(criterion.name), max=\(criterion.maxScore), weight=\(criterion.weight)")
            }
        }
    }
    
    private func assignEvaluation() throws {
        let studentID = ask("ID студента:")
        let criterionID = ask("ID критерия:")
        let score = try askDouble("Балл:")
        
        let dto = try facade.assignEvaluation(
            studentID: studentID,
            criterionID: criterionID,
            score: score
        )
        
        print("Оценка выставлена: \(dto.studentName) / \(dto.criterionName) = \(dto.score)/\(dto.maxScore)")
    }
    
    private func listEvaluations() throws {
        let studentID = ask("ID студента:")
        let evaluations = try facade.listEvaluations(studentID: studentID)
        
        if evaluations.isEmpty {
            print("Оценок нет.")
        } else {
            for evaluation in evaluations {
                print("\(evaluation.criterionName): \(evaluation.score)/\(evaluation.maxScore)")
            }
        }
    }
    
    private func correctEvaluation() throws {
        let studentID = ask("ID студента:")
        let criterionID = ask("ID критерия:")
        let newScore = try askDouble("Новый балл:")
        let dto = try facade.correctEvaluation(
            studentID: studentID,
            criterionID: criterionID,
            newScore: newScore
        )
        
        print("Оценка исправлена: \(dto.studentName) / \(dto.criterionName) = \(dto.score)/\(dto.maxScore)")
    }
    
    private func cancelEvaluation() throws {
        let studentID = ask("ID студента:")
        let criterionID = ask("ID критерия:")
        
        try facade.cancelEvaluation(
            studentID: studentID,
            criterionID: criterionID
        )
        
        print("Оценка отменена.")
    }
    
    private func showFinalScore() throws {
        let studentID = ask("ID студента:")
        let score = try facade.finalScore(for: studentID)
        print(String(format: "Итог: %.2f", score))
    }
    
    private func exportReport() throws {
        let json = try facade.exportReportJSON()
        print("Итоговый отчёт:")
        print(json)
    }
}
