# Environment Variables Guide

This guide explains how to use environment variables with Swift Configuration in the AIChat project.

## ⚠️ IMPORTANT: Security

**NEVER commit environment variables to the repository!**

- ✅ Set them in Xcode scheme (local to your machine)
- ✅ Set them in CI/CD environment (GitHub Actions secrets)
- ❌ Never commit them in code
- ❌ Never commit them in scheme files (they're in `.gitignore`)

## Setting Environment Variables in Xcode

### Step 1: Edit Scheme
1. In Xcode, go to **Product → Scheme → Edit Scheme...**
2. Select **Run** in the left sidebar
3. Click on the **Arguments** tab

### Step 2: Add Environment Variables
Under **Environment Variables**, click the **+** button and add:

| Name | Value | Description |
|------|-------|-------------|
| `OPENAI_API_KEY` | `sk-...` | Your OpenAI API key |
| `MIXPANEL_TOKEN` | `abc123...` | Your Mixpanel token |
| `NEWSAPI_API_KEY` | `xyz789...` | Your NewsAPI key |

### Step 3: Run Your App
When you run the app, you'll see in the console:

```
🔍 Keys: Checking environment variable OPENAI_API_KEY via Swift Configuration...
✅ Keys: OpenAI API Key loaded from ENV: sk-proj...
```

## How It Works

On iOS 18.0+, the app checks environment variables first using Swift Configuration:

```swift
// 1. Check environment variable (via Swift Configuration)
let envReader = ConfigReader(provider: EnvironmentVariablesProvider())
if let envKey = envReader.string(forKey: "OPENAI_API_KEY"), !envKey.isEmpty {
    return envKey  // ✅ Use environment variable
}

// 2. Fallback to Config.plist
return ConfigurationManager.shared.openAIAPIKey
```

## Configuration Priority

1. **🥇 Environment Variables** (iOS 18.0+ via Swift Configuration)
2. **🥈 Config.plist** (all iOS versions)
3. **🥉 Defaults** (empty strings)

## Benefits of Environment Variables

### Local Development
- ✅ Keep secrets out of config files
- ✅ Easy switching between different API keys
- ✅ No risk of committing secrets

### CI/CD Pipelines
- ✅ Set via GitHub Actions secrets
- ✅ Different keys for different environments
- ✅ Secure deployment

## Example: GitHub Actions

In your CI/CD workflow, set secrets:

```yaml
- name: Run Tests
  env:
    OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
    MIXPANEL_TOKEN: ${{ secrets.MIXPANEL_TOKEN }}
    NEWSAPI_API_KEY: ${{ secrets.NEWSAPI_API_KEY }}
  run: |
    xcodebuild test ...
```

## Verifying Configuration Source

Run your app and check the console logs:

### Using Environment Variables
```
🔍 Keys: Checking environment variable MIXPANEL_TOKEN via Swift Configuration...
✅ Keys: Mixpanel Token loaded from ENV: abc123...
```

### Using Config.plist (Fallback)
```
🔍 Keys: Checking environment variable MIXPANEL_TOKEN via Swift Configuration...
⚠️ Keys: MIXPANEL_TOKEN not found in environment, falling back to Config.plist
📱 ConfigurationManager: Using Mixpanel token from Config.plist
🔑 Keys: Mixpanel Token loaded from Config: abc123...
```

## Troubleshooting

### Environment Variables Not Working?

1. **Check iOS Version**: Environment variables via Swift Configuration only work on iOS 18.0+
2. **Check Scheme**: Make sure you added them in the correct scheme (Development, Production, etc.)
3. **Restart Xcode**: Sometimes Xcode needs a restart to pick up scheme changes
4. **Check Logs**: Look for the "🔍 Checking environment variable..." logs

### Still Using Config.plist?

This is normal! If environment variables aren't set, the app correctly falls back to Config.plist. This is the expected behavior and ensures your app always has configuration values.

## Best Practices

### For Local Development
- Use Config.plist for your personal API keys (already in `.gitignore`)
- Use environment variables when testing CI/CD configuration
- Use Mock scheme for UI testing without real API keys

### For CI/CD
- Always use environment variables
- Never commit API keys to the repository
- Use GitHub Secrets or your CI platform's secret management

### For Production
- Use Config.plist with real keys (not committed)
- Consider remote configuration for runtime updates
- Monitor configuration loading in logs

## Related Files

- [Keys.swift](AIChat/Utilities/Keys.swift) - Uses Swift Configuration for environment variables
- [ConfigurationManager.swift](AIChat/Utilities/ConfigurationManager.swift) - Fallback for Config.plist
- [EnhancedConfigurationManager.swift](AIChat/Utilities/EnhancedConfigurationManager.swift) - Async configuration API
- [SWIFT_CONFIGURATION_INTEGRATION.md](SWIFT_CONFIGURATION_INTEGRATION.md) - Full integration guide

---

Generated with [Claude Code](https://claude.com/claude-code)
