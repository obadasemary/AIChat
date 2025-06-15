//
//  UserServicesProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 15.06.2025.
//

import Foundation

protocol UserServicesProtocol {
    var remoteService: RemoteUserServiceProtocol { get }
    var localStorage: LocalUserServiceProtocol { get }
}
