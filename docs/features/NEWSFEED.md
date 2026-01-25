# News Feed Feature

The News Feed feature provides curated news articles with category, country, and language filtering.

## Overview

The News Feed module integrates with NewsAPI to display current news articles. Users can browse by category, filter by country and language, and save articles to bookmarks.

## Architecture

```
NewsFeedView
    ↓
NewsFeedViewModel
    ↓
NewsFeedUseCase
    ↓
├── NewsFeedManager (articles)
├── BookmarkManager (favorites)
└── LogManager (analytics)
```

## Files

| File | Purpose |
|------|---------|
| `NewsFeedView.swift` | SwiftUI view for news feed |
| `NewsFeedViewModel.swift` | View state and article management |
| `NewsFeedUseCase.swift` | Business logic for fetching news |
| `NewsFeedBuilder.swift` | Dependency injection |
| `NewsFeedRouter.swift` | Navigation to article details |

## Key Features

### Article Browsing
- Top headlines display
- Category-based filtering
- Country selection
- Language preferences
- Pull-to-refresh

### Categories Supported
- Top Headlines
- Business
- Technology
- Sports
- Entertainment
- Health
- Science

### Offline Support
- Local caching via FileManager
- Network status awareness
- Graceful offline handling

### Bookmark Integration
- Quick bookmark from feed
- Visual bookmark indicators
- Sync with Bookmarks feature

## Usage

### Building the News Feed View

```swift
@Environment(NewsFeedBuilder.self) var newsFeedBuilder

// Display news feed
newsFeedBuilder.buildNewsFeedView()
```

### Filtering Articles

```swift
// In ViewModel
func filterByCategory(_ category: String) {
    // Fetches articles for selected category
}

func filterByCountry(_ country: String) {
    // Fetches articles for selected country
}
```

## Data Flow

1. View appears, triggers article fetch
2. NewsFeedManager checks network status
3. If online: fetch from NewsAPI, cache locally
4. If offline: load from local cache
5. Display articles in scrollable list
6. User interactions tracked via LogManager

## Data Models

### NewsArticle
```swift
struct NewsArticle: Identifiable, Codable {
    let id: String
    let title: String
    let description: String?
    let content: String?
    let author: String?
    let source: NewsSource
    let url: String
    let imageUrl: String?
    let publishedAt: Date
    let category: String?
}
```

### NewsSource
```swift
struct NewsSource: Codable {
    let id: String?
    let name: String
}
```

## Dependencies

- **NewsFeedManager**: Article fetching and caching
- **BookmarkManager**: Bookmark operations
- **NetworkMonitor**: Connectivity status
- **LogManager**: Analytics tracking

## Configuration

### API Key Setup

NewsAPI requires an API key. Configure via:

1. **Environment Variable**: `NEWSAPI_API_KEY`
2. **Config.plist**: `NewsAPIKey` key
3. **Xcode Scheme**: Environment Variables section

### Rate Limits

- Free tier: 100 requests/day
- Development tier: 500 requests/day
- Business tier: Unlimited

## Error Handling

| Error | Handling |
|-------|----------|
| No network | Show cached content with offline indicator |
| API error | Display error message, allow retry |
| Rate limit | Show rate limit message |
| No articles | Display empty state |

## Related Documentation

- [News Details Feature](./NEWS_DETAILS.md)
- [Bookmarks Feature](./BOOKMARKS.md)
- [News Feed Service](../services/NEWSFEED_SERVICE.md)
