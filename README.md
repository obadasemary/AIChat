# AIChat 


[![iOS Build & Test](https://github.com/obadasemary/AIChat/actions/workflows/CI.yml/badge.svg)](https://github.com/obadasemary/AIChat/actions/workflows/CI.yml)

## Configuration

This project requires API keys to function properly. To set up your configuration:

### Option 1: Configuration File (Recommended for Development)
1. Copy `Config.template.plist` to `Config.plist`
2. Fill in your actual API keys in `Config.plist`
3. Make sure `Config.plist` is added to your Xcode project bundle
4. **Important**: `Config.plist` is gitignored and won't be committed to the repository

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
2. **Copy the template**: `cp Config.template.plist Config.plist`
3. **Get your API keys**:
   - [OpenAI API Key](https://platform.openai.com/account/api-keys)
   - [Mixpanel Token](https://mixpanel.com/settings/project/token)
4. **Fill in `Config.plist`** with your actual keys
5. **Add `Config.plist` to Xcode project** (right-click → Add Files to Project)
6. **Build and run** your app

**Note**: The `Config.template.plist` file is safe to commit and shows the required structure. Your actual `Config.plist` with real keys will never be committed to the repository.
