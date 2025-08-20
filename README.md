# AIChat 


[![iOS Build & Test](https://github.com/obadasemary/AIChat/actions/workflows/CI.yml/badge.svg)](https://github.com/obadasemary/AIChat/actions/workflows/CI.yml)

## Configuration

This project requires API keys to function properly. To set up your configuration:

### Option 1: Configuration File (Recommended for Development)
1. Copy `Config.template.plist` to `Config.plist`
2. Fill in your actual API keys in `Config.plist`
3. Make sure `Config.plist` is added to your Xcode project bundle
4. **Important**: `Config.plist` is gitignored and won't be committed to the repository

### Firebase Configuration
1. Copy `GoogleService-Info-Dev.template.plist` to `GoogleService-Info-Dev.plist`
2. Copy `GoogleService-Info-Prod.template.plist` to `GoogleService-Info-Prod.plist`
3. Fill in your actual Firebase configuration values
4. Make sure both plist files are added to your Xcode project bundle
5. **Important**: Both Firebase plist files are gitignored and won't be committed to the repository

### Option 2: Environment Variables (Recommended for CI/CD)
Set the following environment variables:
- `OPENAI_API_KEY` - Your OpenAI API key
- `MIXPANEL_TOKEN` - Your Mixpanel token

### Security Notes
- `Config.plist` and `Config.template.plist` are already added to `.gitignore`
- Never commit your actual API keys to version control
- The template file shows the required structure without exposing sensitive data

## API Keys Required
- **OpenAI API Key**: For AI chat functionality
- **Mixpanel Token**: For analytics tracking

## 🚀 Getting Started (For New Developers)

1. **Clone the repository**
2. **Copy the templates**:
   ```bash
   cp Config.template.plist Config.plist
   cp GoogleService-Info-Dev.template.plist GoogleService-Info-Dev.plist
   cp GoogleService-Info-Prod.template.plist GoogleService-Info-Prod.plist
   ```
3. **Get your API keys**:
   - [OpenAI API Key](https://platform.openai.com/account/api-keys)
   - [Mixpanel Token](https://mixpanel.com/settings/project/token)
4. **Get your Firebase configuration**:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project or select existing one
   - Add iOS app and download the `GoogleService-Info.plist` files
5. **Fill in the configuration files** with your actual values
6. **Add all plist files to Xcode project** (right-click → Add Files to Project)
7. **Build and run** your app

**Note**: All template files are safe to commit and show the required structure. Your actual configuration files with real keys will never be committed to the repository.
