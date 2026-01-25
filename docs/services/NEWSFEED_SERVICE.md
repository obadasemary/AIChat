# News Feed Service

The News Feed Service manages news article fetching and caching via NewsAPI.

## Overview

The News Feed Service integrates with NewsAPI to provide news articles with support for categories, countries, and languages. It includes offline support through local caching.

## Architecture

```
NewsFeedManager (Orchestration)
    ↓
├── RemoteNewsFeedServiceProtocol
│   ├── RemoteNewsFeedService (Production)
│   └── MockRemoteNewsFeedService (Testing)
└── LocalNewsFeedServiceProtocol
    ├── FileManagerNewsFeedService (Production)
    └── MockLocalNewsFeedService (Testing)
```

## Files

| File | Path |
|------|------|
| `NewsFeedManager.swift` | `Services/NewsFeed/NewsFeedManager.swift` |
| `NewsFeedManagerProtocol.swift` | `Services/NewsFeed/NewsFeedManagerProtocol.swift` |

### Remote Services
| File | Path |
|------|------|
| `RemoteNewsFeedServiceProtocol.swift` | `Services/NewsFeed/Services/RemoteService/RemoteNewsFeedServiceProtocol.swift` |
| `RemoteNewsFeedService.swift` | `Services/NewsFeed/Services/RemoteService/RemoteNewsFeedService.swift` |
| `MockRemoteNewsFeedService.swift` | `Services/NewsFeed/Services/RemoteService/MockRemoteNewsFeedService.swift` |

### Local Services
| File | Path |
|------|------|
| `LocalNewsFeedServiceProtocol.swift` | `Services/NewsFeed/Services/LocalService/LocalNewsFeedServiceProtocol.swift` |
| `FileManagerNewsFeedService.swift` | `Services/NewsFeed/Services/LocalService/FileManagerNewsFeedService.swift` |
| `MockLocalNewsFeedService.swift` | `Services/NewsFeed/Services/LocalService/MockLocalNewsFeedService.swift` |

### Models
| File | Path |
|------|------|
| `NewsArticle.swift` | `Services/NewsFeed/Models/NewsArticle.swift` |
| `NewsSource.swift` | `Services/NewsFeed/Models/NewsSource.swift` |

## Protocol Definition

### NewsFeedManagerProtocol
```swift
protocol NewsFeedManagerProtocol {
    func getTopHeadlines(
        country: String?,
        category: String?,
        language: String?
    ) async throws -> [NewsArticle]

    func searchArticles(query: String) async throws -> [NewsArticle]

    func getArticle(id: String) async throws -> NewsArticle?
}
```

## Usage

### Resolving from Container
```swift
let newsFeedManager = container.resolve(NewsFeedManager.self)
```

### Get Top Headlines
```swift
let articles = try await newsFeedManager.getTopHeadlines(
    country: "us",
    category: "technology",
    language: "en"
)
```

### Search Articles
```swift
let results = try await newsFeedManager.searchArticles(query: "AI")
```

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

## NewsAPI Integration

### Configuration
API key configured via:
1. Environment variable: `NEWSAPI_API_KEY`
2. Config.plist: `NewsAPIKey`

### Endpoints Used
- **Top Headlines**: `/v2/top-headlines`
- **Everything**: `/v2/everything`

### Request Parameters
```swift
struct NewsAPIRequest {
    let country: String?   // ISO 3166-1 code (us, gb, de, etc.)
    let category: String?  // business, technology, sports, etc.
    let language: String?  // ISO 639-1 code (en, ar, de, etc.)
    let q: String?         // Search query
    let pageSize: Int      // Results per page (default: 20)
    let page: Int          // Page number
}
```

### Categories
- `general`
- `business`
- `technology`
- `sports`
- `entertainment`
- `health`
- `science`

### Supported Countries
- `us` - United States
- `gb` - United Kingdom
- `ae` - UAE
- `eg` - Egypt
- And many more...

## Build Configuration

### Development (.dev)
```swift
newsFeedManager = NewsFeedManager(
    remoteService: RemoteNewsFeedService(),
    localStorage: FileManagerNewsFeedService(),
    networkMonitor: networkMonitor,
    logManager: logManager
)
```

### Production (.prod)
```swift
newsFeedManager = NewsFeedManager(
    remoteService: RemoteNewsFeedService(),
    localStorage: FileManagerNewsFeedService(),
    networkMonitor: networkMonitor,
    logManager: logManager
)
```

### Mock (.mock)
```swift
newsFeedManager = NewsFeedManager(
    remoteService: MockRemoteNewsFeedService(),
    localStorage: MockLocalNewsFeedService(),
    networkMonitor: networkMonitor,
    logManager: logManager
)
```

## Caching Strategy

The service implements offline-first caching:

```swift
func getTopHeadlines(...) async throws -> [NewsArticle] {
    // 1. Check network status
    if networkMonitor.isConnected {
        // 2. Fetch from remote
        let articles = try await remoteService.getTopHeadlines(...)
        // 3. Cache locally
        try await localStorage.saveArticles(articles, for: cacheKey)
        return articles
    } else {
        // 4. Return cached data when offline
        return try await localStorage.getArticles(for: cacheKey)
    }
}
```

### Cache Keys
```swift
// Generate cache key from parameters
func cacheKey(country: String?, category: String?, language: String?) -> String {
    "headlines_\(country ?? "")_\(category ?? "")_\(language ?? "")"
}
```

## Network Monitoring

The service uses `NetworkMonitor` for connectivity awareness:

```swift
protocol NetworkMonitorProtocol {
    var isConnected: Bool { get }
}
```

## Error Handling

| Error | Description | Recovery |
|-------|-------------|----------|
| Rate limited | API quota exceeded | Show cached content |
| Invalid API key | Key missing/invalid | Check configuration |
| Network error | No connection | Use cached articles |
| No results | Empty response | Show empty state |

## Rate Limits

| Plan | Requests/Day |
|------|--------------|
| Free | 100 |
| Developer | 500 |
| Business | Unlimited |

## Related Documentation

- [News Feed Feature](../features/NEWSFEED.md)
- [Bookmarks Feature](../features/BOOKMARKS.md)
- [Bookmark Service](./BOOKMARK_SERVICE.md)
