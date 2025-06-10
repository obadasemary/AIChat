//
//  UserAuthInfo+Firebase.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.06.2025.
//

import Foundation
import FirebaseAuth

extension UserAuthInfo {
    init(user: User) {
        self.uid = user.uid
        self.name = user.displayName
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        self.isAnonymous = user.isAnonymous
        self.creationDate = user.metadata.creationDate
        self.lastSignInDate = user.metadata.lastSignInDate
        self.displayName = user.displayName
    }
}
