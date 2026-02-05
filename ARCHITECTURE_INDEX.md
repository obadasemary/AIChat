# AIChat Architecture Documentation Index

This directory contains comprehensive documentation for the AIChat project's architecture and development workflow.

## 📚 Documentation Overview

### 🎯 Start Here
- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Daily reference card for common tasks (5-minute read)
  - Quick feature creation steps
  - Common code patterns
  - Checklist before committing
  - Common mistakes to avoid

### 📖 Complete Guides
- **[TEMPLATE_SETUP.md](TEMPLATE_SETUP.md)** - Full template setup and usage guide (15-minute read)
  - How to use the MVVM template in Xcode
  - Step-by-step feature creation
  - Project compliance status
  - Template maintenance

- **[ARCHITECTURE_DIAGRAM.md](ARCHITECTURE_DIAGRAM.md)** - Visual architecture guide (10-minute read)
  - Feature structure diagrams
  - Data flow visualization
  - Dependency injection flow
  - Module organization

- **[CLAUDE.md](CLAUDE.md)** - Project development guidelines (30-minute read)
  - Build commands
  - Full architecture overview
  - Configuration management
  - Critical development guidelines
  - Common pitfalls

### 🛠️ Tools & Scripts
- **[verify-architecture.sh](verify-architecture.sh)** - Automated architecture verification
  - Checks all features follow MVVM pattern
  - Identifies missing files
  - Ensures project consistency

## 🗂️ Documentation by Purpose

### When You Need To...

#### Create a New Feature
1. Read: [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - "Create New Feature" section
2. Use: Xcode MVVMTemplate (Right-click → New File → Custom Templates)
3. Reference: `AIChat/Core/About/` folder

#### Understand the Architecture
1. Read: [ARCHITECTURE_DIAGRAM.md](ARCHITECTURE_DIAGRAM.md)
2. Read: [CLAUDE.md](CLAUDE.md) - "Architecture Overview" section
3. Study: `AIChat/Core/About/` feature (reference implementation)

#### Verify Your Work
1. Run: `./verify-architecture.sh`
2. Run: `swiftlint lint`
3. Check: [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - "Checklist" section

#### Update the Template
1. Edit: `~/Library/Developer/Xcode/Templates/CustomTemplates/MVVMTemplate.xctemplate/`
2. Update: [TEMPLATE_SETUP.md](TEMPLATE_SETUP.md) - "Template Maintenance" section
3. Update: Reference feature (`AIChat/Core/About/`)

#### Onboard New Developers
1. Read: [CLAUDE.md](CLAUDE.md) - Complete overview
2. Read: [ARCHITECTURE_DIAGRAM.md](ARCHITECTURE_DIAGRAM.md) - Visual guide
3. Practice: Create test feature with MVVMTemplate
4. Keep handy: [QUICK_REFERENCE.md](QUICK_REFERENCE.md)

## 📁 File Structure Reference

```
AIChat/
│
├── ARCHITECTURE_INDEX.md          ← You are here!
├── QUICK_REFERENCE.md            ← Daily quick reference
├── TEMPLATE_SETUP.md             ← Complete setup guide
├── ARCHITECTURE_DIAGRAM.md       ← Visual diagrams
├── CLAUDE.md                     ← Project guidelines
├── verify-architecture.sh        ← Verification script
│
├── AIChat/
│   ├── App/
│   │   ├── AIChatApp.swift      ← Entry point
│   │   ├── DependencyContainer.swift
│   │   └── Dependencies.swift    ← Dependency config
│   │
│   ├── Core/                     ← All features here
│   │   ├── About/               ← Reference feature ⭐
│   │   ├── Profile/
│   │   ├── Chat/
│   │   └── ... (15+ features)
│   │
│   ├── Services/                ← External services
│   ├── Components/              ← Reusable UI
│   └── Utilities/               ← Helper functions
│
└── ~/Library/Developer/Xcode/Templates/CustomTemplates/
    └── MVVMTemplate.xctemplate/  ← Xcode template
```

## 🎯 Quick Navigation

### By Experience Level

#### 🆕 New to the Project
1. Start: [CLAUDE.md](CLAUDE.md) - "Architecture Overview"
2. Then: [ARCHITECTURE_DIAGRAM.md](ARCHITECTURE_DIAGRAM.md)
3. Practice: Create feature with MVVMTemplate
4. Study: `AIChat/Core/About/` implementation

#### 🔨 Daily Development
1. Keep open: [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
2. Use: MVVMTemplate for new features
3. Run: `./verify-architecture.sh` before commits
4. Reference: `AIChat/Core/About/` when stuck

#### 🏗️ Architecture Decisions
1. Review: [ARCHITECTURE_DIAGRAM.md](ARCHITECTURE_DIAGRAM.md)
2. Check: [CLAUDE.md](CLAUDE.md) - "Critical Guidelines"
3. Verify: All features with `./verify-architecture.sh`
4. Update: Templates and documentation

## 🔍 Search Index

### Topics

**MVVM Pattern**
- [ARCHITECTURE_DIAGRAM.md](ARCHITECTURE_DIAGRAM.md) - "Feature Structure Overview"
- [CLAUDE.md](CLAUDE.md) - "Clean Architecture with MVVM Pattern"
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - "Architecture Cheat Sheet"

**Dependency Injection**
- [ARCHITECTURE_DIAGRAM.md](ARCHITECTURE_DIAGRAM.md) - "Dependency Injection Flow"
- [CLAUDE.md](CLAUDE.md) - "Dependency Injection System"
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - "Add Business Logic"

**Creating Features**
- [TEMPLATE_SETUP.md](TEMPLATE_SETUP.md) - "How to Use the Template"
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - "Create New Feature"
- Template: `~/Library/Developer/Xcode/Templates/CustomTemplates/MVVMTemplate.xctemplate/`

**Testing**
- [ARCHITECTURE_DIAGRAM.md](ARCHITECTURE_DIAGRAM.md) - "Test Architecture"
- [CLAUDE.md](CLAUDE.md) - "Testing Strategy"
- Script: `./verify-architecture.sh`

**Build Configuration**
- [ARCHITECTURE_DIAGRAM.md](ARCHITECTURE_DIAGRAM.md) - "Build Configuration Flow"
- [CLAUDE.md](CLAUDE.md) - "Build Configurations"

**SwiftLint Rules**
- [CLAUDE.md](CLAUDE.md) - "SwiftLint Rules"
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - "Common Mistakes"

## 📊 Project Stats

- **Features**: 15+ following MVVM pattern
- **Core Files per Feature**: 5 (View, ViewModel, UseCase, Builder, Router)
- **Build Configurations**: 3 (Mock, Dev, Production)
- **Services**: 8+ (AI, Auth, User, Chat, Analytics, etc.)
- **Test Coverage**: Unit + UI tests
- **Architecture Compliance**: 100%

## 🎓 Learning Path

### Week 1: Understanding
1. Read [CLAUDE.md](CLAUDE.md) - Architecture section
2. Study [ARCHITECTURE_DIAGRAM.md](ARCHITECTURE_DIAGRAM.md)
3. Explore `AIChat/Core/About/` feature
4. Read existing features' code

### Week 2: Practice
1. Create test feature with MVVMTemplate
2. Implement simple business logic
3. Add navigation between features
4. Write unit tests

### Week 3: Mastery
1. Create complex feature with multiple managers
2. Add analytics tracking
3. Handle error states properly
4. Optimize performance

## 🚨 Important Reminders

### Before Every Commit
✅ Run: `./verify-architecture.sh`
✅ Run: `swiftlint lint`
✅ Check: No force unwrap (`!`)
✅ Check: No force try (`try!`)
✅ Verify: Dependencies from container

### When Stuck
1. Check: [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
2. Study: `AIChat/Core/About/` reference
3. Review: [ARCHITECTURE_DIAGRAM.md](ARCHITECTURE_DIAGRAM.md)
4. Read: [CLAUDE.md](CLAUDE.md) guidelines

## 🔗 External Resources

- **SwiftUI**: Official Apple documentation
- **Clean Architecture**: Robert C. Martin (Uncle Bob)
- **MVVM Pattern**: Microsoft documentation
- **Dependency Injection**: Martin Fowler's patterns

## 📞 Getting Help

1. **Architecture Questions**: Read [ARCHITECTURE_DIAGRAM.md](ARCHITECTURE_DIAGRAM.md)
2. **Template Issues**: Read [TEMPLATE_SETUP.md](TEMPLATE_SETUP.md)
3. **Daily Tasks**: Check [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
4. **Project Guidelines**: Read [CLAUDE.md](CLAUDE.md)

## 🎉 Summary

This documentation system provides everything you need to:
- ✅ Understand the project architecture
- ✅ Create new features consistently
- ✅ Maintain code quality
- ✅ Onboard new developers
- ✅ Verify architectural compliance

**Start with**: [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for immediate productivity!

---

Last Updated: February 2026
