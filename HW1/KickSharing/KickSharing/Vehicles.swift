//
//  Vehicles.swift
//  KickSharing
//
//  Created by Сергей Зауэрс on 11.10.2026.
//

import Foundation

/// Общая реализация для всех ТС — уменьшает дублирование.
class BaseVehicle: Vehicle {
    let inventoryNumber: String
    let displayName: String
    let dailyEnergyKWh: Double
    let newbieFriendliness: Int
    var isApproved: Bool = false

    init(
        inventoryNumber: String,
        displayName: String,
        dailyEnergyKWh: Double,
        newbieFriendliness: Int
    ) {
        self.inventoryNumber = inventoryNumber
        self.displayName = displayName
        self.dailyEnergyKWh = dailyEnergyKWh
        self.newbieFriendliness = newbieFriendliness
    }
}

final class Scooter: BaseVehicle {
    init(inventoryNumber: String, dailyEnergyKWh: Double, newbieFriendliness: Int) {
        super.init(
            inventoryNumber: inventoryNumber,
            displayName: "Scooter",
            dailyEnergyKWh: dailyEnergyKWh,
            newbieFriendliness: newbieFriendliness
        )
    }
}

final class Bicycle: BaseVehicle {
    init(inventoryNumber: String, newbieFriendliness: Int) {
        super.init(
            inventoryNumber: inventoryNumber,
            displayName: "Bicycle",
            dailyEnergyKWh: 0.0,
            newbieFriendliness: newbieFriendliness
        )
    }
}

final class ElectricBicycle: BaseVehicle {
    init(inventoryNumber: String, dailyEnergyKWh: Double, newbieFriendliness: Int) {
        super.init(
            inventoryNumber: inventoryNumber,
            displayName: "Electric Bicycle",
            dailyEnergyKWh: dailyEnergyKWh,
            newbieFriendliness: newbieFriendliness
        )
    }
}
