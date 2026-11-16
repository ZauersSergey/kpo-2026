//
//  DIContainer.swift
//  POS
//
//  Created by Сергей Зауэрс on 16.11.2026.
//

import Foundation

final class DIContainer {
    private var storage: [String: Any] = [:]

    func register<T>(_ type: T.Type, _ instance: T) { storage[String(reflecting: type)] = instance }
    
    func resolve<T>(_ type: T.Type) -> T {
        let key = String(reflecting: type)
        guard let value = storage[key] as? T else { fatalError("Dependency not registered: \(key)") }
        return value
    }
}
