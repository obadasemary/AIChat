//
//  String+EXT.swift
//  SamuraiLoggingMixpanel
//
//  Created by Abdelrahman Mohamed on 19.03.2026.
//

import Foundation

extension String {

    func clipped(maxCharacters: Int) -> String {
        String(prefix(maxCharacters))
    }
}
