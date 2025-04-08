//
//  CarouselView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 08.04.2025.
//

import SwiftUI

struct CarouselView<Content: View, T: Hashable>: View {
    
    var items: [T]
    @ViewBuilder var content: (T) -> Content
    @State private var selection: T?
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 12) {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(items, id: \.self) { item in
                        content(item)
                            .scrollTransition(
                                .interactive.threshold(
                                    .visible(0.95)
                                ),
                                transition: { content, phase in
                                    content
                                        .scaleEffect(phase.isIdentity ? 1 : 0.9)
                                }
                            )
                            .containerRelativeFrame(
                                .horizontal,
                                alignment: .center
                            )
                            .id(item)
                    }
                }
            }
            .frame(height: 200)
            .scrollIndicators(.hidden)
            .scrollTargetLayout()
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $selection)
            .onChange(of: items.count, { _, _ in
                updateSelectionIfNeeded()
            })
            .onAppear {
                updateSelectionIfNeeded()
                startAutoScroll()
            }
            .onDisappear {
                stopAutoScroll()
            }
            
            HStack(spacing: 8) {
                ForEach(items, id: \.self) { item in
                    Circle()
                        .fill(
                            item == selection ? .accent : .secondary.opacity(0.5)
                        )
                        .frame(width: 8, height: 8)
                }
            }
            .animation(.linear, value: selection)
        }
    }
    
    private func updateSelectionIfNeeded() {
        if selection == nil || selection == items.last {
            selection = items.first
        }
    }
    
    private func startAutoScroll() {
        stopAutoScroll()
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            DispatchQueue.main.async {
                guard let current = selection, let currentIndex = items.firstIndex(of: current) else {
                    selection = items.first
                    return
                }
                
                let nextIndex = (currentIndex + 1) % items.count
                let nextItem = items[nextIndex]
                withAnimation {
                    selection = nextItem
                }
            }
        }
    }

    private func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    CarouselView(items: AvatarModel.mocks) { item in
        HeroCellView(
            title: item.name,
            subtitle: item.characterDescription,
            imageName: item.profileImageName
        )
    }
    .padding()
}
