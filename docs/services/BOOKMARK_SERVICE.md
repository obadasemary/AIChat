# Bookmark Service

The Bookmark Service manages article bookmarking with local persistence.

## Overview

The Bookmark Service provides bookmark functionality for news articles using SwiftData for persistent local storage.

## Architecture

```
BookmarkManager (Orchestration)
    ↓
BookmarkManagerProtocol
    ↓
├── BookmarkManager (Production - SwiftData)
└── MockBookmarkManager (Testing)
```

## Files

| File | Path |
|------|------|
| `BookmarkManager.swift` | `Services/Bookmark/BookmarkManager.swift` |
| `BookmarkManagerProtocol.swift` | `Services/Bookmark/BookmarkManagerProtocol.swift` |
| `MockBookmarkManager.swift` | `Services/Bookmark/Services/MockBookmarkManager.swift` |

### Models
| File | Path |
|------|------|
| `BookmarkArticleEntity.swift` | `Services/Bookmark/Models/BookmarkArticleEntity.swift` |

## Protocol Definition

### BookmarkManagerProtocol
```swift
protocol BookmarkManagerProtocol {
    func addBookmark(article: NewsArticle) async throws
    func removeBookmark(articleId: String) async throws
    func isBookmarked(articleId: String) async -> Bool
    func getAllBookmarks() async throws -> [BookmarkArticleEntity]
    func getBookmark(articleId: String) async throws -> BookmarkArticleEntity?
}
```

## Usage

### Resolving from Container
```swift
let bookmarkManager = container.resolve(BookmarkManager.self)
```

### Add Bookmark
```swift
try await bookmarkManager.addBookmark(article: newsArticle)
```

### Remove Bookmark
```swift
try await bookmarkManager.removeBookmark(articleId: article.id)
```

### Check if Bookmarked
```swift
let isBookmarked = await bookmarkManager.isBookmarked(articleId: article.id)
```

### Get All Bookmarks
```swift
let bookmarks = try await bookmarkManager.getAllBookmarks()
```

## Data Model

### BookmarkArticleEntity (SwiftData)
```swift
@Model
final class BookmarkArticleEntity {
    @Attribute(.unique) var id: String
    var title: String
    var articleDescription: String?
    var content: String?
    var author: String?
    var sourceName: String
    var url: String
    var imageUrl: String?
    var publishedAt: Date
    var category: String?
    var bookmarkedAt: Date

    init(from article: NewsArticle) {
        self.id = article.id
        self.title = article.title
        self.articleDescription = article.description
        self.content = article.content
        self.author = article.author
        self.sourceName = article.source.name
        self.url = article.url
        self.imageUrl = article.imageUrl
        self.publishedAt = article.publishedAt
        self.category = article.category
        self.bookmarkedAt = Date()
    }
}
```

## SwiftData Integration

### Model Container Setup
```swift
@main
struct AIChatApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: BookmarkArticleEntity.self)
    }
}
```

### CRUD Operations
```swift
@MainActor
class BookmarkManager: BookmarkManagerProtocol {
    private let modelContext: ModelContext

    func addBookmark(article: NewsArticle) async throws {
        let entity = BookmarkArticleEntity(from: article)
        modelContext.insert(entity)
        try modelContext.save()
    }

    func removeBookmark(articleId: String) async throws {
        let predicate = #Predicate<BookmarkArticleEntity> {
            $0.id == articleId
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        if let entity = try modelContext.fetch(descriptor).first {
            modelContext.delete(entity)
            try modelContext.save()
        }
    }

    func getAllBookmarks() async throws -> [BookmarkArticleEntity] {
        let descriptor = FetchDescriptor<BookmarkArticleEntity>(
            sortBy: [SortDescriptor(\.bookmarkedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
}
```

## Build Configuration

### Development (.dev)
```swift
bookmarkManager = BookmarkManager()
```

### Production (.prod)
```swift
bookmarkManager = BookmarkManager()
```

### Mock (.mock)
```swift
bookmarkManager = MockBookmarkManager()
```

## Mock Service

```swift
class MockBookmarkManager: BookmarkManagerProtocol {
    private var bookmarks: [String: BookmarkArticleEntity] = [:]

    func addBookmark(article: NewsArticle) async throws {
        let entity = BookmarkArticleEntity(from: article)
        bookmarks[article.id] = entity
    }

    func removeBookmark(articleId: String) async throws {
        bookmarks.removeValue(forKey: articleId)
    }

    func isBookmarked(articleId: String) async -> Bool {
        bookmarks[articleId] != nil
    }

    func getAllBookmarks() async throws -> [BookmarkArticleEntity] {
        Array(bookmarks.values).sorted { $0.bookmarkedAt > $1.bookmarkedAt }
    }
}
```

## Converting to NewsArticle

For display purposes, convert entity back to article:

```swift
extension BookmarkArticleEntity {
    func toNewsArticle() -> NewsArticle {
        NewsArticle(
            id: id,
            title: title,
            description: articleDescription,
            content: content,
            author: author,
            source: NewsSource(id: nil, name: sourceName),
            url: url,
            imageUrl: imageUrl,
            publishedAt: publishedAt,
            category: category
        )
    }
}
```

## Error Handling

| Error | Description | Recovery |
|-------|-------------|----------|
| Save failed | Failed to persist | Retry operation |
| Delete failed | Failed to remove | Retry operation |
| Fetch failed | Failed to retrieve | Show error message |

## Related Documentation

- [Bookmarks Feature](../features/BOOKMARKS.md)
- [News Feed Feature](../features/NEWSFEED.md)
- [News Feed Service](./NEWSFEED_SERVICE.md)
