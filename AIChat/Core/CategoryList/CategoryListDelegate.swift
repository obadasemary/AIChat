//
//  CategoryListDelegate.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 31.07.2025.
//

import SwiftUI

struct CategoryListDelegate {
    var category: CharacterOption = .alien
    var imageName: String = Constants.randomImage
    var path: Binding<[TabbarPathOption]>
}
