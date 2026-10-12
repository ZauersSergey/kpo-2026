//
//  main.swift
//  KickSharing
//
//  Created by Сергей Зауэрс on 11.10.2026.
//

import Foundation

func makeContainer() -> DIContainer {
    let di = DIContainer()
    di.register(InspectionService.self) { DefaultServiceCenter() }
    di.register(FleetService.self, asSingleton: true) { [unowned di] in
        FleetService(inspector: di.resolve(InspectionService.self))
    }
    return di
}

// MARK: - Точка входа

let di = makeContainer()
let fleet = di.resolve(FleetService.self)
let args = Array(CommandLine.arguments.dropFirst())

// 1. Тесты.
if args.contains("--test") {
    let runner = TestRunner()
    registerFleetTests(runner)
    exit(runner.run() ? 0 : 1)
}

// 2. Сценарий из файла: ./KickSharing --file demo.txt
if let i = args.firstIndex(of: "--file"), i + 1 < args.count {
    let path = args[i + 1]
    do {
        let source = try FileCommandSource(path: path)
        ScenarioRunner(fleet: fleet, source: source).run()
        exit(0)
    } catch {
        FileHandle.standardError.write(
            Data("Не удалось открыть файл \(path): \(error)\n".utf8)
        )
        exit(2)
    }
}

ScenarioRunner(fleet: fleet, source: ConsoleCommandSource()).run()
