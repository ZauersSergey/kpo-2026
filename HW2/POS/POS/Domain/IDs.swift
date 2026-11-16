//
//  IDs.swift
//  POS
//
//  Created by Сергей Зауэрс on 16.11.2026.
//

import Foundation

struct StudentID: Hashable, Codable {
    let value: String
    
    init(_ value: String) { self.value = value }
}

struct CriterionID: Hashable, Codable {
    let value: String
    
    init(_ value: String) { self.value = value }
}
