# Changelog

All notable changes to AIChat will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive documentation for all features and services
- Documentation index with quick navigation
- Code style guide
- Troubleshooting guide
- Data models documentation

---

## [1.5.0] - 2025-01-25

### Added
- Swift Concurrency skill for Claude Code integration
- Enhanced async/await patterns documentation

### Changed
- Updated file author attribution across codebase

---

## [1.4.0] - 2025-01-20

### Added
- News Feed feature with NewsAPI integration
- Bookmarks feature with SwiftData persistence
- Multi-language and country support for news
- Article details view with sharing

### Changed
- Updated README with News Feed and Bookmarks features

---

## [1.3.0] - 2025-01-15

### Added
- Security improvements for API key handling
- Production build configuration without console logging
- Environment variable support via Swift Configuration

### Security
- Prevented API key logging in production builds
- Added dual-layer protection for scheme files

---

## [1.2.0] - 2025-01-10

### Added
- A/B testing framework with Firebase Remote Config
- Developer settings screen for test overrides
- LocalABTestService for development testing
- Launch argument support for UI test variants

### Changed
- Onboarding flow now supports A/B test variants

---

## [1.1.0] - 2025-01-05

### Added
- Push notification support
- Real-time chat message streaming
- Message seen indicators
- Chat reporting functionality

### Fixed
- Memory leak in chat message listener
- Avatar image caching issues

---

## [1.0.0] - 2024-12-20

### Added
- Initial release
- AI-powered chat with OpenAI integration
- User authentication (Anonymous, Apple, Google)
- Avatar creation with AI image generation
- User profile management
- Settings and preferences
- Explore/Discovery features
- Subscription management with StoreKit 2
- Multi-service logging (Console, Mixpanel, Firebase, Crashlytics)
- Clean Architecture with MVVM pattern
- Dependency injection system
- Three build configurations (Dev, Prod, Mock)
- Unit and UI test infrastructure
- CI/CD with GitHub Actions

---

## Version History Format

### Types of Changes

- **Added** - New features
- **Changed** - Changes in existing functionality
- **Deprecated** - Soon-to-be removed features
- **Removed** - Now removed features
- **Fixed** - Bug fixes
- **Security** - Vulnerability fixes

### Versioning

- **Major (X.0.0)** - Breaking changes
- **Minor (0.X.0)** - New features, backward compatible
- **Patch (0.0.X)** - Bug fixes, backward compatible

---

## Upcoming Features

Features planned for future releases:

- [ ] Voice message support
- [ ] Group chat functionality
- [ ] Avatar marketplace
- [ ] Advanced AI personality customization
- [ ] Offline mode improvements
- [ ] Widget support
- [ ] Apple Watch companion app
- [ ] iPad optimization

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to contribute to this project.

When contributing, please:
1. Update the [Unreleased] section with your changes
2. Follow the format guidelines above
3. Link to relevant issues/PRs

---

## Links

- [Repository](https://github.com/obadasemary/AIChat)
- [Issues](https://github.com/obadasemary/AIChat/issues)
- [Releases](https://github.com/obadasemary/AIChat/releases)
