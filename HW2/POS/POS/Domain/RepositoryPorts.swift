//
//  RepositoryPorts.swift
//  POS
//
//  Created by Сергей Зауэрс on 16.11.2026.
//

import Foundation

protocol StudentRepository: AnyObject {
    func add(_ student: Student) throws
    func all() -> [Student]
    func find(by id: StudentID) -> Student?
}

protocol RubricRepository: AnyObject {
    func get() -> Rubric
    func save(_ rubric: Rubric) throws
}

protocol EvaluationRepository: AnyObject {
    func save(_ evaluation: Evaluation) throws
    func find(studentID: StudentID, criterionID: CriterionID) -> Evaluation?
    func findByStudent(_ studentID: StudentID) -> [Evaluation]
    func all() -> [Evaluation]
    func delete(studentID: StudentID, criterionID: CriterionID) throws
}
