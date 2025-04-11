//
//  ChatRowCellView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 11.04.2025.
//

import SwiftUI

struct ChatRowCellView: View {
    
    var imageName: String? = Constants.randomImage
    var headline: String?
    var subheadline: String?
    var hasNewMessages: Bool = true
    
    var body: some View {
        List {
            HStack(spacing: 8) {
                ZStack {
                    if let imageName {
                        ImageLoaderView(urlString: imageName)
                    } else {
                        Rectangle()
                            .fill(.secondary.opacity(0.5))
                    }
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    if let headline {
                        Text(headline)
                            .font(.headline)
                    }
                    
                    if let subheadline {
                        Text(subheadline)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if hasNewMessages {
                    Text("New")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background {
                            Color.blue
                        }
                        .cornerRadius(6)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background {
                Color(uiColor: .systemBackground)
            }
        }
    }
}

#Preview {
    ChatRowCellView()
        .padding()
}
