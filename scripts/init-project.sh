#!/bin/bash
set -e

echo "=== Swift macOS Starter Kit - Project Initialization ==="
echo ""

# =============================================================================
# Check we're in the right place
# =============================================================================

# Warn if running from starter kit directory itself
if [ -f "templates/Package.swift" ]; then
    echo "Warning: You appear to be running from the starter kit directory."
    echo ""
    echo "Recommended usage:"
    echo "  1. Create a new directory for your project"
    echo "  2. cd into that directory"
    echo "  3. Run this script from there"
    echo ""
    echo "Example:"
    echo "  mkdir my-app && cd my-app"
    echo "  git init && git remote add origin git@github.com:you/my-app.git"
    echo "  /path/to/swift-macos-starter/scripts/init-project.sh"
    echo ""
    read -p "Continue anyway in current directory? (y/n): " CONTINUE
    if [ "$CONTINUE" != "y" ]; then
        exit 0
    fi
fi

# =============================================================================
# Auto-detect values
# =============================================================================

# Developer name from certificate
DETECTED_DEV_NAME=$(security find-identity -v -p codesigning 2>/dev/null | grep "Developer ID Application" | head -1 | sed 's/.*Developer ID Application: \([^(]*\).*/\1/' | xargs)

# GitHub username from gh CLI or git config
if command -v gh &> /dev/null && gh auth status &> /dev/null 2>&1; then
    DETECTED_GITHUB_USER=$(gh api user -q .login 2>/dev/null || echo "")
fi
if [ -z "$DETECTED_GITHUB_USER" ]; then
    DETECTED_GITHUB_USER=$(git config --get github.user 2>/dev/null || echo "")
fi

# Repository name from current directory or git remote
DETECTED_REPO_NAME=$(basename "$(pwd)")
if git remote -v &> /dev/null; then
    REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
    if [ -n "$REMOTE_URL" ]; then
        DETECTED_REPO_NAME=$(basename -s .git "$REMOTE_URL")
    fi
fi

# App name defaults to repo name (capitalized)
DETECTED_APP_NAME=$(echo "$DETECTED_REPO_NAME" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1' | sed 's/ //g')

# =============================================================================
# Prompt with auto-detected defaults
# =============================================================================

echo "Auto-detected values (press Enter to accept, or type to override):"
echo ""

read -p "App name [$DETECTED_APP_NAME]: " APP_NAME
APP_NAME=${APP_NAME:-$DETECTED_APP_NAME}

read -p "GitHub username [$DETECTED_GITHUB_USER]: " GITHUB_USER
GITHUB_USER=${GITHUB_USER:-$DETECTED_GITHUB_USER}

read -p "Repository name [$DETECTED_REPO_NAME]: " REPO_NAME
REPO_NAME=${REPO_NAME:-$DETECTED_REPO_NAME}

# Construct default bundle ID
DEFAULT_BUNDLE_ID="com.${GITHUB_USER,,}.${APP_NAME,,}"
read -p "Bundle identifier [$DEFAULT_BUNDLE_ID]: " BUNDLE_ID
BUNDLE_ID=${BUNDLE_ID:-$DEFAULT_BUNDLE_ID}

read -p "Developer name [$DETECTED_DEV_NAME]: " DEV_NAME
DEV_NAME=${DEV_NAME:-$DETECTED_DEV_NAME}

read -p "App description (one line): " APP_DESCRIPTION

# Validate
if [ -z "$APP_NAME" ] || [ -z "$BUNDLE_ID" ]; then
    echo "Error: App name and bundle ID are required"
    exit 1
fi

echo ""
echo "Creating project structure for: $APP_NAME"

# Create directories
mkdir -p "$APP_NAME"
mkdir -p "$APP_NAME/App"
mkdir -p "$APP_NAME/Views"
mkdir -p "$APP_NAME/Services"
mkdir -p "$APP_NAME/Resources"
mkdir -p ".github/workflows"
mkdir -p "scripts"

# Copy and customize templates
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/../templates"

echo "Copying templates..."

# Function to copy and replace placeholders
copy_template() {
    local src="$1"
    local dest="$2"

    if [ -f "$src" ]; then
        sed -e "s/__APP_NAME__/$APP_NAME/g" \
            -e "s/__BUNDLE_ID__/$BUNDLE_ID/g" \
            -e "s/__DEVELOPER_NAME__/$DEV_NAME/g" \
            -e "s/__GITHUB_USER__/$GITHUB_USER/g" \
            -e "s/__REPO_NAME__/$REPO_NAME/g" \
            -e "s/__APP_DESCRIPTION__/$APP_DESCRIPTION/g" \
            "$src" > "$dest"
        echo "  Created: $dest"
    fi
}

# Core app files
copy_template "$TEMPLATE_DIR/App/AppDelegate.swift" "$APP_NAME/App/AppDelegate.swift"
copy_template "$TEMPLATE_DIR/App/StatusBarController.swift" "$APP_NAME/App/StatusBarController.swift"

# Config files
copy_template "$TEMPLATE_DIR/Info.plist" "$APP_NAME/Resources/Info.plist"
copy_template "$TEMPLATE_DIR/MyApp.entitlements" "$APP_NAME/$APP_NAME.entitlements"
copy_template "$TEMPLATE_DIR/Package.swift" "Package.swift"

# GitHub workflows
copy_template "$SCRIPT_DIR/../.github/workflows/build.yml" ".github/workflows/build.yml"
copy_template "$SCRIPT_DIR/../.github/workflows/release.yml" ".github/workflows/release.yml"

# Scripts
cp "$SCRIPT_DIR/setup-secrets.sh" "scripts/setup-secrets.sh"
cp "$SCRIPT_DIR/generate-icon.swift" "scripts/generate-icon.swift"
chmod +x scripts/*.sh

# Track what features are included for TODO.md
INCLUDE_LICENSE="n"
INCLUDE_SPARKLE="n"
SPARKLE_PUBLIC_KEY=""

echo ""
echo "=== Optional Features ==="
echo ""

# License system prompt
read -p "Include License system? (y/n): " INCLUDE_LICENSE
if [ "$INCLUDE_LICENSE" = "y" ]; then
    copy_template "$TEMPLATE_DIR/License/LicenseManager.swift" "$APP_NAME/Services/LicenseManager.swift"
    copy_template "$TEMPLATE_DIR/License/LicenseView.swift" "$APP_NAME/Views/LicenseView.swift"
    copy_template "$TEMPLATE_DIR/License/LicenseWindowController.swift" "$APP_NAME/Views/LicenseWindowController.swift"
    copy_template "$TEMPLATE_DIR/License/success.html" "success.html"
    echo "  License files copied."
fi

# Sparkle prompt
read -p "Include Sparkle auto-updates? (y/n): " INCLUDE_SPARKLE
if [ "$INCLUDE_SPARKLE" = "y" ]; then
    copy_template "$TEMPLATE_DIR/Sparkle/appcast.xml" "appcast.xml"
    echo "  Sparkle files copied."

    echo ""
    echo "=== Generating Sparkle EdDSA Keys ==="
    echo ""

    # Download Sparkle to temp directory (not project)
    SPARKLE_TEMP=$(mktemp -d)
    echo "Downloading Sparkle tools to temp directory..."
    curl -sL -o "$SPARKLE_TEMP/Sparkle.tar.xz" "https://github.com/sparkle-project/Sparkle/releases/download/2.6.4/Sparkle-2.6.4.tar.xz"
    tar -xf "$SPARKLE_TEMP/Sparkle.tar.xz" -C "$SPARKLE_TEMP"

    # Generate keys
    echo "Generating EdDSA key pair..."
    KEY_OUTPUT=$("$SPARKLE_TEMP/bin/generate_keys" 2>&1)

    # Extract public key
    SPARKLE_PUBLIC_KEY=$(echo "$KEY_OUTPUT" | grep -A1 "public" | tail -1 | tr -d ' ')
    SPARKLE_PRIVATE_KEY=$(echo "$KEY_OUTPUT" | grep -A1 "private" | tail -1 | tr -d ' ')

    # Clean up Sparkle temp files
    rm -rf "$SPARKLE_TEMP"

    if [ -n "$SPARKLE_PUBLIC_KEY" ]; then
        echo "  Public key:  $SPARKLE_PUBLIC_KEY"
        echo "  Private key: [saved for GitHub secrets]"

        # Save private key temporarily for secrets upload
        echo "$SPARKLE_PRIVATE_KEY" > .sparkle_private_key.tmp
    else
        echo "  Warning: Could not extract keys. Run manually:"
        echo "  curl -L -o Sparkle.tar.xz 'https://github.com/sparkle-project/Sparkle/releases/download/2.6.4/Sparkle-2.6.4.tar.xz'"
        echo "  tar -xf Sparkle.tar.xz && ./bin/generate_keys"
    fi
fi

echo ""
echo "=== GitHub Secrets Setup ==="
echo ""
echo "Note: The GitHub repository must exist before uploading secrets."
echo "Create it at: https://github.com/new"
echo ""
read -p "Set up GitHub secrets now? (y/n): " SETUP_SECRETS
if [ "$SETUP_SECRETS" = "y" ]; then
    # Check gh CLI
    if ! command -v gh &> /dev/null; then
        echo "Error: GitHub CLI (gh) is required. Install with: brew install gh"
        echo "Skipping secrets setup. Run ./scripts/setup-secrets.sh later."
        SETUP_SECRETS="n"
    elif ! gh auth status &> /dev/null; then
        echo "Error: Not authenticated with GitHub CLI. Run: gh auth login"
        echo "Skipping secrets setup. Run ./scripts/setup-secrets.sh later."
        SETUP_SECRETS="n"
    else
        # Detect repository
        REPO="$GITHUB_USER/$REPO_NAME"

        # Check if repo exists
        if ! gh repo view "$REPO" &> /dev/null; then
            echo "Warning: Repository $REPO does not exist on GitHub."
            read -p "Create it now? (y/n): " CREATE_REPO
            if [ "$CREATE_REPO" = "y" ]; then
                echo "Creating repository..."
                gh repo create "$REPO" --private --source=. --remote=origin 2>/dev/null || \
                gh repo create "$REPO" --public --source=. --remote=origin 2>/dev/null || {
                    echo "Could not create repo. Please create it manually at https://github.com/new"
                    echo "Then run ./scripts/setup-secrets.sh"
                    SETUP_SECRETS="n"
                }
            else
                echo "Skipping secrets setup. Run ./scripts/setup-secrets.sh after creating the repo."
                SETUP_SECRETS="n"
            fi
        fi
    fi
fi

# Only proceed with secrets if still yes
if [ "$SETUP_SECRETS" = "y" ]; then
    echo "Repository: $REPO"
    echo ""

    # Collect Apple credentials
    read -p "Apple ID (email): " APPLE_ID
    read -s -p "App-specific password: " APPLE_APP_PASSWORD
    echo ""
    read -s -p "Certificate export password: " CERT_PASSWORD
    echo ""
    read -p "Apple Team ID: " TEAM_ID

    # Find Developer ID certificate
    echo ""
    echo "Finding Developer ID Application certificate..."
    CERT_NAME=$(security find-identity -v -p codesigning | grep "Developer ID Application" | head -1 | sed 's/.*"\(.*\)".*/\1/')

    if [ -z "$CERT_NAME" ]; then
        echo "Warning: No Developer ID Application certificate found in keychain"
        echo "Skipping certificate export. Add APPLE_CERTIFICATE_BASE64 manually."
    else
        echo "Found: $CERT_NAME"

        # Export certificate
        CERT_FILE=$(mktemp).p12
        if security export -k login.keychain-db -t identities -f pkcs12 -P "$CERT_PASSWORD" -o "$CERT_FILE" 2>/dev/null; then
            CERT_BASE64=$(base64 -i "$CERT_FILE")
            rm -f "$CERT_FILE"

            echo "Uploading secrets to GitHub..."
            gh secret set APPLE_CERTIFICATE_BASE64 --body "$CERT_BASE64" --repo "$REPO" 2>/dev/null || echo "  Warning: Could not set APPLE_CERTIFICATE_BASE64"
            gh secret set APPLE_CERTIFICATE_PASSWORD --body "$CERT_PASSWORD" --repo "$REPO" 2>/dev/null || echo "  Warning: Could not set APPLE_CERTIFICATE_PASSWORD"
        else
            echo "Warning: Failed to export certificate"
        fi
    fi

    # Upload other secrets
    gh secret set APPLE_ID --body "$APPLE_ID" --repo "$REPO" 2>/dev/null || echo "  Warning: Could not set APPLE_ID"
    gh secret set APPLE_APP_PASSWORD --body "$APPLE_APP_PASSWORD" --repo "$REPO" 2>/dev/null || echo "  Warning: Could not set APPLE_APP_PASSWORD"
    gh secret set APPLE_TEAM_ID --body "$TEAM_ID" --repo "$REPO" 2>/dev/null || echo "  Warning: Could not set APPLE_TEAM_ID"

    # Upload Sparkle private key if available
    if [ -f ".sparkle_private_key.tmp" ]; then
        SPARKLE_PRIVATE_KEY=$(cat .sparkle_private_key.tmp)
        gh secret set SPARKLE_PRIVATE_KEY --body "$SPARKLE_PRIVATE_KEY" --repo "$REPO" 2>/dev/null || echo "  Warning: Could not set SPARKLE_PRIVATE_KEY"
        rm -f .sparkle_private_key.tmp
        echo "  SPARKLE_PRIVATE_KEY uploaded"
    fi

    echo ""
    echo "Secrets uploaded successfully!"
fi

# Clean up temp files
rm -f .sparkle_private_key.tmp

# =============================================================================
# Generate TODO.md for coding agents
# =============================================================================

echo ""
echo "Generating TODO.md..."

cat > TODO.md << 'TODOEOF'
# TODO - Project Setup Tasks

This file contains remaining setup tasks for the project. A coding agent (like Claude) can help complete these.

## Required Tasks

TODOEOF

# Add app icon task
cat >> TODO.md << TODOEOF
### 1. App Icon
- [ ] Generate custom app icon
- Location: \`scripts/generate-icon.swift\`
- Current: Uses "waveform" SF Symbol with black circle background
- Action: Change the SF Symbol name on line 24 to match your app's purpose
- Run: \`swift scripts/generate-icon.swift && iconutil -c icns AppIcon.iconset\`
- Then add \`AppIcon.icns\` to Xcode project assets

TODOEOF

# Add Sparkle task if included
if [ "$INCLUDE_SPARKLE" = "y" ]; then
cat >> TODO.md << TODOEOF
### 2. Sparkle Auto-Updates
- [x] EdDSA keys generated
- [ ] Add public key to Info.plist
- Location: \`$APP_NAME/Resources/Info.plist\`
- Public key: \`$SPARKLE_PUBLIC_KEY\`
- Action: Uncomment and update these keys in Info.plist:
  \`\`\`xml
  <key>SUFeedURL</key>
  <string>https://$GITHUB_USER.github.io/$REPO_NAME/appcast.xml</string>
  <key>SUPublicEDKey</key>
  <string>$SPARKLE_PUBLIC_KEY</string>
  <key>SUEnableAutomaticChecks</key>
  <true/>
  \`\`\`
- [ ] Uncomment Sparkle in Package.swift
- [ ] Uncomment Sparkle code in AppDelegate.swift and StatusBarController.swift
- [ ] Enable GitHub Pages (Settings > Pages > Source: main branch, root)

TODOEOF
fi

# Add License task if included
if [ "$INCLUDE_LICENSE" = "y" ]; then
cat >> TODO.md << TODOEOF
### 3. License System
- [ ] Customize license keywords (12 words)
- Locations:
  - \`$APP_NAME/Services/LicenseManager.swift\` (line 23-27)
  - \`success.html\` (line 172-176)
- **IMPORTANT**: Keywords must match exactly in both files!
- Action: Replace WORD1-WORD12 with 12 unique words related to your app
- Example keywords: VOICE, AUDIO, WAVE, SOUND, MUSIC, RECORD, PLAY, MIX, TONE, BEAT, ECHO, LIVE

- [ ] Set Stripe checkout URL
- Location: \`$APP_NAME/Views/LicenseView.swift\` (line 106)
- Action: Replace \`__STRIPE_URL__\` with your Stripe Payment Link
- Get it from: Stripe Dashboard > Payment Links > Create

- [ ] Configure success.html
- Location: \`success.html\`
- Action: Update these values:
  - \`__WEBSITE_URL__\` → Your app's website (e.g., https://$APP_NAME.com)
  - \`__VALIDATION_CODE__\` → A secret code (e.g., "$APP_NAME" lowercase)
- Stripe success URL format: \`https://yourdomain.com/success.html?sid={CHECKOUT_SESSION_ID}&code=yourcode\`

TODOEOF
fi

# Add final tasks
cat >> TODO.md << TODOEOF
## After Completing Above Tasks

1. Create Xcode project:
   - File > New > Project > macOS > App
   - Product Name: $APP_NAME
   - Bundle Identifier: $BUNDLE_ID
   - Delete auto-generated ContentView.swift and ${APP_NAME}App.swift
   - Add files from \`$APP_NAME/\` folder

2. First release:
   \`\`\`bash
   git add .
   git commit -m "Initial project setup"
   git push
   git tag v1.0.0
   git push --tags
   \`\`\`

## Configuration Summary

| Setting | Value |
|---------|-------|
| App Name | $APP_NAME |
| Bundle ID | $BUNDLE_ID |
| Developer | $DEV_NAME |
| GitHub | $GITHUB_USER/$REPO_NAME |
TODOEOF

if [ "$INCLUDE_SPARKLE" = "y" ]; then
cat >> TODO.md << TODOEOF
| Sparkle Public Key | \`$SPARKLE_PUBLIC_KEY\` |
| Appcast URL | https://$GITHUB_USER.github.io/$REPO_NAME/appcast.xml |
TODOEOF
fi

echo "  Created: TODO.md"

# =============================================================================
# Final summary
# =============================================================================

echo ""
echo "=== Project initialization complete ==="
echo ""
echo "Files created:"
echo "  - $APP_NAME/App/AppDelegate.swift"
echo "  - $APP_NAME/App/StatusBarController.swift"
echo "  - $APP_NAME/Resources/Info.plist"
echo "  - $APP_NAME/$APP_NAME.entitlements"
echo "  - Package.swift"
echo "  - .github/workflows/build.yml"
echo "  - .github/workflows/release.yml"
if [ "$INCLUDE_LICENSE" = "y" ]; then
    echo "  - $APP_NAME/Services/LicenseManager.swift"
    echo "  - $APP_NAME/Views/LicenseView.swift"
    echo "  - $APP_NAME/Views/LicenseWindowController.swift"
    echo "  - success.html"
fi
if [ "$INCLUDE_SPARKLE" = "y" ]; then
    echo "  - appcast.xml"
fi
echo "  - TODO.md (remaining tasks for coding agent)"
echo ""
echo "Next step: Open TODO.md and complete the remaining tasks."
echo "A coding agent like Claude can help you with these!"
