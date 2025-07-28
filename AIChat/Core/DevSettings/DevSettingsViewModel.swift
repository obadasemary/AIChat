//
//  DevSettingsViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@Observable
@MainActor
class DevSettingsViewModel {
    
    private let devSettingsUseCase: DevSettingsUseCaseProtocol
    
    var createAccountTest: Bool = false
    var onboardingCommunityTest: Bool = false
    var categoryRowTest: CategoryRowTestOption = .default
    
    var authData: [(key: String, value: Any)] {
        devSettingsUseCase
            .auth?
            .eventParameters
            .asAlphabeticalArray ?? []
    }
    
    var userData: [(key: String, value: Any)] {
        devSettingsUseCase
            .currentUser?
            .eventParameters
            .asAlphabeticalArray ?? []
    }
    
    var utilities: [(key: String, value: Any)] {
        Utilities
            .eventParameters
            .asAlphabeticalArray
    }
    
    init(devSettingsUseCase: DevSettingsUseCaseProtocol) {
        self.devSettingsUseCase = devSettingsUseCase
    }
}

// MARK: - Load
extension DevSettingsViewModel {
    
    func loadABTest() {
        createAccountTest = devSettingsUseCase.activeTests.createAccountTest
        onboardingCommunityTest = devSettingsUseCase.activeTests.onboardingCommunityTest
        categoryRowTest = devSettingsUseCase.activeTests.categoryRowTest
    }
}

// MARK: - Action
extension DevSettingsViewModel {
    
    func onBackButtonTap(onDissmiss: () -> Void) {
        onDissmiss()
    }
    
    func handleCreateAccountChange(oldValue: Bool, newValue: Bool) {
        updateTest(
            property: &createAccountTest,
            newValue: newValue,
            savedValue: devSettingsUseCase.activeTests.createAccountTest
        ) { tests in
            tests.update(createAccountTest: newValue)
        }
    }
    
    func handleOnboardingCommunityChange(oldValue: Bool, newValue: Bool) {
        updateTest(
            property: &onboardingCommunityTest,
            newValue: newValue,
            savedValue: devSettingsUseCase.activeTests.onboardingCommunityTest
        ) { tests in
            tests.update(onboardingCommunityTest: newValue)
        }
    }
    
    func handleOnCategoryRowOptionChange(
        oldValue: CategoryRowTestOption,
        newValue: CategoryRowTestOption
    ) {
        updateTest(
            property: &categoryRowTest,
            newValue: newValue,
            savedValue: devSettingsUseCase.activeTests.categoryRowTest
        ) { tests in
            tests.update(categoryRowTest: newValue)
        }
    }
}

private extension DevSettingsViewModel {
    
    func updateTest<T: Equatable>(
        property: inout T,
        newValue: T,
        savedValue: T,
        updateAction: (inout ActiveABTests) -> Void
    ) {
        if newValue != savedValue {
            do {
                var tests = devSettingsUseCase.activeTests
                updateAction(&tests)
                try devSettingsUseCase.override(updateTests: tests)
            } catch {
                property = savedValue
            }
        }
    }
}
