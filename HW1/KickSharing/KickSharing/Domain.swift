//
//  Domain.swift
//  KickSharing
//
//  Created by Сергей Зауэрс on 11.10.2026.
//

import Foundation

// MARK: - Базовые абстракции

/// Всё, что ставится на баланс и имеет инвентарный номер.
protocol InventoryItem: AnyObject {
    var inventoryNumber: String { get }
    var displayName: String { get }
}

/// Всё, что потребляет суточный ресурс (кВт·ч).
protocol EnergyConsumer: AnyObject {
    var dailyEnergyKWh: Double { get }
}

/// Транспорт: инвентаризуется, потребляет энергию, имеет «простоту для новичка».
protocol Vehicle: InventoryItem, EnergyConsumer {
    /// 1...10
    var newbieFriendliness: Int { get }
    /// Выставляется сервисом после успешного техосмотра.
    var isApproved: Bool { get set }
}

extension Vehicle {
    /// Базовое правило: ≥ 6 — можно новичкам.
    var isSuitableForNewbies: Bool { newbieFriendliness >= 6 }
}

/// Вещи на балансе (шлемы, док-станции, зарядные шкафы...).
protocol Thing: InventoryItem {}

// MARK: - Техосмотр

enum InspectionResult: Equatable {
    case accepted
    case rejected(reason: String)
}

/// Абстракция техосмотра. Легко подменяется в тестах через DI.
protocol InspectionService: AnyObject {
    func inspect(_ vehicle: Vehicle) -> InspectionResult
}
