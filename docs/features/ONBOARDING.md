# Onboarding Feature

The Onboarding feature guides new users through the initial app setup.

## Overview

The Onboarding module presents a multi-step flow that introduces the app, collects user preferences, and prepares users for the main experience.

## Architecture

```
Onboarding Flow
    ↓
┌─────────────────────────────────────────┐
│  OnboardingIntroView                    │
│      ↓                                  │
│  OnboardingCommunityView (A/B tested)   │
│      ↓                                  │
│  OnboardingColorView                    │
│      ↓                                  │
│  OnboardingCompletedView                │
└─────────────────────────────────────────┘
    ↓
Main App (TabBarView)
```

## Files

### Intro View
| File | Purpose |
|------|---------|
| `OnboardingIntroView.swift` | Welcome introduction screen |
| `OnboardingIntroViewModel.swift` | Intro view state |
| `OnboardingIntroUseCase.swift` | Intro business logic |
| `OnboardingIntroBuilder.swift` | Dependency injection |

### Community View (A/B Tested)
| File | Purpose |
|------|---------|
| `OnboardingCommunityView.swift` | Community features showcase |
| `OnboardingCommunityViewModel.swift` | Community view state |
| `OnboardingCommunityUseCase.swift` | Community business logic |
| `OnboardingCommunityBuilder.swift` | Dependency injection |

### Color View
| File | Purpose |
|------|---------|
| `OnboardingColorView.swift` | Profile color selection |
| `OnboardingColorViewModel.swift` | Color view state |
| `OnboardingColorUseCase.swift` | Color business logic |
| `OnboardingColorBuilder.swift` | Dependency injection |

### Completed View
| File | Purpose |
|------|---------|
| `OnboardingCompletedView.swift` | Completion celebration |
| `OnboardingCompletedViewModel.swift` | Completed view state |
| `OnboardingCompletedUseCase.swift` | Completed business logic |
| `OnboardingCompletedBuilder.swift` | Dependency injection |

## Key Features

### Progressive Onboarding
- Step-by-step introduction
- Skip option available
- Progress indicators
- Back navigation support

### A/B Testing Integration
- Community screen A/B tested
- Different variants for testing
- Analytics tracking per variant

### Profile Customization
- Color selection
- Initial preferences
- Account setup

## Usage

### Starting Onboarding

```swift
// Check if user needs onboarding
if !userManager.currentUser?.didCompleteOnboarding ?? true {
    // Show onboarding flow
    OnboardingIntroView()
}
```

### Building Onboarding Views

```swift
@Environment(OnboardingIntroBuilder.self) var introBuilder
@Environment(OnboardingCommunityBuilder.self) var communityBuilder
@Environment(OnboardingColorBuilder.self) var colorBuilder
@Environment(OnboardingCompletedBuilder.self) var completedBuilder

// Build respective views
introBuilder.buildOnboardingIntroView()
communityBuilder.buildOnboardingCommunityView()
colorBuilder.buildOnboardingColorView()
completedBuilder.buildOnboardingCompletedView()
```

## Onboarding Flow

### Step 1: Intro
- App logo and branding
- Brief value proposition
- Continue button

### Step 2: Community (A/B Tested)
- Showcase community features
- Social proof elements
- Variant A: Standard layout
- Variant B: Enhanced testimonials

### Step 3: Color Selection
- Profile color picker
- Visual preview
- Color options grid

### Step 4: Completion
- Success animation
- Welcome message
- Begin button

## A/B Testing

The community screen uses A/B testing:

```swift
// Check A/B test variant
let variant = abTestManager.getVariant(for: .onboardingCommunity)

switch variant {
case .control:
    // Show standard community screen
case .variant:
    // Show enhanced community screen
}
```

### Launch Argument for Testing
```bash
# Trigger A/B test variant in Mock scheme
-ONBOARDING_COMMUNITY_TEST
```

## Profile Color Options

Available colors for selection:
```swift
let profileColors: [Color] = [
    Color(hex: "#7DCEA0"), // Green
    Color(hex: "#33ADFF"), // Blue
    Color(hex: "#5C6BC0"), // Indigo
    Color(hex: "#FF33A1"), // Pink
    Color(hex: "#FFB347"), // Orange
    Color(hex: "#9B59B6"), // Purple
]
```

## Completion Handling

```swift
// Mark onboarding as completed
func completeOnboarding() async throws {
    var user = userManager.currentUser
    user.didCompleteOnboarding = true
    try await userManager.updateUser(user)

    // Navigate to main app
    appState.showTabBar = true
}
```

## Dependencies

- **UserManager**: User preferences storage
- **ABTestManager**: A/B test variants
- **AppState**: Navigation state
- **LogManager**: Analytics tracking

## Analytics Events

| Event | Description |
|-------|-------------|
| `onboarding_start` | User begins onboarding |
| `onboarding_intro_complete` | Completed intro step |
| `onboarding_community_view` | Viewed community (with variant) |
| `onboarding_color_selected` | Selected profile color |
| `onboarding_complete` | Finished onboarding |
| `onboarding_skip` | Skipped onboarding |

## Related Documentation

- [AB Test Service](../services/ABTEST_SERVICE.md)
- [User Service](../services/USER_SERVICE.md)
- [Welcome Feature](./WELCOME.md)
