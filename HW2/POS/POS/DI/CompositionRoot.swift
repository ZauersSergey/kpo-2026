//
//  CompositionRoot.swift
//  POS
//
//  Created by Сергей Зауэрс on 16.11.2026.
//

import Foundation

func makeContainer() -> DIContainer {
    let container = DIContainer()
    let studentRepo = InMemoryStudentRepository()
    let rubricRepo = InMemoryRubricRepository()
    let evaluationRepo = InMemoryEvaluationRepository()
    let evaluationFactory = EvaluationFactory()
    let strategy: FinalScoreStrategy = WeightedTenPointStrategy()
    let calculator = FinalScoreCalculator(strategy: strategy)
    let exporter = JSONFinalReportExporter()
    let studentService = StudentService(repo: studentRepo)
    let rubricService = RubricService(repo: rubricRepo)
    
    let evaluationService = EvaluationService(
        studentRepo: studentRepo,
        rubricRepo: rubricRepo,
        evaluationRepo: evaluationRepo,
        factory: evaluationFactory
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
    
    container.register(StudentService.self, studentService)
    container.register(RubricService.self, rubricService)
    container.register(EvaluationService.self, evaluationService)
    container.register(FinalScoreService.self, finalScoreService)
    container.register(POSFacade.self, facade)
    
    return container
}
