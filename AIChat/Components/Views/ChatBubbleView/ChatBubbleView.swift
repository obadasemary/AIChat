//
//  ChatBubbleView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 02.06.2025.
//

import SwiftUI

struct ChatBubbleView: View {
    
    var text: String = "This is a sample text"
    var textColor: Color = .primary
    var backgroundColor: Color = Color(uiColor: .systemGray6)
    
    var showImage: Bool = true
    var imageName: String? = nil
    
    var onImageTapped: (() -> Void)?
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if showImage {
                ZStack {
                    if let imageName {
                        ImageLoaderView(urlString: imageName)
                            .anyButton {
                                onImageTapped?()
                            }
                    } else {
                        Rectangle()
                            .fill(.secondary)
                            .anyButton {
                                onImageTapped?()
                            }
                    }
                }
                .frame(width: 45, height: 45)
                .clipShape(Circle())
                .padding(.top, 10)
            }
            
            Text(text)
                .font(.body)
                .foregroundStyle(textColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(backgroundColor)
                .cornerRadius(6)
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            ChatBubbleView(
                text: "Yes I am one of the best Error: this application, or a library it uses, has passed an invalid numeric value (NaN, or not-a-number) to CoreGraphics API and this value is being ignored. Please fix this problem.",
                imageName: Constants.randomImage
            )
            ChatBubbleView(
                text: "Yes I am one of the best.",
                imageName: Constants.randomImage
            )
            ChatBubbleView(
                text: "If you want to see the backtrace, please set CG_NUMERICS_SHOW_BACKTRACE environmental variable.",
                imageName: Constants.randomImage
            )
            
            ChatBubbleView(
                text: "If you want to see the backtrace, please set CG_NUMERICS_SHOW_BACKTRACE environmental variable.",
                imageName: Constants.randomImage
            )
            
            ChatBubbleView(
                text: "If you want to see the backtrace, please set CG_NUMERICS_SHOW_BACKTRACE environmental variable.",
                textColor: .white,
                backgroundColor: .accent,
                showImage: false
            )
            
            ChatBubbleView(
                text: "If you want to see the backtrace, please set CG_NUMERICS_SHOW_BACKTRACE environmental variable.",
                imageName: Constants.randomImage
            )
        }
    }
    .padding(.horizontal, 4)
}
