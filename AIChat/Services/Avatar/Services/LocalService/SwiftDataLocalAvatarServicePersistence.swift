//
//  SwiftDataLocalAvatarServicePersistence.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 17.06.2025.
//

import Foundation
import SwiftData

@MainActor
struct SwiftDataLocalAvatarServicePersistence {
    
    private let container: ModelContainer
    
    private var mainContext: ModelContext {
        container.mainContext
    }
    
    init() {
        do {
            self.container = try ModelContainer(for: AvatarEntity.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error.localizedDescription)")
        }
    }
}

extension SwiftDataLocalAvatarServicePersistence: LocalAvatarServicePersistenceProtocol {
    
    func addRecentAvatar(avatar: AvatarModel) throws {
        let entity = AvatarEntity(from: avatar)
        mainContext.insert(entity)
        try mainContext.save()
    }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        let descriptor = FetchDescriptor<AvatarEntity>(
            sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
        )
        let entities = try mainContext.fetch(descriptor)
        return entities.map({ $0.toModel() })
    }
}
