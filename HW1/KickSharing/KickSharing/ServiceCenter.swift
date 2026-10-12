//
//  ServiceCenter.swift
//  KickSharing
//
//  Created by Сергей Зауэрс on 11.10.2026.
//

import Foundation

final class DefaultServiceCenter: InspectionService {
    func inspect(_ vehicle: Vehicle) -> InspectionResult {
        let trimmed = vehicle.inventoryNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return .rejected(reason: "empty inventory number")
        }
        guard vehicle.dailyEnergyKWh >= 0 else {
            return .rejected(reason: "negative daily energy consumption")
        }
        guard (1...10).contains(vehicle.newbieFriendliness) else {
            return .rejected(reason: "newbieFriendliness must be in 1...10")
        }
        return .accepted
    }
}
