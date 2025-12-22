# Publishing to Google Play Store Guide

## Pre-Release Checklist

### App Configuration
- [ ] Update app name in `AndroidManifest.xml`
- [ ] Set unique package name (e.g., `com.yourcompany.appname`)
- [ ] Update version in `pubspec.yaml`
- [ ] Configure app icons (512x512 required for Play Store)
- [ ] Add splash screen
- [ ] Remove debug banner
- [ ] Test on multiple devices/screen sizes

### Code Quality
- [ ] Run `flutter analyze` - fix all issues
- [ ] Run `flutter test` - all tests pass
- [ ] Remove all `print()` statements
- [ ] Remove test/debug credentials
- [ ] Handle all error states

### Permissions
- [ ] Only request necessary permissions
- [ ] Add permission explanations in `AndroidManifest.xml`

---

## Version Configuration

### pubspec.yaml
```yaml
version: 1.0.0+1
# 1.0.0 = versionName (user visible)
# +1 = versionCode (must increment for each release)
```

### Increment for Updates
```yaml
# First release
version: 1.0.0+1

# Bug fix
version: 1.0.1+2

# New feature
version: 1.1.0+3

# Major update
version: 2.0.0+4
```

---

## App Signing

### 1. Create Upload Keystore
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

**⚠️ IMPORTANT**: Store keystore file and passwords securely. You cannot upload updates without it.

### 2. Create key.properties
Create `android/key.properties` (add to .gitignore):
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=upload
storeFile=/path/to/upload-keystore.jks
```

### 3. Configure Gradle
Edit `android/app/build.gradle`:

```groovy
// Add before android block
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ...existing config...

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

---

## Build Release

### App Bundle (Recommended)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### APK (Alternative)
```bash
# Split by architecture (smaller downloads)
flutter build apk --split-per-abi --release

# Or universal APK
flutter build apk --release
```

### With Obfuscation
```bash
flutter build appbundle --obfuscate --split-debug-info=build/debug-info
```
Keep `debug-info/` for crash report debugging.

---

## Google Play Console Setup

### 1. Create Developer Account
- Go to https://play.google.com/console
- Pay one-time $25 registration fee
- Complete identity verification

### 2. Create App
1. Click "Create app"
2. Enter app name
3. Select default language
4. Choose "App" or "Game"
5. Select "Free" or "Paid"
6. Accept policies

### 3. App Content (Required)
Complete these sections:

#### Privacy Policy
- Required for all apps
- Host on your website
- Must be publicly accessible

#### App Access
- Specify if app requires login
- Provide test credentials if needed

#### Ads
- Declare if app contains ads

#### Content Rating
- Complete questionnaire
- Receive age rating

#### Target Audience
- Select target age groups
- Affects content policies

#### News Apps
- Declare if news app

#### Data Safety
- Declare data collection practices
- Very important for user trust

### 4. Store Listing

#### Graphics
| Asset | Size | Format |
|-------|------|--------|
| App icon | 512x512 | PNG |
| Feature graphic | 1024x500 | PNG/JPEG |
| Phone screenshots | min 2, 320-3840px | PNG/JPEG |
| Tablet screenshots | optional, 7"+ | PNG/JPEG |

#### Description
- Short description: 80 characters
- Full description: 4000 characters
- Include keywords naturally

---

## Release Process

### 1. Upload to Testing Track (Recommended)
1. Go to "Testing" → "Internal testing"
2. Create new release
3. Upload `.aab` file
4. Add release notes
5. Save and review
6. Start rollout

### 2. Testing Tracks

| Track | Purpose | Testers |
|-------|---------|---------|
| Internal | Quick testing | Up to 100 |
| Closed | Beta testing | Invite-only |
| Open | Public beta | Anyone can join |
| Production | Live release | Everyone |

### 3. Promote to Production
After testing:
1. Go to "Production" → "Create new release"
2. Add from library (use tested bundle)
3. Add release notes
4. Review and rollout

### 4. Rollout Options
- **Staged rollout**: Start at 5-10%, gradually increase
- **Full rollout**: 100% immediately

---

## Post-Release

### Monitor
- Check crash reports in Play Console
- Monitor reviews and ratings
- Track install/uninstall metrics

### Update Process
1. Increment version code in `pubspec.yaml`
2. Build new app bundle
3. Upload to testing track
4. Test thoroughly
5. Promote to production

---

## Troubleshooting

### Common Issues

**"App not signed correctly"**
- Check key.properties paths
- Verify keystore password
- Ensure signing config in build.gradle

**"Version code already used"**
- Increment version code in pubspec.yaml

**"App rejected"**
- Review rejection email for specific policy
- Fix issues and resubmit

### Useful Commands
```bash
# Verify APK signing
apksigner verify --print-certs app-release.apk

# Check bundle
bundletool validate --bundle=app-release.aab

# Clean build
flutter clean && flutter pub get && flutter build appbundle
```

---

## CI/CD Integration

### GitHub Actions Example
```yaml
name: Build and Deploy

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - run: flutter pub get
      - run: flutter test
      - run: flutter build appbundle --release
      
      - uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.SERVICE_ACCOUNT_JSON }}
          packageName: com.yourcompany.appname
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: internal
```

### Codemagic (Flutter-focused CI/CD)
- https://codemagic.io
- GUI-based workflow builder
- Direct Play Store integration
- Free tier available

---

## Release Checklist Summary

- [ ] Version incremented
- [ ] App signed with release keystore
- [ ] App bundle built successfully
- [ ] Tested on physical device in release mode
- [ ] Store listing complete
- [ ] Privacy policy published
- [ ] Content rating completed
- [ ] Data safety form filled
- [ ] Screenshots uploaded
- [ ] Internal testing passed
- [ ] Production release submitted
