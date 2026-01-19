# Swift macOS Starter Kit

A complete template for building macOS menu bar apps with code signing, notarization, auto-updates, and licensing.

## Quick Start

```bash
# 1. Create your project directory
mkdir my-app && cd my-app
git init

# 2. Run the init script
/path/to/swift-macos-starter/scripts/init-project.sh
```

The init script will:
- Auto-detect developer name, GitHub username, repo name
- Copy and customize all templates
- Optionally include License system and Sparkle auto-updates
- **Auto-generate Sparkle EdDSA keys** (if selected)
- **Auto-upload GitHub secrets** (if you choose)
- **Generate TODO.md** with remaining tasks for coding agents

## Complete Walkthrough

### Prerequisites
- macOS with Xcode installed
- Developer ID Application certificate in keychain
- GitHub CLI installed (`brew install gh`) and authenticated (`gh auth login`)
- Apple App-Specific Password (from appleid.apple.com)

### Step 1: Create Project Directory
```bash
mkdir my-cool-app
cd my-cool-app
git init
```

### Step 2: Run Init Script
```bash
/path/to/swift-macos-starter/scripts/init-project.sh
```

### Step 3: Interactive Prompts

```
=== Swift macOS Starter Kit - Project Initialization ===

Auto-detected values (press Enter to accept, or type to override):

App name [MyCoolApp]:                              # From directory name
GitHub username [yourname]:                        # From gh api user
Repository name [my-cool-app]:                     # From directory name
Bundle identifier [com.yourname.mycoolapp]:        # Constructed
Developer name [Your Name]:                        # From certificate
App description (one line): A cool macOS app

Creating project structure for: MyCoolApp
Copying templates...
  Created: MyCoolApp/App/AppDelegate.swift
  Created: MyCoolApp/App/StatusBarController.swift
  Created: MyCoolApp/Resources/Info.plist
  Created: MyCoolApp/MyCoolApp.entitlements
  Created: Package.swift
  Created: .github/workflows/build.yml
  Created: .github/workflows/release.yml

=== Optional Features ===

Include License system? (y/n): y
  Created: MyCoolApp/Services/LicenseManager.swift
  Created: MyCoolApp/Views/LicenseView.swift
  Created: MyCoolApp/Views/LicenseWindowController.swift
  Created: success.html
  License files copied.

Include Sparkle auto-updates? (y/n): y
  Created: appcast.xml
  Sparkle files copied.

=== Generating Sparkle EdDSA Keys ===

Downloading Sparkle tools to temp directory...
Generating EdDSA key pair...
  Public key:  YOUR_PUBLIC_KEY_HERE=
  Private key: [saved for GitHub secrets]

=== GitHub Secrets Setup ===

Note: The GitHub repository must exist before uploading secrets.
Create it at: https://github.com/new

Set up GitHub secrets now? (y/n): y
Warning: Repository yourname/my-cool-app does not exist on GitHub.
Create it now? (y/n): y
Creating repository...
Repository: yourname/my-cool-app

Apple ID (email): you@example.com
App-specific password: ****
Certificate export password: ****
Apple Team ID: ABC123XYZ

Finding Developer ID Application certificate...
Found: Developer ID Application: Your Name (ABC123XYZ)
Uploading secrets to GitHub...
  SPARKLE_PRIVATE_KEY uploaded

Secrets uploaded successfully!

Generating TODO.md...
  Created: TODO.md

=== Project initialization complete ===

Next step: Open TODO.md and complete the remaining tasks.
A coding agent like Claude can help you with these!
```

### Step 4: Complete TODO.md Tasks

The generated `TODO.md` contains all remaining tasks with exact file paths and values:

```markdown
# TODO - Project Setup Tasks

### 1. App Icon
- [ ] Change SF Symbol in scripts/generate-icon.swift line 24
- [ ] Run: swift scripts/generate-icon.swift && iconutil -c icns AppIcon.iconset

### 2. Sparkle Auto-Updates
- [x] EdDSA keys generated
- [ ] Add to Info.plist:
      <key>SUPublicEDKey</key>
      <string>YOUR_PUBLIC_KEY_HERE=</string>
- [ ] Uncomment Sparkle in Package.swift, AppDelegate.swift, StatusBarController.swift

### 3. License System
- [ ] Customize 12 keywords in LicenseManager.swift AND success.html (must match!)
- [ ] Set Stripe URL in LicenseView.swift
```

**Just tell Claude:** "Help me complete the tasks in TODO.md"

### Step 5: Create Xcode Project
1. File > New > Project > macOS > App
2. Product Name: `MyCoolApp`
3. Bundle Identifier: `com.yourname.mycoolapp`
4. Delete auto-generated `ContentView.swift` and `MyCoolAppApp.swift`
5. Drag files from `MyCoolApp/` folder into Xcode

### Step 6: First Release
```bash
git add .
git commit -m "Initial project setup"
git push -u origin main
git tag v1.0.0
git push --tags
```

GitHub Actions will automatically: Build → Sign → Notarize → Create DMG → Release

---

## What's Included

| Component | Description | Files |
|-----------|-------------|-------|
| **Core App** | Menu bar app template | `templates/App/` |
| **License System** | Weekly rotating keys + Stripe | `templates/License/` |
| **Sparkle Updates** | In-place auto-updates | `templates/Sparkle/` |
| **CI/CD** | Build, sign, notarize, release | `.github/workflows/` |
| **Scripts** | Secrets setup, icon generation | `scripts/` |

## Working with Coding Agents

After running `init-project.sh`, a `TODO.md` file is generated with remaining tasks.

Just tell Claude: **"Help me complete the tasks in TODO.md"** and it will:
- Know exactly what needs to be done
- Have all the file paths and line numbers
- Have the configuration values (like Sparkle public key) ready to use

## File Structure
```
MyApp/
├── Package.swift                 # SPM layer
├── MyApp.xcodeproj/              # Xcode layer
├── MyApp/
│   ├── App/                      # AppDelegate, StatusBarController
│   ├── Views/                    # UI (LicenseView, LicenseWindowController)
│   ├── Services/                 # Logic (LicenseManager)
│   └── Resources/                # Info.plist, assets
├── scripts/
│   ├── init-project.sh           # Initialize new project
│   ├── setup-secrets.sh          # Upload GitHub secrets
│   └── generate-icon.swift       # Generate app icon
├── appcast.xml                   # Sparkle update feed
├── success.html                  # License key page (post-purchase)
├── TODO.md                       # Tasks for coding agent
└── .github/workflows/
    ├── build.yml                 # CI (unsigned)
    └── release.yml               # Sign, notarize, release
```

## Placeholders

The init script auto-replaces these:

| Placeholder | Description | Auto-detected from |
|-------------|-------------|-------------------|
| `__APP_NAME__` | App name | Directory name (PascalCase) |
| `__BUNDLE_ID__` | Bundle identifier | Constructed from username + app |
| `__DEVELOPER_NAME__` | Certificate name | Keychain certificate |
| `__GITHUB_USER__` | GitHub username | `gh api user` |
| `__REPO_NAME__` | Repository name | Git remote or directory |

Manual placeholders (in TODO.md):
| Placeholder | Description |
|-------------|-------------|
| `__STRIPE_URL__` | Your Stripe checkout link |
| `__WEBSITE_URL__` | Your app's website |
| `__VALIDATION_CODE__` | License URL validation code |

## GitHub Secrets

These are uploaded automatically by the init script:

| Secret | Description |
|--------|-------------|
| `APPLE_CERTIFICATE_BASE64` | P12 certificate (base64) |
| `APPLE_CERTIFICATE_PASSWORD` | P12 password |
| `APPLE_TEAM_ID` | Apple Team ID |
| `APPLE_ID` | Apple ID email |
| `APPLE_APP_PASSWORD` | App-specific password |
| `SPARKLE_PRIVATE_KEY` | EdDSA private key (if Sparkle enabled) |

## License System

Weekly rotating license keys with Stripe integration. No server required.

### How It Works
1. User purchases via Stripe → redirected to `success.html?sid=cs_xxx&code=myapp`
2. Success page generates a 4-word license key based on current week
3. User pastes key in app → validated locally (current week + previous week)
4. License stored in UserDefaults permanently

### Token Rotation
- 12 keywords rotate in sliding window of 4
- Week 1: `WORD1-WORD2-WORD3-WORD4`
- Week 2: `WORD2-WORD3-WORD4-WORD5`
- Valid window: current week + previous week (2 weeks total)

### Stripe Configuration
Success URL: `https://yourapp.com/success.html?sid={CHECKOUT_SESSION_ID}&code=yourcode`

## Sparkle Auto-Update

In-place auto-updates that preserve user permissions.

### Why Sparkle?
- Updates in place — no re-download, permissions preserved
- EdDSA signed updates for security
- Automatic update checks on launch

### How It Works
1. Push tag → GitHub Action builds, signs, notarizes
2. DMG signed with EdDSA key
3. appcast.xml updated with new version info
4. App checks appcast.xml → prompts user to update

### Gotchas
- Sparkle binaries must be re-signed for notarization (handled in release.yml)
- appcast.xml must be served via HTTPS (GitHub Pages works)
- Build numbers must match between local and CI (use `git rev-list --count HEAD`)

## Architecture
- Three layers: Xcode + SPM + xcframework
- Package.swift for AI editing, Xcode for signing/release
- Always use `.xcframework`, never `.framework`

## Menu Bar App
- `LSUIElement: true` — No dock icon
- SF Symbol with `isTemplate = true`
- Sign frameworks first (inside-out)

## Entitlements
- Audio: `com.apple.security.device.audio-input`
- Accessibility: `com.apple.security.automation.apple-events`
- Network: `com.apple.security.network.client`

## Commands
```bash
swift build                              # Local build
git tag v1.0.0 && git push --tags        # Release
./scripts/setup-secrets.sh               # Upload certs (if not done in init)
swift scripts/generate-icon.swift        # Generate icon
iconutil -c icns AppIcon.iconset         # Convert to icns
```

## Gotchas
- Xcode ignores SPM `unsafeFlags` — use xcframework
- Notarize .app before creating DMG
- Hardened runtime required for notarization
- App-specific password for notarytool
