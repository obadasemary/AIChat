# Xcode Templates Installation

This directory contains Xcode templates for creating features in AIChat.

## Available Templates

### VIPERTemplate (Recommended)
Generates: **View, Presenter, Interactor, Builder, Router**
- Used by the current VIPER architecture branch
- Presenter handles presentation logic & UI state
- Interactor handles business logic

### MVVMTemplate
Generates: **View, ViewModel, UseCase, Builder, Router**
- Original MVVM architecture template
- ViewModel handles presentation logic & UI state
- UseCase handles business logic

## Template Location

After installation, templates are available in:
```
~/Library/Developer/Xcode/Templates/CustomTemplates/VIPERTemplate.xctemplate/
~/Library/Developer/Xcode/Templates/CustomTemplates/MVVMTemplate.xctemplate/
```

## Installation

### Automatic Installation (Recommended)

Run the installation script to install both templates:
```bash
./install-template.sh
```

### Manual Installation

1. Create the templates directory if it doesn't exist:
   ```bash
   mkdir -p ~/Library/Developer/Xcode/Templates/CustomTemplates
   ```

2. Copy the template folders:
   ```bash
   cp -r XcodeTemplate/VIPERTemplate.xctemplate ~/Library/Developer/Xcode/Templates/CustomTemplates/
   cp -r XcodeTemplate/MVVMTemplate.xctemplate ~/Library/Developer/Xcode/Templates/CustomTemplates/
   ```

3. Restart Xcode if it's running:
   ```bash
   killall Xcode
   open /Applications/Xcode.app
   ```

## Verification

After installation, verify the templates are available:

1. Open Xcode
2. Right-click any folder in Project Navigator
3. Select **New File...**
4. Scroll to **Custom Templates** section
5. You should see both **VIPERTemplate** and **MVVMTemplate**

## Usage

1. Right-click on `AIChat/Core/` folder in Xcode
2. Select **New File...**
3. Choose **Custom Templates** -> **VIPERTemplate** or **MVVMTemplate**
4. Enter:
   - Feature Name (PascalCase): Your feature name (e.g., `Notifications`)
   - Feature Name (camelCase): Your feature name (e.g., `notifications`)
5. Click **Create**

## Template Structures

### VIPER Template (5 files)
```
YourFeature/
├── YourFeatureView.swift          # SwiftUI UI
├── YourFeaturePresenter.swift     # Presentation logic & state
├── YourFeatureInteractor.swift    # Business logic
├── YourFeatureBuilder.swift       # Dependency injection
└── YourFeatureRouter.swift        # Navigation
```

### MVVM Template (5 files)
```
YourFeature/
├── YourFeatureView.swift          # SwiftUI UI
├── YourFeatureViewModel.swift     # Presentation logic & state
├── YourFeatureUseCase.swift       # Business logic
├── YourFeatureBuilder.swift       # Dependency injection
└── YourFeatureRouter.swift        # Navigation
```

## Documentation

- [TEMPLATE_SETUP.md](../TEMPLATE_SETUP.md) - Complete setup guide
- [QUICK_REFERENCE.md](../QUICK_REFERENCE.md) - Daily quick reference

## Tips

- Keep the `About` feature as your reference implementation
- Run `./verify-architecture.sh` to check all features follow the pattern
- Use `swiftlint lint` to ensure code quality

## Troubleshooting

### Template not showing in Xcode

1. Verify installation:
   ```bash
   ls -la ~/Library/Developer/Xcode/Templates/CustomTemplates/
   ```

2. Restart Xcode:
   ```bash
   killall Xcode
   open /Applications/Xcode.app
   ```

### Template generates incorrect files

1. Check template files are properly formatted
2. Verify placeholders: `___VARIABLE_productName:identifier___`
3. Reinstall the templates: `./install-template.sh`

## Need Help?

Check the comprehensive documentation:
- [QUICK_REFERENCE.md](../QUICK_REFERENCE.md) - Quick answers
- [TEMPLATE_SETUP.md](../TEMPLATE_SETUP.md) - Full guide
