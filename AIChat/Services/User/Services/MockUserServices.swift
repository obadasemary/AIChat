//
//  MockUserServices.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 15.06.2025.
//

import Foundation

struct MockUserServices: UserServicesProtocol {
    
    let remoteService: RemoteUserServiceProtocol
    let localStorage: LocalUserServiceProtocol
    
    init(currentUser: UserModel? = nil) {
        self.remoteService = MockUserService(currentUser: currentUser)
        self.localStorage = MockUserPersistence(currentUser: currentUser)
    }
}
