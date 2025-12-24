//
//  AboutViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 01.12.2025.
//

import SwiftUI
import SwiftfulUtilities

@Observable
@MainActor
class AboutPresenter {

    private let aboutInteractor: AboutInteractorProtocol
    private let router: AboutRouterProtocol

    var appVersion: String {
        aboutInteractor.appVersion
    }

    var buildNumber: String {
        aboutInteractor.buildNumber
    }

    init(
        aboutInteractor: AboutInteractorProtocol,
        router: AboutRouterProtocol
    ) {
        self.aboutInteractor = aboutInteractor
        self.router = router
    }
}

// MARK: - Actions
extension AboutPresenter {

    func onContactSupportPressed() {
        aboutInteractor.trackEvent(event: Event.contactSupportPressed)

        let email = "obada.semary@gmail.com"
        let subject = "AIChat Support Request"
        let body = """


        ---
        App Version: \(appVersion)
        Build Number: \(buildNumber)
        """

        let emailString = "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"

        guard let url = URL(string: emailString),
              UIApplication.shared.canOpenURL(url)
        else {
            aboutInteractor.trackEvent(event: Event.contactSupportFailed)
            return
        }

        UIApplication.shared.open(url)
    }

    func onPrivacyPolicyPressed() {
        aboutInteractor.trackEvent(event: Event.privacyPolicyPressed)
        
        guard let url = URL(string: "https://SamuraiStudios.com/privacy") else {
            aboutInteractor.trackEvent(event: Event.privacyPolicyFailed)
            return
        }
        UIApplication.shared.open(url)
    }

    func onTermsOfServicePressed() {
        aboutInteractor.trackEvent(event: Event.termsOfServicePressed)
        
        guard let url = URL(string: "https://SamuraiStudios.com/terms") else {
            aboutInteractor.trackEvent(event: Event.termsOfServiceFailed)
            return
        }
        UIApplication.shared.open(url)
    }
}

// MARK: - Event
private extension AboutPresenter {

    enum Event: LoggableEvent {
        case contactSupportPressed
        case contactSupportFailed
        case privacyPolicyPressed
        case privacyPolicyFailed
        case termsOfServicePressed
        case termsOfServiceFailed

        var eventName: String {
            switch self {
            case .contactSupportPressed: "AboutView_ContactSupport_Pressed"
            case .contactSupportFailed: "AboutView_ContactSupport_Failed"
            case .privacyPolicyPressed: "AboutView_PrivacyPolicy_Pressed"
            case .privacyPolicyFailed: "AboutView_PrivacyPolicy_Failed"
            case .termsOfServicePressed: "AboutView_TermsOfService_Pressed"
            case .termsOfServiceFailed: "AboutView_TermsOfService_Failed"
            }
        }

        var parameters: [String: Any]? {
            return nil
        }

        var type: LogType {
            switch self {
            case .contactSupportFailed, .privacyPolicyFailed, .termsOfServiceFailed:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
