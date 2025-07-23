@Observable
@MainActor
class CategoryListViewModel {
    
    private let avatarManager: AvatarManager
    private let logManager: LogManager
    
    var avatars: [AvatarModel] = []
    
    private(set) var isLoading: Bool = true
    
    var showAlert: AnyAppAlert?
    
    init(container: DIContainer) {
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.logManager = container.resolve(LogManager.self)!
    }
}