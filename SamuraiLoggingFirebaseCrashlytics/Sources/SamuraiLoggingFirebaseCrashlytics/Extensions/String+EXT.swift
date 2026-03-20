//
//  String+EXT.swift
//  SamuraiLoggingFirebaseCrashlytics
//
//  Created by Abdelrahman Mohamed on 19.03.2026.
//

import Foundation

extension String {
    var stableHashValue: Int {
        let unicodeScalars = self.unicodeScalars.map { $0.value }
        return unicodeScalars.reduce(5381) { ($0 << 5) &+ $0 &+ Int($1) }
    }
}
