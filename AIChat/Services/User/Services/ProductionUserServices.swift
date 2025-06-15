//
//  ProductionUserServices.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 15.06.2025.
//

import Foundation

struct ProductionUserServices: UserServicesProtocol {
    let remoteService: RemoteUserServiceProtocol = FirebaseUserService()
    let localStorage: LocalUserServiceProtocol = FileManagerUserPersistance(
        keychain: KeychainHelper()
    )
}
