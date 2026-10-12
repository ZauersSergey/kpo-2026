//
//  DIContainer.swift
//  KickSharing
//
//  Created by Сергей Зауэрс on 11.10.2026.
//

import Foundation

final class DIContainer {
    private var factories: [String: () -> Any] = [:]
    private var singletons: Set<String> = []
    private var cache: [String: Any] = [:]

    private func key<T>(_ type: T.Type) -> String {
        String(describing: type)
    }

    func register<T>(
        _ type: T.Type,
        asSingleton: Bool = false,
        _ factory: @escaping () -> T
    ) {
        let k = key(type)
        factories[k] = factory
        if asSingleton { singletons.insert(k) }
    }

    func resolve<T>(_ type: T.Type) -> T {
        let k = key(type)

        if singletons.contains(k), let cached = cache[k] as? T {
            return cached
        }
        guard let factory = factories[k] else {
            fatalError("DI: no registration for \(k)")
        }
        let value = factory()
        if singletons.contains(k) { cache[k] = value }
        guard let typed = value as? T else {
            fatalError("DI: type mismatch for \(k)")
        }
        return typed
    }
}
