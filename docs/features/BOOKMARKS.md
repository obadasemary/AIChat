# Bookmarks Feature

The Bookmarks feature allows users to save and manage their favorite news articles.

## Overview

The Bookmarks module provides persistent storage for saved articles using SwiftData. Users can bookmark articles from the News Feed or News Details screens and access them anytime.

## Architecture

```
BookmarksView
    ↓
BookmarksViewModel
    ↓
BookmarksUseCase
    ↓
├── BookmarkManager (persistence)
└── LogManager (analytics)
```

## Files

| File | Purpose |
|------|---------|
| `BookmarksView.swift` | SwiftUI view for bookmarks list |
| `BookmarksViewModel.swift` | View state and bookmark management |
| `BookmarksUseCase.swift` | Business logic for bookmark operations |
| `BookmarksBuilder.swift` | Dependency injection |
| `BookmarksRouter.swift` | Navigation to article details |

## Key Features

### Bookmark Management
- Add articles to bookmarks
- Remove bookmarks
- View all saved articles
- Sort by date saved

### Persistence
- SwiftData for local storage
- Survives app restarts
- No account required

### UI Features
- Grid or list view
- Article preview cards
- Swipe to delete
- Empty state handling

## Usage

### Building the Bookmarks View

```swift
@Environment(BookmarksBuilder.self) var bookmarksBuilder

// Display bookmarks
bookmarksBuilder.buildBookmarksView()
```

### Bookmark Operations

```swift
// Add bookmark
bookmarkManager.addBookmark(article: newsArticle)

// Remove bookmark
bookmarkManager.removeBookmark(articleId: article.id)

// Check if bookmarked
let isBookmarked = bookmarkManager.isBookmarked(articleId: article.id)

// Get all bookmarks
let bookmarks = bookmarkManager.getAllBookmarks()
```

## Data Model

### BookmarkArticleEntity
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
}
```

## Data Flow

1. User taps bookmark icon on article
2. BookmarkManager creates BookmarkArticleEntity
3. SwiftData persists to local storage
4. UI updates to show bookmarked state
5. Bookmarks view refreshes automatically

## SwiftData Integration

The Bookmarks feature uses SwiftData for persistence:

```swift
// Model Container setup in App
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

## Dependencies

- **BookmarkManager**: Bookmark CRUD operations
- **LogManager**: Analytics tracking

## Error Handling

| Error | Handling |
|-------|----------|
| Save failed | Show error toast, allow retry |
| Delete failed | Show error message |
| Load failed | Display empty state with retry |

## Related Documentation

- [News Feed Feature](./NEWSFEED.md)
- [Bookmark Service](../services/BOOKMARK_SERVICE.md)
- [Data Models](../DATA_MODELS.md)
