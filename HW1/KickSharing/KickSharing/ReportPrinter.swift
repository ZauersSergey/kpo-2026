//
//  ReportPrinter.swift
//  KickSharing
//
//  Created by Сергей Зауэрс on 12.10.2026.
//

import Foundation

/// Форматирование вывода. 
enum ReportPrinter {

    static func printReport(
        _ fleet: FleetService,
        to output: (String) -> Void = { print($0) }
    ) {
        output("--- Отчёт по парку ---")
        output("Техники: \(fleet.vehicleCount)")
        output("Вещей:   \(fleet.thingCount)")
        output(
            String(
                format: "Суммарный суточный расход: %.3f кВт·ч",
                fleet.totalDailyEnergyKWh
            )
        )
        
        output("\nТехника, доступная новичкам (порог ≥ 6):")
        let nb = fleet.newbieFriendlyVehicles()
        if nb.isEmpty {
            output("  —")
        } else {
            for v in nb {
                output("  #\(v.inventoryNumber) \(v.displayName) (простота \(v.newbieFriendliness))")
            }
        }

        output("\nВесь инвентарь:")
        for item in fleet.allInventoryItems() {
            output("  [\(item.inventoryNumber)] \(item.displayName)")
        }

        if !fleet.rejectionLog.isEmpty {
            output("\nОтклонено при техосмотре:")
            for entry in fleet.rejectionLog {
                let shown = entry.inventoryNumber.isEmpty
                    ? "<no number>"
                    : "#\(entry.inventoryNumber)"
                output("  \(shown): \(entry.reason)")
            }
        }
    }

    static func printList(
        _ fleet: FleetService,
        to output: (String) -> Void = { print($0) }
    ) {
        for item in fleet.allInventoryItems() {
            output("  [\(item.inventoryNumber)] \(item.displayName)")
        }
    }

    static func printEnergy(
        _ fleet: FleetService,
        to output: (String) -> Void = { print($0) }
    ) {
        output(String(format: "  %.3f кВт·ч/сутки", fleet.totalDailyEnergyKWh))
    }

    static func printNewbies(
        _ fleet: FleetService,
        to output: (String) -> Void = { print($0) }
    ) {
        let list = fleet.newbieFriendlyVehicles()
        if list.isEmpty {
            output("  —")
            return
        }
        for v in list {
            output("  #\(v.inventoryNumber) \(v.displayName) (score \(v.newbieFriendliness))")
        }
    }

    static func printCounts(
        _ fleet: FleetService,
        to output: (String) -> Void = { print($0) }
    ) {
        output("  Техники: \(fleet.vehicleCount), вещей: \(fleet.thingCount)")
    }

    static func printInspectionResult(
        _ result: InspectionResult,
        for v: Vehicle,
        to output: (String) -> Void = { print($0) }
    ) {
        switch result {
        case .accepted:
            output("  ✓ Accepted: \(v.displayName) #\(v.inventoryNumber)")
        case .rejected(let reason):
            let shown = v.inventoryNumber.isEmpty
                ? "<no number>"
                : "#\(v.inventoryNumber)"
            output("  ✗ Rejected: \(v.displayName) \(shown) — \(reason)")
        }
    }
}
