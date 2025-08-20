# 🚀 AIChat Project Setup Guide

This guide will help you set up the AIChat project with your own API keys and Firebase configuration.

## 🔑 Required API Keys & Services

### 1. OpenAI API Key
- **Purpose**: AI chat functionality
- **Get it**: [OpenAI Platform](https://platform.openai.com/account/api-keys)
- **Cost**: Pay-per-use (very affordable for development)

### 2. Mixpanel Token
- **Purpose**: Analytics tracking
- **Get it**: [Mixpanel Settings](https://mixpanel.com/settings/project/token)
- **Cost**: Free tier available

### 3. Firebase Configuration
- **Purpose**: Authentication, database, storage, analytics
- **Get it**: [Firebase Console](https://console.firebase.google.com/)
- **Cost**: Generous free tier

## 📱 Step-by-Step Setup

### Step 1: Clone the Repository
```bash
git clone <your-repo-url>
cd AIChat
```

### Step 2: Copy Configuration Templates
```bash
# Copy API configuration template
cp Config.template.plist Config.plist

# Copy Firebase configuration templates
cp GoogleService-Info-Dev.template.plist GoogleService-Info-Dev.plist
cp GoogleService-Info-Prod.template.plist GoogleService-Info-Prod.plist
```

### Step 3: Configure API Keys
Edit `Config.plist` and replace the placeholder values:

```xml
<key>OpenAIAPIKey</key>
<string>sk-your-actual-openai-api-key-here</string>
<key>MixpanelToken</key>
<string>your-actual-mixpanel-token-here</string>
```

### Step 4: Configure Firebase

#### 4.1 Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or select existing project
3. Follow the setup wizard

#### 4.2 Add iOS App
1. Click "Add app" → iOS
2. Enter your bundle ID (e.g., `com.YourName.AIChat`)
3. Download the `GoogleService-Info.plist` file

#### 4.3 Configure Development Environment
1. Edit `GoogleService-Info-Dev.plist`
2. Replace all placeholder values with your actual Firebase configuration
3. Make sure bundle ID matches your development target

#### 4.4 Configure Production Environment
1. Edit `GoogleService-Info-Prod.plist`
2. Replace all placeholder values with your actual Firebase configuration
3. Make sure bundle ID matches your production target

### Step 5: Add Files to Xcode Project
1. **Open your Xcode project** (`AIChat.xcodeproj`)
2. **Right-click on your project navigator**
3. **Select "Add Files to AIChat"**
4. **Add all three plist files**:
   - `Config.plist`
   - `GoogleService-Info-Dev.plist`
   - `GoogleService-Info-Prod.plist`
5. **Verify target membership** for all files

### Step 6: Build and Test
1. **Clean build folder**: Product → Clean Build Folder
2. **Build and run** your app
3. **Check console output** for configuration messages

## 🔍 Verification

When everything is configured correctly, you should see:

```
📱 ConfigurationManager: Found Config.plist at: /path/to/your/app/Config.plist
📱 ConfigurationManager: Successfully loaded configuration
🔑 Keys: OpenAI API Key loaded: sk-proj-...
🔑 Keys: Mixpanel Token loaded: 5b7313d0...
📱 ConfigurationManager: Found Firebase config for dev at: /path/to/GoogleService-Info-Dev.plist
```

## 🚨 Troubleshooting

### "Config.plist not found" Error
- Make sure `Config.plist` is added to your Xcode project
- Check target membership in File Inspector
- Clean build folder and rebuild

### "Firebase config not found" Error
- Make sure both Firebase plist files are added to Xcode
- Verify file names match exactly (case-sensitive)
- Check target membership

### API Key Errors
- Verify your API keys are correct
- Check that you've replaced all placeholder values
- Ensure no extra spaces or characters

## 🔒 Security Notes

- ✅ **Template files are safe** to commit to version control
- ✅ **Real configuration files are gitignored** and won't be committed
- ✅ **Never commit** your actual API keys or Firebase configuration
- ✅ **Use environment variables** for CI/CD pipelines

## 📚 Additional Resources

- [OpenAI API Documentation](https://platform.openai.com/docs)
- [Mixpanel Documentation](https://developer.mixpanel.com/)
- [Firebase iOS Setup](https://firebase.google.com/docs/ios/setup)
- [iOS App Security Best Practices](https://developer.apple.com/security/)

## 🆘 Need Help?

If you encounter issues:
1. Check the console output for error messages
2. Verify all files are added to Xcode project
3. Ensure target membership is correct
4. Clean build folder and rebuild

---

**Happy coding! 🎉**
