//
//  CategoryRowTestOption.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 09.07.2025.
//

import Foundation

enum CategoryRowTestOption: String, Codable, CaseIterable {
    case original
    case top
    case hidden
    
    static var `default`: Self {
        .original
    }
}
