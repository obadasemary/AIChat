//
//  ProfileModalView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 03.06.2025.
//

import SwiftUI

struct ProfileModalView: View {
    
    var imageName: String? = Constants.randomImage
    var title: String? = "Alpha"
    var subtitle: String? = "Alien"
    var headline: String? = "An alien in the park."
    var onXMarkTap: () -> Void = { }
    
    var body: some View {
        VStack(spacing: .zero) {
            if let imageName {
                ImageLoaderView(
                    urlString: imageName,
                    forceTransitionAnimation: true
                )
                .aspectRatio(1, contentMode: .fit)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                if let title {
                    Text(title)
                        .font(.title)
                        .fontWeight(.semibold)
                }
                
                if let subtitle {
                    Text(subtitle)
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                
                if let headline {
                    Text(headline)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(.thinMaterial)
        .cornerRadius(16)
        .overlay(
            Image(systemName: "xmark.circle.fill")
                .font(.title)
                .foregroundStyle(.black)
                .padding(4)
                .tappableBackground()
                .anyButton {
                    onXMarkTap()
                }
                .padding(8)
            , alignment: .topTrailing
        )
    }
}

#Preview("Modal w/ Image") {
    ZStack {
        Color.secondary.ignoresSafeArea()
        
        ProfileModalView()
            .padding()
    }
}

#Preview("Modal w/out Image") {
    ZStack {
        Color.secondary.ignoresSafeArea()
        
        ProfileModalView(imageName: nil)
            .padding()
    }
}
