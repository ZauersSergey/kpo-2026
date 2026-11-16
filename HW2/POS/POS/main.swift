//
//  main.swift
//  POS
//
//  Created by Сергей Зауэрс on 16.11.2026.
//

import Foundation

let container = makeContainer()
let facade = container.resolve(POSFacade.self)

if CommandLine.arguments.contains("--demo") {
    DemoRunner(facade: facade).run()
} else if CommandLine.arguments.contains("--test") {
    DomainChecks.run()
} else {
    ConsoleUI(facade: facade).run()
}
