//
//  ScenarioRunner.swift
//  KickSharing
//
//  Created by Сергей Зауэрс on 12.10.2026.
//

import Foundation

/// Читает команды из CommandSource и вызывает методы FleetService.
final class ScenarioRunner {
    private let fleet: FleetService
    private let source: CommandSource
    private let output: (String) -> Void
    private var shouldQuit = false

    init(
        fleet: FleetService,
        source: CommandSource,
        output: @escaping (String) -> Void = { print($0) }
    ) {
        self.fleet = fleet
        self.source = source
        self.output = output
    }

    func run() {
        while !shouldQuit, let line = source.nextLine() {
            let parts = line.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
            guard let command = parts.first else { continue }
            handle(command: command.uppercased(), args: Array(parts.dropFirst()))
        }
    }

    private func handle(command: String, args: [String]) {
        switch command {
        case "ADD_SCOOTER":
            guard args.count == 3,
                  let energy = Double(args[1]),
                  let score = Int(args[2]) else {
                output("! ADD_SCOOTER <inv> <energy> <score>"); return
            }
            let v = Scooter(
                inventoryNumber: args[0],
                dailyEnergyKWh: energy,
                newbieFriendliness: score
            )
            ReportPrinter.printInspectionResult(fleet.addVehicle(v), for: v, to: output)

        case "ADD_EBIKE":
            guard args.count == 3,
                  let energy = Double(args[1]),
                  let score = Int(args[2]) else {
                output("! ADD_EBIKE <inv> <energy> <score>"); return
            }
            let v = ElectricBicycle(
                inventoryNumber: args[0],
                dailyEnergyKWh: energy,
                newbieFriendliness: score
            )
            ReportPrinter.printInspectionResult(fleet.addVehicle(v), for: v, to: output)

        case "ADD_BICYCLE":
            guard args.count == 2, let score = Int(args[1]) else {
                output("! ADD_BICYCLE <inv> <score>"); return
            }
            let v = Bicycle(inventoryNumber: args[0], newbieFriendliness: score)
            ReportPrinter.printInspectionResult(fleet.addVehicle(v), for: v, to: output)

        case "ADD_HELMET":
            guard args.count == 2 else {
                output("! ADD_HELMET <inv> <size>"); return
            }
            fleet.addThing(Helmet(inventoryNumber: args[0], size: args[1]))
            output("  + Helmet #\(args[0]) (\(args[1]))")

        case "ADD_DOCK":
            guard args.count == 2, let cap = Int(args[1]) else {
                output("! ADD_DOCK <inv> <capacity>"); return
            }
            fleet.addThing(DockingStation(inventoryNumber: args[0], capacity: cap))
            output("  + DockingStation #\(args[0]) (\(cap))")

        case "ADD_CABINET":
            guard args.count == 2, let slots = Int(args[1]) else {
                output("! ADD_CABINET <inv> <slots>"); return
            }
            fleet.addThing(ChargingCabinet(inventoryNumber: args[0], slots: slots))
            output("  + ChargingCabinet #\(args[0]) (\(slots))")

        case "REPORT": ReportPrinter.printReport(fleet, to: output)
        case "LIST": ReportPrinter.printList(fleet, to: output)
        case "ENERGY": ReportPrinter.printEnergy(fleet, to: output)
        case "NEWBIES": ReportPrinter.printNewbies(fleet, to: output)
        case "COUNTS": ReportPrinter.printCounts(fleet, to: output)
        case "HELP": output(Self.helpText)
        case "QUIT", "EXIT": shouldQuit = true

        default: output("! Неизвестная команда: \(command). HELP — список.")
        }
    }

    static let helpText = """
    Команды:
      ADD_SCOOTER <inv> <energy> <score>   — добавить самокат
      ADD_EBIKE   <inv> <energy> <score>   — добавить электровелосипед
      ADD_BICYCLE <inv> <score>            — добавить велосипед
      ADD_HELMET  <inv> <size>             — добавить шлем
      ADD_DOCK    <inv> <capacity>         — добавить док-станцию
      ADD_CABINET <inv> <slots>            — добавить зарядный шкаф
      LIST                                 — весь инвентарь
      ENERGY                               — суммарный расход
      NEWBIES                              — техника для новичков
      COUNTS                               — счётчики
      REPORT                               — полный отчёт
      HELP                                 — эта справка
      QUIT                                 — выход
    """
}
