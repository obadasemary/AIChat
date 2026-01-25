# Explore Feature

The Explore feature enables users to discover AI avatars and content categories.

## Overview

The Explore module serves as the discovery hub of the app, showcasing featured avatars, categories, and providing search functionality.

## Architecture

```
ExploreView
    ↓
ExploreViewModel
    ↓
ExploreUseCase / ExploreInteractor
    ↓
├── AvatarManager (avatar discovery)
├── CategoryManager (categories)
└── LogManager (analytics)
```

## Files

| File | Purpose |
|------|---------|
| `ExploreView.swift` | SwiftUI view for exploration |
| `ExploreViewModel.swift` | View state management |
| `ExploreUseCase.swift` | Business logic |
| `ExploreBuilder.swift` | Dependency injection |
| `ExploreRouter.swift` | Navigation handling |
| `ExploreInteractor.swift` | Interactor protocol |

## Key Features

### Avatar Discovery
- Featured avatars carousel
- Popular avatars section
- Recently created avatars
- Search functionality

### Category Browsing
- Avatar categories
- Category-filtered browsing
- Visual category cards

### Content Sections
- Hero carousel with featured content
- Horizontal scrollable rows
- Grid layouts for categories

## Usage

### Building the Explore View

```swift
@Environment(ExploreBuilder.self) var exploreBuilder

// Display explore screen
exploreBuilder.buildExploreView()
```

### Navigation to Avatar

```swift
// Navigate to chat with selected avatar
router.navigateToChat(avatarId: avatar.id)
```

## UI Components

### Hero Carousel
Displays featured avatars in a full-width carousel:
```swift
CarouselView(items: featuredAvatars) { avatar in
    HeroCellView(avatar: avatar)
}
```

### Category Grid
Shows avatar categories in a grid layout:
```swift
LazyVGrid(columns: columns) {
    ForEach(categories) { category in
        CategoryCellView(category: category)
    }
}
```

## Data Flow

1. View appears, triggers content fetch
2. AvatarManager provides featured/popular avatars
3. Categories loaded from configuration
4. Display organized content sections
5. User taps avatar to navigate to chat
6. Analytics track discovery interactions

## Avatar Categories

Avatars are organized by character types:
- Humans (Man, Woman)
- Animals (Dog, Cat)
- Fantasy (Alien, Robot)
- And more...

Each category shows relevant avatars and allows filtering.

## Dependencies

- **AvatarManager**: Avatar discovery and search
- **LogManager**: Analytics tracking

## Related Documentation

- [Create Avatar Feature](./CREATE_AVATAR.md)
- [Chat Feature](./CHAT.md)
- [Avatar Service](../services/AVATAR_SERVICE.md)
