# ПОС - Преподавательская Оценка Студентов
# Зауэрс Сергей Дмитриевич

Домашнее задание №2 по курсу «Конструирование программного обеспечения».
Консольный модуль учёта преподавательской оценки студентов: студенты, рубрикатор,
оценки, итог по весам, экспорт итогов в JSON.

- Язык: Swift
- Архитектура: Clean
- Паттерны GoF: Factory, Facade, Strategy
- DI: свой простой контейнер + `CompositionRoot`

---

## Как запустить

Нужен установленный компилятор Swift:

- Linux: [swift.org/download](https://www.swift.org/download/) - тулчейн для Ubuntu/Fedora и т.п. После установки `swiftc --version` должен отвечать.
- Windows: [swift.org/download](https://www.swift.org/download/) - Swift for Windows (ставится вместе с Visual Studio Build Tools). После установки `swiftc --version` должен отвечать (проверять в x64 Native Tools Command Prompt или Developer PowerShell).

### Linux / macOS (терминал)

Из папки HW2/POS/POS

    swiftc \
      Domain/*.swift \
      Application/*.swift \
      Infrastructure/*.swift \
      Presentation/*.swift \
      DI/*.swift \
      main.swift \
      -o pos

Запуск:

    ./pos            # интерактивное меню
    ./pos --demo     # демо-сценарий
    ./pos --test     # проверки инвариантов и Domain Service

### Windows (PowerShell)

Из корня проекта:

    swiftc `
      Domain\*.swift `
      Application\*.swift `
      Infrastructure\*.swift `
      Presentation\*.swift `
      DI\*.swift `
      main.swift `
      -o pos.exe

Запуск:

    .\pos.exe            # интерактивное меню
    .\pos.exe --demo     # демо-сценарий
    .\pos.exe --test     # проверки инвариантов

В обычном `cmd.exe` - одной строкой:

    swiftc Domain\*.swift Application\*.swift Infrastructure\*.swift Presentation\*.swift DI\*.swift main.swift -o pos.exe

Я не проверял этот запуск, потому что у меня только Mac. Если не сработает, то запишу видео как у меня всё собирается на Mac
---

## Архитектура

Выбрана Clean. Зависимости направлены строго внутрь - к домену:

    Presentation (ConsoleUI, DemoRunner)
            │  видит только POSFacade
            ▼
    Application (Services, DTO, ExporterPort, RepositoryPorts)
            │  знает Domain и порты
            ▼
    Domain (Entities, VO, Factory, Strategy, FinalScoreCalculator)
            ▲
            │  реализует порты
    Infrastructure (InMemoryRepositories, JSONFinalReportExporter)

- Domain - модель, value objects, инварианты, доменные сервисы, порты репозиториев. Не знает про infrastructure.
- Application - use cases: студенты, критерии, оценки, расчёт итога, экспорт. Ходит в домен через порты и Domain Service, наружу отдаёт DTO.
- Infrastructure - конкретные реализации портов: in-memory репозитории, JSON-экспортёр. Может меняться независимо.
- Presentation - консольный UI и демо-сценарий. Никакой бизнес-логики - только ввод/вывод и вызовы фасада.
- DI - простой контейнер + единственное место в проекте, где собирается граф зависимостей.


---

## DDD

### Ubiquitous Language
| Термин | В коде |
|---|---|
| студент | `Student` |
| критерий | `Criterion` |
| рубрикатор | `Rubric` (агрегат-корень) |
| оценка | `Evaluation` |
| балл | `Score` |
| итог | `FinalScore` |

### Entity и Value Object

Entity - идентичность и жизненный цикл:
- `Student` (id + name),
- `Criterion` (id + name + maxScore + weight),
- `Evaluation` (studentID + criterion + score).

Value Object - определяется значением, без своего ID:
- `StudentID`, `CriterionID` - типизированные идентификаторы,
- `StudentName`, `CriterionName` - непустые имена,
- `MaxScore`, `Weight` - положительные конечные числа,
- `Score` - балл в пределах критерия,
- `FinalScore` - итог `0...10`.

Пример разделения: `Criterion` - entity, потому что у него устойчивый `CriterionID` и он живёт в рубрикаторе (`add`, `criterion(by:)`). `MaxScore` - VO: два `MaxScore(10)` неразличимы, у него нет идентичности, только значение. VO валидирует себя в `init` и не пропускает невалидные данные внутрь модели.

### Инварианты - охраняются моделью

| Правило | Где охраняется |
|---|---|
| Балл не выходит за пределы критерия | `Score.create(value:maxScore:)` - единственный способ создать `Score`, `init` приватный |
| Оценку можно ставить только по критерию из рубрикатора | `EvaluationFactory.make` ищет критерий в `Rubric`, иначе `criterionNotFound` |
| Итог согласован с текущими оценками | `FinalScoreCalculator` считает итог каждый раз из `[Evaluation]` и `Rubric`, ничего не хранится |
| Нет дубликатов критериев | `Rubric.add` отбивает `duplicateCriterion` |
| Вес и максимум положительны | `MaxScore.init`, `Weight.init` |
| Имена не пустые | `StudentName.init`, `CriterionName.init` |

### Repository (порт)

`Domain/RepositoryPorts.swift` объявляет три порта: `StudentRepository`, `RubricRepository`, `EvaluationRepository`. Application и Presentation зависят только от них.

Реализации лежат в `Infrastructure/` (`InMemoryStudentRepository`, `InMemoryRubricRepository`, `InMemoryEvaluationRepository`) и подставляются в `CompositionRoot`. 
### Domain Service

`FinalScoreCalculator` + `FinalScoreStrategy`. Правило «итог = взвешенная сумма по рубрикатору» не принадлежит одной сущности: оно одновременно зависит от `Evaluation`, `Criterion` и `Rubric`. Поэтому вынесено в доменный сервис, а конкретная формула - в `WeightedTenPointStrategy` (GoF Strategy).

Итог не хранится полем ни в одной сущности. `FinalScoreService` в Application каждый раз собирает оценки студента и текущий рубрикатор и отдаёт калькулятору. Если критерий добавили или оценку исправили - итог при следующем запросе уже новый. Это и есть «согласован с текущим набором оценок».

---

## GoF - три паттерна, по одному на группу

### Factory (порождающий) - `EvaluationFactory`

Зачем: `Evaluation` нельзя создать без критерия из рубрикатора и без проверки `score ∈ [0, maxScore]`. Если разрешить `Evaluation.init` наружу, правило будет размазано по UI и сервисам, и рано или поздно кто-нибудь его обойдёт.

Как: единственная точка создания `Evaluation`. Фабрика получает `Rubric` и `criterionID`, находит критерий (иначе `criterionNotFound`), затем создаёт `Evaluation` через `Evaluation.create` → `Score.create` с проверкой диапазона.

### Facade (структурный) - `POSFacade`

Зачем: UI не должен знать про четыре сервиса, репозитории, стратегию, экспортёр и DTO-маппинг. Иначе сценарии размазываются по консоли и любые изменения в сервисах тянут правки в Presentation.

Как: один класс `POSFacade` - единая точка сценариев для Presentation. Внутри - `StudentService`, `RubricService`, `EvaluationService`, `FinalScoreService`, `FinalReportExporter`. Наверх отдаёт только DTO.

### Strategy (поведенческий) - `FinalScoreStrategy`

Зачем: правило итога может меняться - взвешенное 10-балльное, экзаменационное, пороговое. Если правило зашито в Domain Service, любое изменение - правка домена и риск регрессии.

Как: интерфейс `FinalScoreStrategy`, конкретная реализация - `WeightedTenPointStrategy`. `FinalScoreCalculator` делегирует стратегии. Добавить новую стратегию - новый `struct`, реализующий протокол, плюс одна строка в `CompositionRoot`.

Больше паттернов не добавлял специально: три уместных лучше шести декоративных, и по ТЗ это допустимый максимум.

---

## DI

`DI/DIContainer.swift` - минимальный контейнер: `register`/`resolve` по `String(reflecting: Type.self)`.

`DI/CompositionRoot.swift` - единственное место в проекте, где руками собирается граф зависимостей:

    let studentRepo = InMemoryStudentRepository()
    let rubricRepo  = InMemoryRubricRepository()
    let evaluationRepo = InMemoryEvaluationRepository()

    let factory = EvaluationFactory()
    let strategy: FinalScoreStrategy = WeightedTenPointStrategy()
    let calculator = FinalScoreCalculator(strategy: strategy)
    let exporter: FinalReportExporter = JSONFinalReportExporter()

    let studentService = StudentService(repo: studentRepo)
    let rubricService = RubricService(repo: rubricRepo)
    let evaluationService = EvaluationService(
        studentRepo: studentRepo,
        rubricRepo: rubricRepo,
        evaluationRepo: evaluationRepo,
        factory: factory
    )
    let finalScoreService = FinalScoreService(
        studentRepo: studentRepo,
        rubricRepo: rubricRepo,
        evaluationRepo: evaluationRepo,
        calculator: calculator
    )

    let facade = POSFacade(
        studentService: studentService,
        rubricService: rubricService,
        evaluationService: evaluationService,
        finalScoreService: finalScoreService,
        exporter: exporter
    )

    container.register(POSFacade.self, facade)

Замена хранилища, стратегии или экспортёра - точечная, ровно здесь. Остальной код про это не знает.

---

## Тесты

`Presentation/DomainChecks.swift`, запуск `--test`. Проверяется:

1. `Score.create` отклоняет балл больше максимума (11 при `maxScore = 10`).
2. `FinalScoreCalculator` на одиночной оценке 9/10 с весом возвращает `9.0`.
3. Валидная `Evaluation` создаётся и хранит `score.value`.

Пример вывода:

    ОК: балл больше максимума отклонён
    ОК: итог = 9.0
    Проверки домена пройдены.

Этих трёх проверок достаточно, чтобы показать: инварианты работают, Domain Service считает корректно, и что новые правила (например, пороговое округление итога) ломают тест - то есть тест реально что-то охраняет.

---

## Функциональные сценарии

| # | Сценарий | Где |
|---|---|---|
| 1 | Добавить студента, посмотреть список | `StudentService`, `POSFacade` |
| 2 | Добавить критерий (`name`, `maxScore`, `weight`), посмотреть список | `RubricService` |
| 3 | Выставить оценку студенту по критерию | `EvaluationService.assign` |
| 4 | Исправить оценку | `EvaluationService.correct` |
| 5 | Отменить оценку | `EvaluationService.cancel` |
| 6 | Посмотреть оценки студента | `EvaluationService.list` |
| 7 | Посчитать итог студента | `FinalScoreService` + `FinalScoreCalculator` |
| 8 | Экспорт итогов в JSON | `JSONFinalReportExporter` |
| 9 | Демо-сценарий | `DemoRunner`, `--demo` |

---

## Роль ИИ

ИИ использовал как вспомогательный инструмент: помощь в понимании задачи, описание задачи простым языком, помощь в составлении README, ответы на теоретические вопросы по DDD, вопросы по компиляции Swift проекта не на Mac. Компиляцию не на Mac я не проверял, поэтому если не получится запустить, то запишу видео как у меня всё собирается

---

