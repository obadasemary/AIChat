//
//  ActiveABTestsTests.swift
//  AIChatTests
//
//  Created by Abdelrahman Mohamed on 14.07.2025.
//

import Testing
import Foundation
@testable import AIChat

struct ActiveABTestsTests {
    
    // swiftlint:disable large_tuple
    private typealias RandomData = (
        createAccountTest: Bool,
        onboardingCommunityTest: Bool,
        categoryRowTest: CategoryRowTestOption,
        paywallOption: PaywallOptional
    )
    // swiftlint:enable large_tuple

    private func makeRandomData() -> RandomData {
        let create = Bool.random()
        let onboarding = Bool.random()
        let category = CategoryRowTestOption.allCases.randomElement() ?? .default
        let paywall = PaywallOptional.allCases.randomElement() ?? .custom
        return (create, onboarding, category, paywall)
    }

    private func makeModel(from data: RandomData) -> ActiveABTests {
        return ActiveABTests(
            createAccountTest: data.createAccountTest,
            onboardingCommunityTest: data.onboardingCommunityTest,
            categoryRowTest: data.categoryRowTest,
            paywallOption: data.paywallOption
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
        await #expect(
            service.activeTests.paywallOption == data.paywallOption
        )
    }
    
    @Test("MockABTestService Save Updated Config")
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
        await #expect(
            mockService.activeTests.paywallOption == newModel.paywallOption
        )
    }
    
    @Test("MockABTestService Fetch and Save")
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
        #expect(fetched.paywallOption == initialModel.paywallOption)

        // Prepare a new model and save it
        let newData = makeRandomData()
        let newModel = makeModel(from: newData)
        try await service.saveUpdatedConfig(updatedTest: newModel)

        // Fetch again should return the new model
        let refetched = try await service.fetchUpdatedConfig()
        #expect(refetched.createAccountTest == newModel.createAccountTest)
        #expect(refetched.onboardingCommunityTest == newModel.onboardingCommunityTest)
        #expect(refetched.categoryRowTest == newModel.categoryRowTest)
        #expect(refetched.paywallOption == newModel.paywallOption)
    }
    
    @Test("MockABTestService Fetch Updated Config")
    func testFetchUpdatedConfig() async throws {
        let initialData = makeRandomData()
        let initialModel = makeModel(from: initialData)
        let service = await MockABTestService(activeTests: initialModel)

        let fetchedConfig = try await service.fetchUpdatedConfig()

        #expect(
            fetchedConfig.createAccountTest == initialData.createAccountTest
        )
        #expect(
            fetchedConfig.onboardingCommunityTest == initialData.onboardingCommunityTest
        )
        #expect(fetchedConfig.categoryRowTest == initialData.categoryRowTest)
        #expect(fetchedConfig.paywallOption == initialData.paywallOption)
    }

    @Test("ActiveABTests Event Parameters")
    func testEventParameters() async throws {
        let initialData = makeRandomData()
        let initialModel = makeModel(from: initialData)
        let service = await MockABTestService(activeTests: initialModel)

        let params = await service.activeTests.eventParameters

        #expect(
            params["test_20250720_CreateAccTest"] as? Bool == initialData
                .createAccountTest
        )
        #expect(
            params["test_20250720_OnbCommunityTest"] as? Bool == initialData
                .onboardingCommunityTest
        )
        #expect(
            params["test_20250720_CateegoryRowTest"] as? String == initialData
                .categoryRowTest
                .rawValue
        )
        #expect(
            params["test_20250720_PaywallOption"] as? String == initialData
                .paywallOption
                .rawValue
        )
    }

    @Test("ActiveABTests Codable Conformance")
    func testCodableConformance() async throws {
        let randomCreateAccountTest = Bool.random
        let randomOnboardingCommunityTest = Bool.random
        let randomCategoryRowTest = CategoryRowTestOption.allCases.randomElement() ?? .default
        let randomPaywallOption = PaywallOptional.allCases.randomElement() ?? .custom

        let originalTests = ActiveABTests(
            createAccountTest: randomCreateAccountTest(),
            onboardingCommunityTest: randomOnboardingCommunityTest(),
            categoryRowTest: randomCategoryRowTest,
            paywallOption: randomPaywallOption
        )

        // Encode ActiveABTests to JSON
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalTests)

        // Decode JSON back to ActiveABTests
        let decoder = JSONDecoder()
        let decodedTests = try decoder.decode(ActiveABTests.self, from: data)

        // Assert that all properties are equal
        #expect(decodedTests.createAccountTest == originalTests.createAccountTest)
        #expect(decodedTests.onboardingCommunityTest == originalTests.onboardingCommunityTest)
        #expect(decodedTests.categoryRowTest == originalTests.categoryRowTest)
        #expect(decodedTests.paywallOption == originalTests.paywallOption)
    }
}
