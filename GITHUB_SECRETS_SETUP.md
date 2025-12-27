# GitHub Secrets Setup Guide

This guide provides step-by-step instructions for setting up GitHub Secrets for the AIChat project's CI/CD pipeline.

## Overview

GitHub Secrets allow you to securely store sensitive information (like API keys) that your GitHub Actions workflows need. The secrets are encrypted and never exposed in logs.

## Required Secrets

For the AIChat project, you need to configure these three secrets:

| Secret Name | Purpose | How to Get It |
|-------------|---------|---------------|
| `OPENAI_API_KEY` | Access OpenAI API for chat functionality | [platform.openai.com/api-keys](https://platform.openai.com/api-keys) |
| `MIXPANEL_TOKEN` | Analytics tracking in the app | [mixpanel.com/settings/project](https://mixpanel.com/settings/project) |
| `NEWSAPI_API_KEY` | Access news articles API | [newsapi.org/account](https://newsapi.org/account) |

## Step-by-Step Setup

### 1. Navigate to GitHub Repository Settings

1. Go to your GitHub repository: `https://github.com/YOUR_USERNAME/AIChat`
2. Click on the **Settings** tab (top navigation bar)
3. You must have admin access to the repository to add secrets

### 2. Access Secrets Configuration

1. In the left sidebar, find **Secrets and variables**
2. Click to expand it
3. Select **Actions**

You should now see the "Actions secrets and variables" page.

### 3. Add Each Secret

For each of the three required secrets:

1. Click the **New repository secret** button
2. Fill in the form:
   - **Name**: Enter the exact secret name (case-sensitive!)
     - `OPENAI_API_KEY`
     - `MIXPANEL_TOKEN`
     - `NEWSAPI_API_KEY`
   - **Secret**: Paste the actual API key value
3. Click **Add secret**

**Important:**
- Secret names are **case-sensitive** and must match exactly
- Once saved, secret values cannot be viewed (only updated)
- Secrets are encrypted at rest and in transit

### 4. Verify Secrets Are Added

After adding all three secrets, you should see them listed:

```
OPENAI_API_KEY         Updated now by username
MIXPANEL_TOKEN         Updated now by username
NEWSAPI_API_KEY        Updated now by username
```

## How Secrets Are Used in CI/CD

The GitHub Actions workflow (`.github/workflows/CI.yml`) automatically uses these secrets:

```yaml
- name: Build Project
  env:
    OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
    MIXPANEL_TOKEN: ${{ secrets.MIXPANEL_TOKEN }}
    NEWSAPI_API_KEY: ${{ secrets.NEWSAPI_API_KEY }}
  run: |
    xcodebuild clean build ...
```

When the workflow runs:
1. GitHub injects the secret values as environment variables
2. Swift Configuration reads them via `EnvironmentVariablesProvider`
3. The app uses them instead of requiring `Config.plist`
4. Secret values are never printed in logs (GitHub redacts them automatically)

## Testing Your Setup

### Method 1: Push to Main Branch

1. Make a small change (e.g., update README)
2. Commit and push to the `main` branch
3. Go to **Actions** tab in GitHub
4. Click on the latest workflow run
5. Expand the "Build Project" step
6. Look for logs indicating environment variables were loaded

### Method 2: Create a Pull Request

1. Create a new branch with any change
2. Push and create a PR to `main`
3. CI will automatically run
4. Check the workflow run in the PR

**Note:** For security, secrets are **not** available to workflows triggered by pull requests from forked repositories.

## Verifying Secrets Work

In the workflow logs, you should see:

```
✅ Keys: OpenAI API Key loaded from ENV: sk-proj-***
✅ Keys: Mixpanel Token loaded from ENV: abc***
✅ Keys: NewsAPI Key loaded from ENV: xyz***
```

The actual values are automatically redacted by GitHub (shown as `***`).

## Security Best Practices

### ✅ DO:
- Use GitHub Secrets for all sensitive values
- Rotate secrets regularly (every 90 days)
- Use different API keys for dev/staging/production
- Remove secrets for services you no longer use
- Audit who has access to repository settings

### ❌ DON'T:
- Never commit API keys to the repository
- Never echo secret values in workflow logs
- Never share secret values via insecure channels
- Don't use the same API keys across multiple projects
- Don't grant repository access to untrusted users

## Managing Secrets

### Updating a Secret

1. Go to Settings → Secrets and variables → Actions
2. Click on the secret name
3. Click **Update secret**
4. Enter the new value
5. Click **Update secret**

The next workflow run will automatically use the new value.

### Deleting a Secret

1. Go to Settings → Secrets and variables → Actions
2. Click on the secret name
3. Click **Remove secret**
4. Confirm deletion

**Warning:** Deleting a secret will cause workflows to fail if they depend on it.

### Rotating Secrets

Best practice for rotating secrets:

1. **Generate new key** from the service provider (OpenAI, Mixpanel, etc.)
2. **Update GitHub Secret** with the new value
3. **Test workflow** runs successfully with new key
4. **Delete old key** from the service provider
5. **Document rotation** in your security log

## Troubleshooting

### Problem: "Context access might be invalid" warnings

**Solution:** These warnings appear in the IDE but are normal. The secrets will be available when the workflow runs in GitHub Actions.

### Problem: Workflow fails with "unauthorized" or "invalid API key"

**Possible causes:**
1. Secret name doesn't match (check case-sensitivity)
2. API key is invalid or expired
3. Secret not set (go to Settings → Secrets)
4. Workflow running from a forked repository (secrets not available)

**Solution:** Verify secret names and values in GitHub Settings.

### Problem: Can't see secret values

**This is normal!** GitHub encrypts secrets and never displays them after creation. You can only update or delete them.

### Problem: Secrets work locally but not in CI

**Possible causes:**
1. Using `Config.plist` locally vs environment variables in CI
2. Different API keys between local and CI
3. Secrets not configured in GitHub

**Solution:** Check the workflow logs to see which configuration source is being used.

## Environment Variables in Different Contexts

| Context | How to Set | Priority |
|---------|------------|----------|
| **Local Xcode** | Edit Scheme → Arguments → Environment Variables | 1st (iOS 18.0+) |
| **GitHub Actions** | Settings → Secrets and variables → Actions | 1st (via env:) |
| **Fallback** | Config.plist file (gitignored) | 2nd |

## Additional Resources

- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

- [SWIFT_CONFIGURATION_INTEGRATION.md](SWIFT_CONFIGURATION_INTEGRATION.md) - Swift Configuration details
- [.github/workflows/CI.yml](.github/workflows/CI.yml) - The workflow file using secrets

## Quick Reference

### Add a new secret:
```
Settings → Secrets and variables → Actions → New repository secret
```

### Update existing secret:
```
Settings → Secrets and variables → Actions → Click secret → Update secret
```

### Check if secrets are working:
```
Actions tab → Latest workflow run → Expand build steps → Look for environment variable logs
```

---

Generated with [Claude Code](https://claude.com/claude-code)
