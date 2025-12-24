//
//  DevSettingsViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation
import SwiftUI

@Observable
@MainActor
class DevSettingsPresenter {

    private let devSettingsInteractor: DevSettingsInteractorProtocol
    private let router: DevSettingsRouterProtocol

    var createAccountTest: Bool = false
    var onboardingCommunityTest: Bool = false
    var categoryRowTest: CategoryRowTestOption = .default
    var paywallOption: PaywallOptional = .custom
    var colorSchemePreference: ColorSchemePreference = .light

    var authData: [(key: String, value: Any)] {
        devSettingsInteractor
            .auth?
            .eventParameters
            .asAlphabeticalArray ?? []
    }

    var userData: [(key: String, value: Any)] {
        devSettingsInteractor
            .currentUser?
            .eventParameters
            .asAlphabeticalArray ?? []
    }

    var utilities: [(key: String, value: Any)] {
        Utilities
            .eventParameters
            .asAlphabeticalArray
    }

    init(
        devSettingsInteractor: DevSettingsInteractorProtocol,
        router: DevSettingsRouterProtocol
    ) {
        self.devSettingsInteractor = devSettingsInteractor
        self.router = router
    }
}

// MARK: - Load
extension DevSettingsPresenter {
    
    func loadABTest() {
        createAccountTest = devSettingsInteractor.activeTests.createAccountTest
        onboardingCommunityTest = devSettingsInteractor.activeTests.onboardingCommunityTest
        categoryRowTest = devSettingsInteractor.activeTests.categoryRowTest
        paywallOption = devSettingsInteractor.activeTests.paywallOption
        colorSchemePreference = ColorSchemeManager.shared.currentPreference

        // Sync PaywallConfiguration with saved value
        PaywallConfiguration.shared.updateOption(paywallOption)
    }
}

// MARK: - Action
extension DevSettingsPresenter {

    func onBackButtonTap() {
        router.dismissScreen()
    }
    
    func handleCreateAccountChange(oldValue: Bool, newValue: Bool) {
        updateTest(
            property: &createAccountTest,
            newValue: newValue,
            savedValue: devSettingsInteractor.activeTests.createAccountTest
        ) { tests in
            tests.update(createAccountTest: newValue)
        }
    }
    
    func handleOnboardingCommunityChange(oldValue: Bool, newValue: Bool) {
        updateTest(
            property: &onboardingCommunityTest,
            newValue: newValue,
            savedValue: devSettingsInteractor.activeTests.onboardingCommunityTest
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
            savedValue: devSettingsInteractor.activeTests.categoryRowTest
        ) { tests in
            tests.update(categoryRowTest: newValue)
        }
    }
    
    func handlePaywallOptionChange(
        oldValue: PaywallOptional,
        newValue: PaywallOptional
    ) {
        updateTest(
            property: &paywallOption,
            newValue: newValue,
            savedValue: devSettingsInteractor.activeTests.paywallOption
        ) { tests in
            tests.update(paywallOption: newValue)
        }
        // Only update PaywallConfiguration if persistence succeeded
        if paywallOption == newValue {
            PaywallConfiguration.shared.updateOption(newValue)
        }
    }
    
    @MainActor
    func handleColorSchemeChange(
        oldValue: ColorSchemePreference,
        newValue: ColorSchemePreference
    ) {
        withAnimation(.smooth(duration: 0.35)) {
            ColorSchemeManager.shared.updatePreference(newValue)
        }
    }
}

private extension DevSettingsPresenter {
    
    func updateTest<T: Equatable>(
        property: inout T,
        newValue: T,
        savedValue: T,
        updateAction: (inout ActiveABTests) -> Void
    ) {
        if newValue != savedValue {
            do {
                var tests = devSettingsInteractor.activeTests
                updateAction(&tests)
                try devSettingsInteractor.override(updateTests: tests)
            } catch {
                property = savedValue
            }
        }
    }
}
