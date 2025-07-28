//
//  AppViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation
import SwiftfulUtilities

@Observable
@MainActor
class AppViewModel {
    
    private let appViewUseCase: AppViewUseCaseProtocol
    
    init(appViewUseCase: AppViewUseCaseProtocol) {
        self.appViewUseCase = appViewUseCase
    }
}

// MARK: - Action
extension AppViewModel {
    
    func checkUserStatus() async {
        if let user = appViewUseCase.auth {
            appViewUseCase.trackEvent(event: Event.existingAuthStart)
            do {
                try await appViewUseCase.logIn(auth: user, isNewUser: false)
            } catch {
                appViewUseCase
                    .trackEvent(event: Event.existingAuthFail(error: error))
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        } else {
            appViewUseCase.trackEvent(event: Event.anonymousAuthStart)
            do {
                let result = try await appViewUseCase.signInAnonymously()
                appViewUseCase.trackEvent(event: Event.anonymousAuthSuccess)
                try await appViewUseCase
                    .logIn(auth: result.user, isNewUser: result.isNewUser)
            } catch {
                appViewUseCase
                    .trackEvent(event: Event.anonymousAuthFail(error: error))
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        }
    }
    
    func showATTPromptIfNeeded() async {
        #if !DEBUG
        let status = await AppTrackingTransparencyHelper
            .requestTrackingAuthorization()
        
        appViewUseCase
            .trackEvent(
                event: Event.attStatus(
                    dict: status.eventParameters
                )
            )
        #endif
    }
}

// MARK: - Event
private extension AppViewModel {
    
    enum Event: LoggableEvent {
        case existingAuthStart
        case existingAuthFail(error: Error)
        case anonymousAuthStart
        case anonymousAuthSuccess
        case anonymousAuthFail(error: Error)
        case attStatus(dict: [String: Any])
        
        var eventName: String {
            switch self {
            case .existingAuthStart: "AppView_ExistingAuth_Start"
            case .existingAuthFail: "AppView_ExistingAuth_Fail"
            case .anonymousAuthStart: "AppView_AnonymousAuth_Start"
            case .anonymousAuthSuccess: "AppView_AnonymousAuth_Success"
            case .anonymousAuthFail: "AppView_AnonymousAuth_Fail"
            case .attStatus: "AppView_ATT_Status"
            }
        }
        
        var parameters: [String : Any]? {
            switch self {
            case .existingAuthFail(error: let error),
                    .anonymousAuthFail(error: let error):
                error.eventParameters
            case .attStatus(dict: let dict):
                dict
            default:
                nil
            }
        }
        
        var type: LogType {
            switch self {
            case .existingAuthFail, .anonymousAuthFail:
                    .severe
            default:
                    .analytic
            }
        }
    }
}
