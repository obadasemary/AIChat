//
//  HeroCellView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 08.04.2025.
//

import SwiftUI

struct HeroCellView: View {
    
    var title: String? = "This is some title"
    var subtitle: String? = "This is some subtitle that will go here."
    var imageName: String? = Constants.randomImage
    
    var body: some View {
        ZStack {
            if let imageName {
                ImageLoaderView(urlString: imageName)
            } else {
                Rectangle()
                    .fill(.accent)
            }
        }
        .overlay(alignment: .bottomLeading) {
            VStack(alignment: .leading, spacing: 4) {
                if let title {
                    Text(title)
                        .font(.headline)
                }
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                }
            }
            .foregroundColor(.white)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            .black.opacity(0),
                            .black.opacity(0.3),
                            .black.opacity(0.4)
                        ]
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .cornerRadius(16)
    }
}

#Preview {
    ScrollView {
        VStack {
            HeroCellView()
                .frame(width: 380, height: 200)
            HeroCellView(imageName: nil)
                .frame(width: 380, height: 200)
            HeroCellView(title: nil)
                .frame(width: 380, height: 200)
            HeroCellView(subtitle: nil)
                .frame(width: 380, height: 200)
        }
        .frame(maxWidth: .infinity)
    }
}
