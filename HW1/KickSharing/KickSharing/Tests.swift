//
//  Tests.swift
//  KickSharing
//
//  Created by Сергей Зауэрс on 11.10.2026.
//

import Foundation

final class AlwaysAcceptInspector: InspectionService {
    func inspect(_ vehicle: Vehicle) -> InspectionResult { .accepted }
}

final class AlwaysRejectInspector: InspectionService {
    let reason: String
    init(reason: String = "fake reject") { self.reason = reason }
    func inspect(_ vehicle: Vehicle) -> InspectionResult { .rejected(reason: reason) }
}

final class RecordingInspector: InspectionService {
    private(set) var inspectedNumbers: [String] = []
    var result: InspectionResult = .accepted

    func inspect(_ vehicle: Vehicle) -> InspectionResult {
        inspectedNumbers.append(vehicle.inventoryNumber)
        return result
    }
}

func registerFleetTests(_ runner: TestRunner) {

    // 1. Приём через fake-инспектор: accepted
    runner.test("addVehicle: accepted через fake-инспектор") {
        let fleet = FleetService(inspector: AlwaysAcceptInspector())
        let s = Scooter(inventoryNumber: "SC-1", dailyEnergyKWh: 1.2, newbieFriendliness: 8)
        let r = fleet.addVehicle(s)
        try expectEqual(r, .accepted)
        try expectEqual(fleet.vehicleCount, 1)
        try expect(s.isApproved, "флаг isApproved должен выставиться")
    }

    // 2. Приём через fake-инспектор: rejected
    runner.test("addVehicle: rejected через fake-инспектор") {
        let fleet = FleetService(inspector: AlwaysRejectInspector(reason: "broken brake"))
        let s = Scooter(inventoryNumber: "SC-2", dailyEnergyKWh: 1.0, newbieFriendliness: 7)
        let r = fleet.addVehicle(s)
        try expectEqual(r, .rejected(reason: "broken brake"))
        try expectEqual(fleet.vehicleCount, 0)
        try expect(!s.isApproved)
        try expectEqual(fleet.rejectionLog.count, 1)
    }

    // 3. Суммарное энергопотребление
    runner.test("totalDailyEnergyKWh: суммирует только принятую технику") {
        let fleet = FleetService(inspector: AlwaysAcceptInspector())
        fleet.addVehicle(Scooter(inventoryNumber: "SC-3", dailyEnergyKWh: 1.5, newbieFriendliness: 5))
        fleet.addVehicle(Scooter(inventoryNumber: "SC-4", dailyEnergyKWh: 2.25, newbieFriendliness: 7))
        fleet.addThing(Helmet(inventoryNumber: "HM-1", size: "M")) // не влияет
        try expectEqual(fleet.totalDailyEnergyKWh, 3.75)
    }

    // 4. Правило «для новичков»
    runner.test("newbieFriendlyVehicles: порог ≥ 6") {
        let fleet = FleetService(inspector: AlwaysAcceptInspector())
        fleet.addVehicle(Scooter(inventoryNumber: "SC-5", dailyEnergyKWh: 1, newbieFriendliness: 6))
        fleet.addVehicle(Scooter(inventoryNumber: "SC-6", dailyEnergyKWh: 1, newbieFriendliness: 5))
        fleet.addVehicle(Bicycle(inventoryNumber: "BC-1", newbieFriendliness: 9))
        let ids = fleet.newbieFriendlyVehicles().map { $0.inventoryNumber }
        try expectEqual(ids, ["SC-5", "BC-1"])
    }

    // 5. Реальное решение техосмотра — reject на некорректный балл
    runner.test("DefaultServiceCenter: reject при newbieFriendliness = 0") {
        let sc = DefaultServiceCenter()
        let bad = Scooter(inventoryNumber: "SC-7", dailyEnergyKWh: 1, newbieFriendliness: 0)
        if case .rejected = sc.inspect(bad) {
            // ок
        } else {
            throw TestFailure(message: "ожидался rejected")
        }
    }

    // 6. Реальное решение техосмотра — accept на валидный
    runner.test("DefaultServiceCenter: accept на валидное ТС") {
        let sc = DefaultServiceCenter()
        let good = Scooter(inventoryNumber: "SC-8", dailyEnergyKWh: 1.0, newbieFriendliness: 6)
        try expectEqual(sc.inspect(good), .accepted)
    }

    // 7. Правило «для новичков» через реальный сервис
    runner.test("isSuitableForNewbies: граница 5/6") {
        let low  = Scooter(inventoryNumber: "SC-9",  dailyEnergyKWh: 1, newbieFriendliness: 5)
        let high = Scooter(inventoryNumber: "SC-10", dailyEnergyKWh: 1, newbieFriendliness: 6)
        try expect(!low.isSuitableForNewbies)
        try expect(high.isSuitableForNewbies)
    }

    // 8. Подмена зависимости через DI-контейнер
    runner.test("DI: подмена InspectionService через контейнер") {
        let di = DIContainer()
        di.register(InspectionService.self) { AlwaysRejectInspector(reason: "DI fake") }
        di.register(FleetService.self, asSingleton: true) { [unowned di] in
            FleetService(inspector: di.resolve(InspectionService.self))
        }
        let fleet = di.resolve(FleetService.self)
        let r = fleet.addVehicle(
            Scooter(inventoryNumber: "SC-11", dailyEnergyKWh: 1, newbieFriendliness: 8)
        )
        try expectEqual(r, .rejected(reason: "DI fake"))
    }

    // 9. Убеждаемся, что инспектор реально вызывается
    runner.test("Spy: инспектор вызывается для каждого ТС") {
        let spy = RecordingInspector()
        let fleet = FleetService(inspector: spy)
        fleet.addVehicle(Scooter(inventoryNumber: "SC-12", dailyEnergyKWh: 1, newbieFriendliness: 7))
        fleet.addVehicle(Bicycle(inventoryNumber: "BC-2", newbieFriendliness: 9))
        try expectEqual(spy.inspectedNumbers, ["SC-12", "BC-2"])
    }

    // 10. Инвентарный список содержит и технику, и вещи
    runner.test("allInventoryItems: техника + вещи") {
        let fleet = FleetService(inspector: AlwaysAcceptInspector())
        fleet.addVehicle(Scooter(inventoryNumber: "SC-13", dailyEnergyKWh: 1, newbieFriendliness: 7))
        fleet.addThing(Helmet(inventoryNumber: "HM-2", size: "L"))
        let ids = fleet.allInventoryItems().map { $0.inventoryNumber }.sorted()
        try expectEqual(ids, ["HM-2", "SC-13"])
    }
}
