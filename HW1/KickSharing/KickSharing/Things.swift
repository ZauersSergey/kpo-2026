//
//  Things.swift
//  KickSharing
//
//  Created by Сергей Зауэрс on 11.10.2026.
//

import Foundation

final class Helmet: Thing {
    let inventoryNumber: String
    let displayName: String = "Helmet"
    let size: String

    init(inventoryNumber: String, size: String) {
        self.inventoryNumber = inventoryNumber
        self.size = size
    }
}

final class DockingStation: Thing {
    let inventoryNumber: String
    let displayName: String = "Docking Station"
    let capacity: Int

    init(inventoryNumber: String, capacity: Int) {
        self.inventoryNumber = inventoryNumber
        self.capacity = capacity
    }
}

final class ChargingCabinet: Thing {
    let inventoryNumber: String
    let displayName: String = "Charging Cabinet"
    let slots: Int

    init(inventoryNumber: String, slots: Int) {
        self.inventoryNumber = inventoryNumber
        self.slots = slots
    }
}
