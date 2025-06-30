//
//  CustomListCellView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 09.04.2025.
//

import SwiftUI

struct CustomListCellView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    var imageName: String?
    var title: String?
    var subtitle: String?
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                if let imageName = imageName {
                    ImageLoaderView(urlString: imageName)
                } else {
                    Rectangle()
                        .fill(.secondary.opacity(0.5))
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(height: 60)
            .cornerRadius(16)
            
            VStack(alignment: .leading, spacing: 4) {
                if let title = title {
                    Text(title)
                        .font(.headline)
                }
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .padding(.vertical, 4)
        .background(colorScheme.backgroundPrimary)
    }
}

#Preview {
    List {
        CustomListCellView(imageName: Constants.randomImage, title: "Title", subtitle: "Subtitle")
        
        CustomListCellView(imageName: Constants.randomImage, title: "Title", subtitle: "Subtitle")
        
        CustomListCellView(imageName: nil, title: nil, subtitle: nil)
    }
}
