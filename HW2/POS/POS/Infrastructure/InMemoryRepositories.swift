//
//  InMemoryRepositories.swift
//  POS
//
//  Created by Сергей Зауэрс on 16.11.2026.
//

import Foundation

final class InMemoryStudentRepository: StudentRepository {
    private var students: [StudentID: Student] = [:]
    func add(_ student: Student) throws { students[student.id] = student }
    func all() -> [Student] { Array(students.values) }
    func find(by id: StudentID) -> Student? { students[id] }
}

final class InMemoryRubricRepository: RubricRepository {
    private var rubric = Rubric()
    func get() -> Rubric { rubric }
    func save(_ rubric: Rubric) throws { self.rubric = rubric }
}

final class InMemoryEvaluationRepository: EvaluationRepository {
    private var items: [String: Evaluation] = [:]
    private func key(_ studentID: StudentID, _ criterionID: CriterionID) -> String { "\(studentID.value)::\(criterionID.value)" }
    func save(_ evaluation: Evaluation) throws { items[key(evaluation.studentID, evaluation.criterion.id)] = evaluation }
    func find(studentID: StudentID, criterionID: CriterionID) -> Evaluation? { items[key(studentID, criterionID)] }
    func findByStudent(_ studentID: StudentID) -> [Evaluation] { items.values.filter { $0.studentID == studentID } }
    func all() -> [Evaluation] { Array(items.values) }
    func delete(studentID: StudentID, criterionID: CriterionID) throws {
        let key = key(studentID, criterionID)

        guard items.removeValue(forKey: key) != nil else {
            throw DomainError.evaluationNotFound(studentID, criterionID)
        }
    }
}
