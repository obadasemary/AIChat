//
//  ProductionUserServices.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 15.06.2025.
//

import Foundation

struct ProductionUserServices: UserServicesProtocol {
    let remoteService: RemoteUserServiceProtocol
    let localStorage: LocalUserServiceProtocol
    
    init(
        remoteService: RemoteUserServiceProtocol = FirebaseUserService(),
        localStorage: LocalUserServiceProtocol = FileManagerUserPersistence()
    ) {
        self.remoteService = remoteService
        self.localStorage = localStorage
    }
}
