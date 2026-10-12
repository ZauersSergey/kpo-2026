//
//  FleetService.swift
//  KickSharing
//
//  Created by Сергей Зауэрс on 11.10.2026.
//

import Foundation

/// Доменный сервис учёта парка.
final class FleetService {
    private let inspector: InspectionService

    private(set) var vehicles: [Vehicle] = []
    private(set) var things: [Thing] = []
    private(set) var rejectionLog: [(inventoryNumber: String, reason: String)] = []

    init(inspector: InspectionService) {
        self.inspector = inspector
    }

    // MARK: - Приём

    @discardableResult
    func addVehicle(_ vehicle: Vehicle) -> InspectionResult {
        let result = inspector.inspect(vehicle)
        switch result {
        case .accepted:
            vehicle.isApproved = true
            vehicles.append(vehicle)
        case .rejected(let reason):
            rejectionLog.append((vehicle.inventoryNumber, reason))
        }
        return result
    }

    func addThing(_ thing: Thing) {
        things.append(thing)
    }

    // MARK: - Отчёты

    var vehicleCount: Int { vehicles.count }
    var thingCount: Int { things.count }

    var totalDailyEnergyKWh: Double {
        vehicles.reduce(0) { $0 + $1.dailyEnergyKWh }
    }

    func newbieFriendlyVehicles() -> [Vehicle] {
        vehicles.filter { $0.isSuitableForNewbies }
    }

    /// Техника + вещи одним списком.
    func allInventoryItems() -> [InventoryItem] {
        (vehicles as [InventoryItem]) + (things as [InventoryItem])
    }
}
