//
//  Error+EXT.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 26.06.2025.
//

import Foundation

extension Error {
    
    var eventParameters: [String: Any] {
        [
            "error_description": localizedDescription
        ]
    }
}
