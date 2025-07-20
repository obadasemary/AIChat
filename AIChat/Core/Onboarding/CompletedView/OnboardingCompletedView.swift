//
//  OnboardingCompletedView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

struct OnboardingCompletedView: View {
    
    @Environment(AppState.self) private var root
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    
    @State private var isCompletingProfileSetup: Bool = false
    var selectedColor: Color = .accent
    @State private var showAlert: AnyAppAlert?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Setup completed!")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(selectedColor)
            
            Text("we've set up for profile and you're ready to start chatting")
                .font(.title)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
        .safeAreaInset(
            edge: .bottom,
            alignment: .center,
            spacing: 16,
            content: {
                AsyncCallToActionButton(
                    isLoading: isCompletingProfileSetup,
                    title: "Finish",
                    action: onFinishButtonPressed
                )
                .accessibilityIdentifier("FinishButton")
            }
        )
        .padding(24)
        .toolbar(.hidden, for: .navigationBar)
        .screenAppearAnalytics(name: "OnboardingCompletedView")
        .showCustomAlert(alert: $showAlert)
    }
}

// MARK: - Action
private extension OnboardingCompletedView {
    
    func onFinishButtonPressed() {
        isCompletingProfileSetup = true
        logManager.trackEvent(event: Event.finishStart)
        Task {
            do {
                let hex = selectedColor.asHex()
                try await userManager
                    .markOnboardingCompleteForCurrentUser(
                        profileColorHex: hex
                    )
                logManager
                    .trackEvent(
                        event: Event.finishSuccess(
                            hex: hex
                        )
                    )
                
                isCompletingProfileSetup = false
                root.updateViewState(showTabBarView: true)
            } catch {
                showAlert = AnyAppAlert(error: error)
                logManager
                    .trackEvent(
                        event: Event.finishFail(
                            error: error
                        )
                    )
            }
        }
    }
}

// MARK: - Event
private extension OnboardingCompletedView {
    
    enum Event: LoggableEvent {
        case finishStart
        case finishSuccess(hex: String)
        case finishFail(error: Error)
        
        var eventName: String {
            switch self {
            case .finishStart: "OnboardingCompletedView_Finish_Start"
            case .finishSuccess: "OnboardingCompletedView_Finish_Success"
            case .finishFail: "OnboardingCompletedView_Finish_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .finishSuccess(hex: let hex):
                return [
                    "profile_color_hex": hex
                ]
            case .finishFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .finishFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}

#Preview {
    OnboardingCompletedView(selectedColor: .mint)
        .environment(UserManager(services: MockUserServices()))
        .environment(AppState())
        .previewEnvironment()
}
