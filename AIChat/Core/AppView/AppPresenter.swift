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
class AppPresenter {
    
    private let appViewInteractor: AppViewInteractorProtocol
    
    var showTabBar: Bool {
        appViewInteractor.showTabBar
    }
    
    init(appViewInteractor: AppViewInteractorProtocol) {
        self.appViewInteractor = appViewInteractor
    }
}

// MARK: - Action
extension AppPresenter {
    
    func checkUserStatus() async {
        if let user = appViewInteractor.auth {
            appViewInteractor.trackEvent(event: Event.existingAuthStart)
            do {
                try await appViewInteractor.logIn(auth: user, isNewUser: false)
            } catch {
                appViewInteractor
                    .trackEvent(event: Event.existingAuthFail(error: error))
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        } else {
            appViewInteractor.trackEvent(event: Event.anonymousAuthStart)
            do {
                let result = try await appViewInteractor.signInAnonymously()
                appViewInteractor.trackEvent(event: Event.anonymousAuthSuccess)
                try await appViewInteractor
                    .logIn(auth: result.user, isNewUser: result.isNewUser)
            } catch {
                appViewInteractor
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
        
        appViewInteractor
            .trackEvent(
                event: Event.attStatus(
                    dict: status.eventParameters
                )
            )
        #endif
    }
}

// MARK: - Event
private extension AppPresenter {
    
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
