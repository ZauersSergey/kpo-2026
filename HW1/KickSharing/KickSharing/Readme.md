# KickSharing
## Запуск
Xcode 27, macOS Command Line Tool. Аргументы:

- без аргументов — интерактивная консоль (команды вводятся пользователем);
- `--file <path>` — проиграть сценарий из файла;
- `--test` — запустить юнит-тесты.

Примеры:

    ./KickSharing                      # интерактив
    ./KickSharing --file demo.txt      # сценарий из файла
    ./KickSharing --test               # тесты
    cat demo.txt | ./KickSharing       # pipe (CI)

## Архитектура
- **Domain** (`Domain.swift`): `InventoryItem`, `EnergyConsumer`, `Vehicle`, `Thing`, `InspectionService`, `InspectionResult`.
- **Модель** (`Vehicles.swift`, `Things.swift`): `BaseVehicle` + `Scooter`/`Bicycle`/`ElectricBicycle`; `Helmet`, `DockingStation`, `ChargingCabinet`.
- **Сервис** (`FleetService.swift`): реестр парка, агрегированные отчёты, фильтр новичков.
- **Техосмотр** (`ServiceCenter.swift`): `DefaultServiceCenter` — реализация `InspectionService`.
- **DI** (`DIContainer.swift`): строковые ключи, ленивые синглтоны.
- **Composition Root** — `main.swift` → `makeContainer()`.

## Разделение интерфейса и бизнес-логики
Данные приходят извне через
абстракцию `CommandSource`:
- `FleetService` — только бизнес-логика. Ничего не знает про консоль,
  файл и формат вывода.
- `CommandSource` — протокол источника команд.
  - `ConsoleCommandSource` — чтение из stdin (интерактив или pipe).
  - `FileCommandSource` — чтение из файла-сценария.
- `ScenarioRunner` — парсит команды и вызывает методы `FleetService`.
- `ReportPrinter` — форматирует вывод. Отделён от домена (SRP).

Один и тот же `ScenarioRunner` работает и с консолью, и с файлом, и с pipe —
формат команд единый. Источник подставляется снаружи, что дополнительно
демонстрирует DIP.

## Формат команд
    ADD_SCOOTER <inv> <energy> <score>
    ADD_EBIKE   <inv> <energy> <score>
    ADD_BICYCLE <inv> <score>
    ADD_HELMET  <inv> <size>
    ADD_DOCK    <inv> <capacity>
    ADD_CABINET <inv> <slots>
    LIST | ENERGY | NEWBIES | COUNTS | REPORT | HELP | QUIT

Строки, начинающиеся с `#`, игнорируются. См. `demo.txt`.

## SOLID
**Наиболее явно — DIP.** `FleetService` не создаёт инспектора сам, а принимает `InspectionService` через `init`. В тестах через DI подставляются `AlwaysAcceptInspector` / `AlwaysRejectInspector` / `RecordingInspector` (`Tests.swift`), в проде — `DefaultServiceCenter`.

**ISP / OCP.** Абстракции `InventoryItem` и `EnergyConsumer` разделены: `Thing` не обязан реализовывать энергию; `EnergyConsumer` не обязан иметь инвентарный номер (полезно для будущих датчиков). Новые виды транспорта добавляются подклассом `BaseVehicle` — `FleetService` и отчёты не меняются.

**SRP.** Модель ↔ сервис парка ↔ техосмотр ↔ DI — четыре независимых модуля.

**Сознательно «почти нарушен» LSP.** `Bicycle` унаследован от `BaseVehicle` (и, соответственно, `EnergyConsumer`) с `dailyEnergyKWh = 0.0`. Формально `Bicycle` «потребляет 0», что для физического велосипеда — натяжка. Альтернатива — отдельный `NonPoweredVehicle`, но она приводит к размножению иерархий и к дублированию отчётной логики. Ограничение приемлемо, потому что `EnergyConsumer` трактуется как «суточный расход ресурса, приведённый к энергии», и нулевое значение корректно складывается в `totalDailyEnergyKWh`.

## Что сломается при расширении
- **Новый транспорт** (`CargoScooter`): добавляется класс-наследник `BaseVehicle`. `FleetService`, отчёты, DI — **не меняются**.
- **Сотрудник** (`Employee`): сейчас в модели нет — по условию сотрудники на баланс не ставятся. Если понадобится, введём протокол `Employee` и `EmployeeService` **отдельно** от `InventoryItem`; `FleetService` не затрагивается.
- **Склад запчастей** (`SparePartsWarehouse`): это отдельная агрегатная сущность. `SparePart: InventoryItem` можно добавить в `FleetService.addThing` без правок домена транспорта.

## Тесты — что фиксируют
- **Решение техосмотра**: тесты «DefaultServiceCenter: accept/reject...» + «addVehicle: accepted/rejected через fake-инспектор».
- **Правило для новичков**: «newbieFriendlyVehicles: порог ≥ 6» и «isSuitableForNewbies: граница 5/6».
- **Подмена зависимости**: тест «DI: подмена InspectionService через контейнер» — регистрируется `AlwaysRejectInspector`, `FleetService` резолвится из `DIContainer` и получает отказ. Spy-тест «Spy: инспектор вызывается для каждого ТС» проверяет, что взаимодействие действительно произошло.
- Покрытие: доменные правила + инспекция + DI + агрегаты (≈10 тестов, ориентировочно >60% логики).

## Использование ИИ
- спроектирован DI-контейнер (фабрики + ленивые синглтоны);
- написан собственный мини-раннер тестов
- написан Readme.md
