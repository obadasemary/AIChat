//
//  FirebaseImageUploadServiceProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 16.06.2025.
//

import SwiftUI

protocol FirebaseImageUploadServiceProtocol: Sendable {
    func uploadImage(image: UIImage, path: String) async throws -> URL
}
