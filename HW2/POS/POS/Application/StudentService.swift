//
//  StudentService.swift
//  POS
//
//  Created by Сергей Зауэрс on 16.11.2026.
//

import Foundation

final class StudentService {
    private let repo: StudentRepository

    init(repo: StudentRepository) { self.repo = repo }

    func addStudent(name: String) throws -> Student {
        let nameVO = try StudentName(name)
        let student = Student(
            id: StudentID(UUID().uuidString),
            name: nameVO
        )
        try repo.add(student)
        return student
    }
    
    func list() -> [Student] { repo.all().sorted { $0.name.value < $1.name.value } }
    func find(_ id: StudentID) -> Student? { repo.find(by: id) }
}
