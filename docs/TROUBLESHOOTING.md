# Troubleshooting Guide

Common issues and solutions for AIChat development and runtime problems.

## Table of Contents

1. [Build Issues](#build-issues)
2. [Configuration Issues](#configuration-issues)
3. [Runtime Issues](#runtime-issues)
4. [Testing Issues](#testing-issues)
5. [Firebase Issues](#firebase-issues)
6. [API Issues](#api-issues)
7. [UI Issues](#ui-issues)
8. [Performance Issues](#performance-issues)

---

## Build Issues

### SwiftLint Errors

#### Force Unwrapping Error
```
error: Force unwrapping should be avoided (force_unwrapping)
```

**Solution**: Replace force unwrapping with safe alternatives:
```swift
// Bad
let value = optionalValue!

// Good
guard let value = optionalValue else { return }
// or
if let value = optionalValue {
    // use value
}
// or
let value = optionalValue ?? defaultValue
```

#### Force Try Error
```
error: Force try should be avoided (force_try)
```

**Solution**: Use proper error handling:
```swift
// Bad
let data = try! JSONDecoder().decode(Model.self, from: jsonData)

// Good
do {
    let data = try JSONDecoder().decode(Model.self, from: jsonData)
} catch {
    print("Decoding error: \(error)")
}
```

### Module Not Found

```
error: No such module 'Firebase'
```

**Solution**:
1. Close Xcode
2. Delete derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`
3. Clean SPM cache: `rm -rf ~/Library/Caches/org.swift.swiftpm`
4. Reopen project and let packages resolve

### Signing Issues

```
error: Signing for "AIChat" requires a development team
```

**Solution**:
1. Select the project in navigator
2. Go to Signing & Capabilities
3. Select your team from dropdown
4. Ensure bundle identifier is unique

### Simulator Not Found

```
error: Unable to find a destination matching 'iPhone 17 Pro'
```

**Solution**:
1. Open Xcode → Window → Devices and Simulators
2. Add the required simulator
3. Or use a different simulator name in build command

---

## Configuration Issues

### Missing Config.plist

```
Fatal error: Config.plist not found
```

**Solution**:
1. Copy template: `cp Config.template.plist Config.plist`
2. Add your API keys to `Config.plist`
3. Add file to Xcode project with correct target membership

### Missing Firebase Configuration

```
Firebase configuration not found for .dev
```

**Solution**:
1. Copy templates:
   ```bash
   cp GoogleService-Info-Dev.template.plist GoogleService-Info-Dev.plist
   cp GoogleService-Info-Prod.template.plist GoogleService-Info-Prod.plist
   ```
2. Download actual config from Firebase Console
3. Replace template content with real configuration
4. Add files to Xcode project

### API Key Not Working

**Symptoms**: API calls fail with 401 or invalid key errors

**Solution**:
1. Verify key is correctly set in Config.plist
2. Check environment variable in scheme settings
3. Ensure no extra whitespace in key value
4. Verify key has required permissions/scopes
5. Check if key has expired or been revoked

### Environment Variables Not Loading

**Symptoms**: `Keys.openAIAPIKey` returns empty string

**Solution**:
1. For iOS 18.0+, ensure Swift Configuration is set up
2. Check scheme environment variables
3. Verify Config.plist fallback is configured
4. Print debug: `print(ProcessInfo.processInfo.environment)`

---

## Runtime Issues

### App Crashes on Launch

**Symptoms**: App crashes immediately after launch

**Common Causes & Solutions**:

1. **Missing Firebase configuration**
   - Ensure GoogleService-Info plist is added to target

2. **Force unwrapping nil value**
   - Check crash logs for exact line
   - Add nil checks

3. **Missing required permissions**
   - Check Info.plist for required keys

### Memory Warnings

**Symptoms**: App receives memory warnings or crashes

**Solution**:
1. Use Instruments to profile memory usage
2. Check for retain cycles in closures
3. Use `[weak self]` in closures
4. Release large resources when not needed

### Network Requests Failing

**Symptoms**: API calls timeout or fail

**Debugging Steps**:
1. Check device/simulator network connection
2. Verify API endpoint is correct
3. Check API key is valid
4. Look for SSL/certificate issues
5. Check if API has rate limits

### Data Not Persisting

**Symptoms**: SwiftData or UserDefaults not saving

**Solution**:
1. Ensure model context is saved after changes
2. Check for threading issues (use @MainActor)
3. Verify model container is set up correctly
4. Check for encoding/decoding errors

---

## Testing Issues

### Unit Tests Failing

**Symptoms**: Tests pass locally but fail in CI

**Common Causes**:
1. **Timing issues**: Add proper async/await handling
2. **Mock data differences**: Ensure mocks are deterministic
3. **Environment differences**: Check simulator version

### UI Tests Failing

**Symptoms**: UI tests can't find elements

**Solution**:
1. Add accessibility identifiers to views
2. Wait for elements to appear:
   ```swift
   let button = app.buttons["submit"]
   XCTAssertTrue(button.waitForExistence(timeout: 5))
   ```
3. Ensure correct scheme (AIChat - Mock)
4. Check for overlapping elements

### Mock Scheme Not Working

**Symptoms**: Real API calls in mock mode

**Solution**:
1. Verify scheme is set to "AIChat - Mock"
2. Check Dependencies.swift mock configuration
3. Ensure mock services are properly implemented

---

## Firebase Issues

### Firebase Not Initializing

```
[Firebase/Core] Firebase app has not been configured yet
```

**Solution**:
1. Ensure `configureFirebase()` is called early in app lifecycle
2. Check correct plist is being loaded for build config
3. Verify plist has valid Firebase configuration

### Firestore Permission Denied

```
PERMISSION_DENIED: Missing or insufficient permissions
```

**Solution**:
1. Check Firebase Security Rules
2. Verify user is authenticated
3. Ensure document path is correct
4. Check if user has access to the document

### Authentication Errors

```
Error Domain=FIRAuthErrorDomain Code=17999
```

**Common Fixes**:
1. Enable sign-in method in Firebase Console
2. Check OAuth configuration for Apple/Google sign-in
3. Verify bundle ID matches Firebase config

---

## API Issues

### OpenAI API Errors

#### Rate Limited
```
error: Rate limit exceeded
```

**Solution**:
1. Implement exponential backoff
2. Reduce request frequency
3. Upgrade API plan if needed

#### Invalid API Key
```
error: Invalid API key
```

**Solution**:
1. Verify key in OpenAI dashboard
2. Check key hasn't been rotated
3. Ensure no extra whitespace

### NewsAPI Errors

#### Daily Limit Reached
```
error: You have made too many requests
```

**Solution**:
1. Free tier: 100 requests/day
2. Implement caching to reduce calls
3. Upgrade plan if needed

#### Missing API Key
```
error: apiKey is required
```

**Solution**:
1. Add NEWSAPI_API_KEY to environment
2. Add NewsAPIKey to Config.plist

---

## UI Issues

### Views Not Updating

**Symptoms**: UI doesn't reflect data changes

**Solution**:
1. Ensure @Observable is used correctly
2. Check property wrappers (@State, @Binding)
3. Verify updates happen on main thread
4. Use @MainActor for ViewModels

### Dark Mode Issues

**Symptoms**: Colors wrong in dark mode

**Solution**:
1. Use semantic colors (Color.primary, .secondary)
2. Define colors in asset catalog with dark variants
3. Test both modes during development

### Layout Breaking

**Symptoms**: UI looks wrong on different devices

**Solution**:
1. Use safe area insets
2. Test on multiple simulators
3. Avoid hardcoded sizes
4. Use flexible layouts (VStack, HStack, LazyVGrid)

---

## Performance Issues

### Slow App Launch

**Symptoms**: App takes long to start

**Solution**:
1. Defer non-essential initialization
2. Use lazy loading for heavy resources
3. Profile with Instruments
4. Reduce main thread work

### Scrolling Jank

**Symptoms**: Choppy scrolling in lists

**Solution**:
1. Use LazyVStack/LazyHStack
2. Implement proper cell reuse
3. Load images asynchronously
4. Avoid heavy computations in cell views

### High Memory Usage

**Symptoms**: Memory warnings, app termination

**Solution**:
1. Implement proper image caching
2. Release unused resources
3. Check for retain cycles
4. Use Instruments to find leaks

---

## Getting Help

If you can't resolve an issue:

1. **Search existing issues**: [GitHub Issues](https://github.com/obadasemary/AIChat/issues)
2. **Create new issue**: Include error messages, steps to reproduce, environment details
3. **Contact support**: obada.semary@gmail.com

### Information to Include

When reporting issues, provide:
- Xcode version
- iOS version
- Device/Simulator type
- Build configuration (Dev/Prod/Mock)
- Complete error message
- Steps to reproduce
- Relevant code snippets
