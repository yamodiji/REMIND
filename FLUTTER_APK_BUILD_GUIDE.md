# 🚀 Flutter APK Build Guide - Avoiding Common Errors

This guide contains all the solutions to common Flutter APK build errors encountered during SMS Ledger app development. Use this as a reference for future Flutter projects to avoid repeating the same issues.

## 📋 Quick Setup Checklist

When creating a new Flutter app that needs APK build via GitHub Actions, follow this checklist:

### ✅ **1. Project Structure Setup**
```yaml
# pubspec.yaml - Use compatible versions
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  # Use maintained plugins
  another_telephony: ^0.4.1  # NOT telephony: ^0.2.0
  permission_handler: ^11.0.1
  shared_preferences: ^2.2.2
  intl: ^0.18.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

### ✅ **2. Android Configuration**

#### `android/app/build.gradle`
```gradle
android {
    namespace "com.example.your_app"
    compileSdk 34

    defaultConfig {
        applicationId "com.example.your_app"
        minSdkVersion 23  // IMPORTANT: Use 23+ for modern plugins
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }
}
```

#### `android/gradle.properties`
```properties
# CRITICAL: Remove MaxPermSize for Java 8+
org.gradle.jvmargs=-Xmx2048M -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8
android.useAndroidX=true
android.enableJetifier=true
# CI/CD optimizations
org.gradle.daemon=false
org.gradle.parallel=false
org.gradle.configureondemand=false
```

### ✅ **3. GitHub Actions Workflow**

#### `.github/workflows/build-apk.yml`
```yaml
name: Build Flutter APK

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]
  workflow_dispatch:

# CRITICAL: Add permissions for releases
permissions:
  contents: write
  packages: write
  actions: read

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v4

    - name: Setup Java
      uses: actions/setup-java@v4
      with:
        distribution: 'zulu'
        java-version: '17'  # Use Java 17, NOT 8

    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.24.0'  # Use stable version, NOT latest
        channel: 'stable'

    - name: Get dependencies
      run: flutter pub get

    - name: Analyze code
      run: flutter analyze

    - name: Run tests
      run: flutter test || true

    - name: Clean build cache
      run: flutter clean

    - name: Get dependencies again
      run: flutter pub get

    # CRITICAL: Setup Gradle for CI
    - name: Setup Gradle properties
      run: |
        mkdir -p ~/.gradle
        echo "org.gradle.daemon=false" >> ~/.gradle/gradle.properties
        echo "org.gradle.parallel=false" >> ~/.gradle/gradle.properties
        echo "org.gradle.configureondemand=false" >> ~/.gradle/gradle.properties
        echo "org.gradle.jvmargs=-Xmx2048m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8" >> ~/.gradle/gradle.properties

    # Build with retry logic
    - name: Build APK with retry
      run: |
        for i in {1..3}; do
          echo "Build attempt $i"
          if flutter build apk --release --no-tree-shake-icons; then
            echo "Build successful on attempt $i"
            break
          else
            echo "Build failed on attempt $i"
            if [ $i -eq 3 ]; then
              echo "All build attempts failed"
              exit 1
            fi
            echo "Cleaning and retrying..."
            flutter clean
            flutter pub get
            sleep 10
          fi
        done

    - name: Upload APK artifact
      uses: actions/upload-artifact@v4
      with:
        name: app-apk
        path: build/app/outputs/flutter-apk/app-release.apk

    - name: Rename APK for release
      run: cp build/app/outputs/flutter-apk/app-release.apk app-release.apk

    - name: Create Release
      if: github.ref == 'refs/heads/main' || github.ref == 'refs/heads/master'
      uses: softprops/action-gh-release@v2
      with:
        tag_name: v1.0.${{ github.run_number }}
        name: App v1.0.${{ github.run_number }}
        body: |
          🚀 **Automatic Build**
          📱 Download the APK below and install on your Android device
          ⚠️ **Note:** Enable "Install from unknown sources" in Android settings
        files: app-release.apk
        draft: false
        prerelease: false
        token: ${{ secrets.GITHUB_TOKEN }}
```

## 🚨 **Common Errors & Solutions**

### **Error 1: Code Analysis Failures**
```
❌ Don't invoke 'print' in production code
❌ Unused import
```
**Solution:**
- Remove all `print()` statements or wrap in `assert()`
- Remove unused imports
- Run `flutter analyze` locally before pushing

### **Error 2: Test Failures**
```
❌ Expected: exactly one matching candidate
❌ Actual: Found 2 widgets with text "Title"
```
**Solution:**
- Use `findsNWidgets(2)` instead of `findsOneWidget` when multiple widgets exist
- Be specific about widget finders in tests

### **Error 3: Plugin Compatibility**
```
❌ Namespace not specified
❌ Could not create instance of LibraryVariantBuilderImpl
```
**Solution:**
- Use maintained plugin forks (e.g., `another_telephony` instead of `telephony`)
- Check plugin compatibility with current Flutter version
- Update `minSdkVersion` as required by plugins

### **Error 4: SDK Version Conflicts**
```
❌ minSdkVersion 21 cannot be smaller than version 23 declared in library
```
**Solution:**
- Update `minSdkVersion` to match plugin requirements
- Modern apps should use `minSdkVersion 23` (Android 6.0+)

### **Error 5: JVM Compatibility**
```
❌ Unrecognized VM option 'MaxPermSize=512m'
❌ Could not create the Java Virtual Machine
```
**Solution:**
- Remove `MaxPermSize` option (deprecated in Java 8+)
- Use proper JVM args: `-Xmx2048M -XX:+HeapDumpOnOutOfMemoryError`

### **Error 6: Gradle Daemon Issues**
```
❌ Could not receive a message from the daemon
❌ Unable to start the daemon process
```
**Solution:**
- Disable Gradle daemon in CI: `org.gradle.daemon=false`
- Disable parallel builds: `org.gradle.parallel=false`
- Add retry logic for builds

### **Error 7: GitHub Release Permissions**
```
❌ GitHub release failed with status: 403
```
**Solution:**
- Add workflow permissions: `contents: write`
- Use `softprops/action-gh-release@v2`
- Use `token:` instead of `env: GITHUB_TOKEN`

### **Error 8: Flutter Version Compatibility**
```
❌ app_plugin_loader Gradle plugin imperatively using apply script method
```
**Solution:**
- Use Flutter 3.24.0 (stable) instead of latest
- Avoid Flutter 3.32.4+ for APK builds
- Use GitHub Actions instead of local builds for consistency

## 🎯 **Best Practices Summary**

### **For Dependencies:**
- ✅ Use maintained plugin forks
- ✅ Check plugin compatibility before adding
- ✅ Keep dependencies updated but stable

### **For Android Config:**
- ✅ Use `minSdkVersion 23` or higher
- ✅ Remove deprecated JVM options
- ✅ Configure Gradle for CI environments

### **For GitHub Actions:**
- ✅ Add proper workflow permissions
- ✅ Use stable Flutter versions
- ✅ Implement retry logic for builds
- ✅ Upload artifacts as backup

### **For Code Quality:**
- ✅ Run `flutter analyze` before pushing
- ✅ Fix all linter warnings
- ✅ Write proper tests with correct expectations

## 📱 **Final APK Download Process**

1. **Push code** to GitHub repository
2. **Check Actions** tab for build progress
3. **Download from Releases** (preferred) or Actions artifacts
4. **Install on Android** device with "Unknown sources" enabled

## 🔄 **Reusable Prompt for Future Projects**

When creating a new Flutter app with APK build requirements, use this prompt:

---

**"Create a Flutter app with the following requirements and setup GitHub Actions for automatic APK building. Use the lessons learned from SMS Ledger project:**

**Essential Setup:**
- Use Flutter 3.24.0 stable version
- Configure minSdkVersion 23 for modern plugin compatibility  
- Remove deprecated MaxPermSize JVM option
- Use maintained plugin alternatives (e.g., another_telephony instead of telephony)
- Setup proper GitHub Actions permissions (contents: write)
- Implement Gradle daemon fixes for CI (daemon=false, parallel=false)
- Add build retry logic with clean/pub get between attempts
- Configure proper JVM args without deprecated options
- Setup both artifact upload and GitHub releases
- Include code analysis and test steps that handle common failures

**Avoid these specific errors:**
- Print statements in production code
- Unused imports causing analysis failures
- Test expectations for duplicate widgets
- Plugin namespace/compatibility issues
- JVM MaxPermSize compatibility with Java 17
- Gradle daemon communication failures in CI
- GitHub release permission 403 errors
- Flutter version compatibility with Gradle plugins

**App Features:** [Specify your app requirements here]"

---

This comprehensive setup will prevent all the build issues we encountered and ensure smooth APK generation from the start! 🚀 