//
//  AboutViewModel.swift
//  AIChat
//
//  Created by Claude Code on 01.12.2025.
//

import SwiftUI
import SwiftfulUtilities

@Observable
@MainActor
class AboutViewModel {

    private let aboutUseCase: AboutUseCaseProtocol
    private let router: AboutRouterProtocol

    var appVersion: String {
        aboutUseCase.appVersion
    }

    var buildNumber: String {
        aboutUseCase.buildNumber
    }

    init(
        aboutUseCase: AboutUseCaseProtocol,
        router: AboutRouterProtocol
    ) {
        self.aboutUseCase = aboutUseCase
        self.router = router
    }
}

// MARK: - Actions
extension AboutViewModel {

    func onContactSupportPressed() {
        aboutUseCase.trackEvent(event: Event.contactSupportPressed)

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
            aboutUseCase.trackEvent(event: Event.contactSupportFailed)
            return
        }

        UIApplication.shared.open(url)
    }

    func onPrivacyPolicyPressed() {
        aboutUseCase.trackEvent(event: Event.privacyPolicyPressed)
        // TODO: Open privacy policy URL
        guard let url = URL(string: "https://obada.com/privacy") else { return }
        UIApplication.shared.open(url)
    }

    func onTermsOfServicePressed() {
        aboutUseCase.trackEvent(event: Event.termsOfServicePressed)
        // TODO: Open terms of service URL
        guard let url = URL(string: "https://obada.com/terms") else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Event
private extension AboutViewModel {

    enum Event: LoggableEvent {
        case contactSupportPressed
        case contactSupportFailed
        case privacyPolicyPressed
        case termsOfServicePressed

        var eventName: String {
            switch self {
            case .contactSupportPressed: "AboutView_ContactSupport_Pressed"
            case .contactSupportFailed: "AboutView_ContactSupport_Failed"
            case .privacyPolicyPressed: "AboutView_PrivacyPolicy_Pressed"
            case .termsOfServicePressed: "AboutView_TermsOfService_Pressed"
            }
        }

        var parameters: [String: Any]? {
            return nil
        }

        var type: LogType {
            switch self {
            case .contactSupportFailed:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
