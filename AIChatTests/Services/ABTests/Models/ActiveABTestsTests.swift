//
//  ActiveABTestsTests.swift
//  AIChatTests
//
//  Created by Abdelrahman Mohamed on 14.07.2025.
//

import Testing
@testable import AIChat

struct ActiveABTestsTests {
    
    private typealias RandomData = (
        createAccountTest: Bool,
        onboardingCommunityTest: Bool,
        categoryRowTest: CategoryRowTestOption
    )
    
    private func makeRandomData() -> RandomData {
        let create = Bool.random()
        let onboarding = Bool.random()
        let category = CategoryRowTestOption.allCases.randomElement() ?? .default
        return (create, onboarding, category)
    }
    
    private func makeModel(from data: RandomData) -> ActiveABTests {
        return ActiveABTests(
            createAccountTest: data.createAccountTest,
            onboardingCommunityTest: data.onboardingCommunityTest,
            categoryRowTest: data.categoryRowTest
        )
    }

    @Test("ActiveABTests init with values")
    func test_init_withValues() async throws {
        let data = makeRandomData()
        let model = makeModel(from: data)
        
        let service = await MockABTestService(activeTests: model)
        
        await #expect(
            service.activeTests.createAccountTest == data.createAccountTest
        )
        await #expect(
            service.activeTests.onboardingCommunityTest == data.onboardingCommunityTest
        )
        await #expect(
            service.activeTests.categoryRowTest == data.categoryRowTest
        )
    }
    
    @Test("MockABTestService save")
    func test_mockService_Save() async throws {
        // Prepare an initial ActiveABTests instance
        let initialData = makeRandomData()
        let initialModel = makeModel(from: initialData)
        // Initialize service with the model
        let mockService = await MockABTestService(activeTests: initialModel)
        
        // Prepare a new model and save it
        let newData = makeRandomData()
        let newModel = makeModel(from: newData)
        try await mockService.saveUpdatedConfig(updatedTest: newModel)
        
        await #expect(
            mockService.activeTests.createAccountTest == newModel.createAccountTest
        )
        await #expect(
            mockService.activeTests.onboardingCommunityTest == newModel.onboardingCommunityTest
        )
        await #expect(
            mockService.activeTests.categoryRowTest == newModel.categoryRowTest
        )
    }
    
    @Test("MockABTestService fetch and save")
    func test_mockService_fetchAndSave() async throws {
        // Prepare an initial ActiveABTests instance
        let initialData = makeRandomData()
        let initialModel = makeModel(from: initialData)
        // Initialize service with the model
        let service = await MockABTestService(activeTests: initialModel)
        
        // Fetch should return the initial model
        let fetched = try await service.fetchUpdatedConfig()
        #expect(fetched.createAccountTest == initialModel.createAccountTest)
        #expect(fetched.onboardingCommunityTest == initialModel.onboardingCommunityTest)
        #expect(fetched.categoryRowTest == initialModel.categoryRowTest)
        
        // Prepare a new model and save it
        let newData = makeRandomData()
        let newModel = makeModel(from: newData)
        try await service.saveUpdatedConfig(updatedTest: newModel)
        
        // Fetch again should return the new model
        let refetched = try await service.fetchUpdatedConfig()
        #expect(refetched.createAccountTest == newModel.createAccountTest)
        #expect(refetched.onboardingCommunityTest == newModel.onboardingCommunityTest)
        #expect(refetched.categoryRowTest == newModel.categoryRowTest)
    }
}
