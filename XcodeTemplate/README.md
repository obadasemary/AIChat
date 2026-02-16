# Xcode VIPER Template Installation

This directory contains the Xcode template for creating VIPER features in AIChat.

## Template Location

The template files are installed in:
```
~/Library/Developer/Xcode/Templates/CustomTemplates/VIPERTemplate.xctemplate/
```

## Installation

### Automatic Installation (Recommended)

Run the installation script:
```bash
./install-template.sh
```

### Manual Installation

1. Create the templates directory if it doesn't exist:
   ```bash
   mkdir -p ~/Library/Developer/Xcode/Templates/CustomTemplates
   ```

2. Copy the template folder:
   ```bash
   cp -r XcodeTemplate/VIPERTemplate.xctemplate ~/Library/Developer/Xcode/Templates/CustomTemplates/
   ```

3. Restart Xcode if it's running:
   ```bash
   killall Xcode
   open /Applications/Xcode.app
   ```

## Verification

After installation, verify the template is available:

1. Open Xcode
2. Right-click any folder in Project Navigator
3. Select **New File...**
4. Scroll to **Custom Templates** section
5. You should see **VIPERTemplate**

## Usage

1. Right-click on `AIChat/Core/` folder in Xcode
2. Select **New File...**
3. Choose **Custom Templates** -> **VIPERTemplate**
4. Enter:
   - Feature Name (PascalCase): Your feature name (e.g., `Notifications`)
   - Feature Name (camelCase): Your feature name (e.g., `notifications`)
5. Click **Create**

## Documentation

- [TEMPLATE_SETUP.md](../TEMPLATE_SETUP.md) - Complete setup guide
- [QUICK_REFERENCE.md](../QUICK_REFERENCE.md) - Daily quick reference

## Updating the Template

If you update the template files:

1. Update files in:
   ```
   XcodeTemplate/VIPERTemplate.xctemplate/
   ```

2. Reinstall the template:
   ```bash
   ./install-template.sh
   ```

3. Restart Xcode

## Template Structure

The template generates 5 files for each feature:

```
YourFeature/
├── YourFeatureView.swift          # SwiftUI UI
├── YourFeaturePresenter.swift     # Presentation logic & state
├── YourFeatureInteractor.swift    # Business logic
├── YourFeatureBuilder.swift       # Dependency injection
└── YourFeatureRouter.swift        # Navigation
```

## Tips

- Keep the `About` feature as your reference implementation
- Run `./verify-architecture.sh` to check all features follow the pattern
- Use `swiftlint lint` to ensure code quality

## Troubleshooting

### Template not showing in Xcode

1. Verify installation:
   ```bash
   ls -la ~/Library/Developer/Xcode/Templates/CustomTemplates/VIPERTemplate.xctemplate/
   ```

2. Restart Xcode:
   ```bash
   killall Xcode
   open /Applications/Xcode.app
   ```

### Template generates incorrect files

1. Check template files are properly formatted
2. Verify placeholders: `___VARIABLE_productName:identifier___`
3. Reinstall the template: `./install-template.sh`

## Need Help?

Check the comprehensive documentation:
- [QUICK_REFERENCE.md](../QUICK_REFERENCE.md) - Quick answers
- [TEMPLATE_SETUP.md](../TEMPLATE_SETUP.md) - Full guide
