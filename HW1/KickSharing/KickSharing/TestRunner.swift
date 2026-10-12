//
//  TestRunner.swift
//  KickSharing
//
//  Created by Сергей Зауэрс on 11.10.2026.
//

import Foundation

struct TestFailure: Error, CustomStringConvertible {
    let message: String
    var description: String { message }
}

func expect(_ condition: Bool, _ message: String = "expectation failed") throws {
    if !condition { throw TestFailure(message: message) }
}

func expectEqual<T: Equatable>(_ a: T, _ b: T, _ message: String = "") throws {
    if a != b {
        throw TestFailure(message: "\(message) — expected \(b), got \(a)")
    }
}

final class TestRunner {
    private struct Case {
        let name: String
        let body: () throws -> Void
    }

    private var cases: [Case] = []

    func test(_ name: String, _ body: @escaping () throws -> Void) {
        cases.append(Case(name: name, body: body))
    }

    /// Возвращает true, если все тесты прошли.
    @discardableResult
    func run() -> Bool {
        var passed = 0
        var failed = 0

        print("\n=== KickSharing test suite ===")
        for c in cases {
            do {
                try c.body()
                print("  ✓ \(c.name)")
                passed += 1
            } catch {
                print("  ✗ \(c.name) — \(error)")
                failed += 1
            }
        }
        print("=== passed: \(passed), failed: \(failed) ===\n")
        return failed == 0
    }
}
