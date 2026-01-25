# AIChat Documentation Index

Welcome to the AIChat documentation. This index provides quick access to all documentation resources.

## Quick Links

| Document | Description |
|----------|-------------|
| [README](../README.md) | Project overview and quick start |
| [Setup Guide](../SETUP_GUIDE.md) | Detailed setup instructions |
| [Contributing](../CONTRIBUTING.md) | Contribution guidelines |
| [CLAUDE.md](../CLAUDE.md) | Claude Code integration guide |

---

## Documentation Sections

### Architecture & Design

- [System Design](./system_design.md) - High-level system architecture
- [Architecture Diagrams](./architecture-diagrams.md) - Visual architecture representations
- [Data Models](./DATA_MODELS.md) - Data structures and relationships

### Feature Documentation

Detailed documentation for each feature module:

| Feature | Description | Documentation |
|---------|-------------|---------------|
| Chat | AI-powered conversations | [Chat Feature](./features/CHAT.md) |
| Chats | Chat list management | [Chats Feature](./features/CHATS.md) |
| News Feed | Browse news articles | [News Feed Feature](./features/NEWSFEED.md) |
| Bookmarks | Save favorite articles | [Bookmarks Feature](./features/BOOKMARKS.md) |
| Profile | User profile management | [Profile Feature](./features/PROFILE.md) |
| Settings | App configuration | [Settings Feature](./features/SETTINGS.md) |
| Explore | Discovery and exploration | [Explore Feature](./features/EXPLORE.md) |
| Create Avatar | Avatar creation | [Create Avatar Feature](./features/CREATE_AVATAR.md) |
| Paywall | Subscription management | [Paywall Feature](./features/PAYWALL.md) |
| Onboarding | User onboarding flow | [Onboarding Feature](./features/ONBOARDING.md) |

### Services Documentation

Detailed documentation for each service:

| Service | Description | Documentation |
|---------|-------------|---------------|
| AI Manager | OpenAI integration | [AI Service](./services/AI_SERVICE.md) |
| Auth Manager | Firebase authentication | [Auth Service](./services/AUTH_SERVICE.md) |
| User Manager | User data management | [User Service](./services/USER_SERVICE.md) |
| Chat Manager | Chat persistence | [Chat Service](./services/CHAT_SERVICE.md) |
| Avatar Manager | Avatar management | [Avatar Service](./services/AVATAR_SERVICE.md) |
| News Feed Manager | NewsAPI integration | [News Feed Service](./services/NEWSFEED_SERVICE.md) |
| Bookmark Manager | Bookmark persistence | [Bookmark Service](./services/BOOKMARK_SERVICE.md) |
| Purchase Manager | In-app purchases | [Purchase Service](./services/PURCHASE_SERVICE.md) |
| Log Manager | Multi-service logging | [Log Service](./services/LOG_SERVICE.md) |
| AB Test Manager | A/B testing | [AB Test Service](./services/ABTEST_SERVICE.md) |
| Push Manager | Push notifications | [Push Service](./services/PUSH_SERVICE.md) |

### Development Guides

- [Code Style Guide](./CODE_STYLE_GUIDE.md) - Swift coding standards and best practices
- [Troubleshooting Guide](./TROUBLESHOOTING.md) - Common issues and solutions
- [Environment Variables](../ENVIRONMENT_VARIABLES.md) - Configuration management
- [GitHub Secrets Setup](../GITHUB_SECRETS_SETUP.md) - CI/CD secrets configuration

### Testing

- [UI Test Improvements](./UI_TEST_IMPROVEMENTS.md) - UI testing documentation
- [Testing Strategy](./TESTING.md) - Comprehensive testing guide

### Version History

- [Changelog](../CHANGELOG.md) - Version history and release notes

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        Presentation Layer                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │    View     │  │  ViewModel  │  │   Router    │             │
│  │  (SwiftUI)  │  │ (Observable)│  │ (Navigation)│             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
├─────────────────────────────────────────────────────────────────┤
│                        Business Logic Layer                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │   UseCase   │  │   Builder   │  │  Interactor │             │
│  │  (Logic)    │  │    (DI)     │  │  (Protocol) │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
├─────────────────────────────────────────────────────────────────┤
│                         Service Layer                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │   Manager   │  │   Service   │  │    Model    │             │
│  │ (Orchestration)│  │(Implementation)│  │   (Data)    │         │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
├─────────────────────────────────────────────────────────────────┤
│                        External Services                         │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐  │
│  │ Firebase│ │ OpenAI  │ │ NewsAPI │ │Mixpanel │ │ StoreKit│  │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow

```
User Action → View → ViewModel → UseCase → Manager → Service → External API
              ↓         ↓          ↓         ↓         ↓
          UI Update ← State ← Business ← Data ← Response
```

---

## Getting Help

- **Issues**: [GitHub Issues](https://github.com/obadasemary/AIChat/issues)
- **Discussions**: [GitHub Discussions](https://github.com/obadasemary/AIChat/discussions)
- **Email**: [obada.semary@gmail.com](mailto:obada.semary@gmail.com)
