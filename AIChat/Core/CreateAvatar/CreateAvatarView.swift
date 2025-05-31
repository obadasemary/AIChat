//
//  CreateAvatarView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 30.05.2025.
//

import SwiftUI

struct CreateAvatarView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                
            }
            .navigationTitle("Create Avatar")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .anyButton(.plain) {
                            dismiss()
                        }
                        .foregroundStyle(.accent)
                }
            }
        }
    }
}

#Preview {
    CreateAvatarView()
}
