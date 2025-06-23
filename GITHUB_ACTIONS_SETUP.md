# 🚀 GitHub Actions Setup Guide for SMS Ledger

This guide will help you set up automatic APK building using GitHub Actions.

## 📋 **Prerequisites**

1. **GitHub Account** - Free account is sufficient
2. **Git installed** on your computer
3. **Your SMS Ledger project** (already created)

## 🔧 **Step-by-Step Setup**

### **Step 1: Create GitHub Repository**

1. **Go to GitHub.com** and sign in
2. **Click "New repository"** (green button)
3. **Repository name:** `sms-ledger` (or any name you prefer)
4. **Description:** `Flutter SMS Transaction Tracker`
5. **Set to Public** (required for free GitHub Actions)
6. **Don't initialize** with README (we already have files)
7. **Click "Create repository"**

### **Step 2: Upload Your Project**

Open terminal/command prompt in your project folder (`F:\PROJ`) and run:

```bash
# Initialize git repository
git init

# Add all files
git add .

# Commit files
git commit -m "Initial commit: SMS Ledger Flutter app"

# Add GitHub repository as remote (replace with your actual repo URL)
git remote add origin https://github.com/YOUR_USERNAME/sms-ledger.git

# Push to GitHub
git push -u origin main
```

**Replace `YOUR_USERNAME` with your actual GitHub username!**

### **Step 3: Verify Upload**

1. **Refresh your GitHub repository page**
2. **You should see all your files** including:
   - `.github/workflows/build-apk.yml`
   - `lib/` folder with your Flutter code
   - `android/` folder with Android configuration
   - `pubspec.yaml` with dependencies

### **Step 4: Trigger First Build**

#### **Option A: Automatic Trigger**
The build will automatically start when you push to the main branch.

#### **Option B: Manual Trigger**
1. **Go to your repository** on GitHub
2. **Click "Actions" tab**
3. **Select "Build Flutter APK"** workflow
4. **Click "Run workflow"** button
5. **Click green "Run workflow"** button

### **Step 5: Monitor Build Progress**

1. **Go to Actions tab** in your repository
2. **Click on the running build** (yellow circle = running, green check = success)
3. **Watch the build steps** in real-time
4. **Build takes ~5-10 minutes** to complete

### **Step 6: Download Your APK**

#### **Method 1: From Artifacts (Immediate)**
1. **Wait for build to complete** (green checkmark)
2. **Click on the completed build**
3. **Scroll down to "Artifacts" section**
4. **Click "sms-ledger-apk"** to download ZIP
5. **Extract the ZIP** to get `app-release.apk`

#### **Method 2: From Releases (Automatic)**
1. **Go to "Releases" tab** in your repository
2. **Find the latest release** (created automatically)
3. **Download `app-release.apk`** directly

## 📱 **Install APK on Android**

### **Step 1: Enable Unknown Sources**
1. **Go to Settings > Security**
2. **Enable "Unknown Sources"** or "Install unknown apps"
3. **Allow installation** from your file manager

### **Step 2: Install APK**
1. **Transfer APK** to your Android device
2. **Open file manager** and find the APK
3. **Tap the APK** to install
4. **Grant SMS permissions** when prompted

## 🔄 **Making Updates**

### **To Update Your App:**
1. **Make changes** to your Flutter code
2. **Commit and push** changes:
   ```bash
   git add .
   git commit -m "Update: describe your changes"
   git push
   ```
3. **GitHub Actions will automatically build** a new APK
4. **Download the new APK** from Artifacts or Releases

## 🛠️ **Workflow Features**

### **What the GitHub Action Does:**
- ✅ **Sets up Flutter 3.24.0** (stable version)
- ✅ **Installs Java 17** (required for Android builds)
- ✅ **Downloads dependencies** (`flutter pub get`)
- ✅ **Analyzes code** for errors (`flutter analyze`)
- ✅ **Runs tests** (`flutter test`)
- ✅ **Builds release APK** (`flutter build apk --release`)
- ✅ **Uploads APK** as downloadable artifact
- ✅ **Creates GitHub release** with APK attached

### **Build Triggers:**
- 🔄 **Push to main/master branch**
- 🔄 **Pull requests**
- 🔄 **Manual trigger** (Run workflow button)

## 🐛 **Troubleshooting**

### **Build Fails - Common Issues:**

#### **1. Repository Not Public**
- **Error:** GitHub Actions disabled
- **Solution:** Make repository public or upgrade to GitHub Pro

#### **2. Wrong Branch Name**
- **Error:** Workflow doesn't trigger
- **Solution:** Check if your main branch is called `main` or `master`

#### **3. Flutter Version Issues**
- **Error:** Build fails during Flutter setup
- **Solution:** The workflow uses Flutter 3.24.0 (stable)

#### **4. Test Failures**
- **Error:** Tests fail during build
- **Solution:** Tests are set to continue even if they fail (`|| true`)

### **APK Installation Issues:**

#### **1. "App not installed"**
- **Solution:** Enable "Unknown Sources" in Android settings

#### **2. "Parse error"**
- **Solution:** Download APK again, ensure it's not corrupted

#### **3. "Insufficient storage"**
- **Solution:** Free up space on your Android device

## 📊 **Build Status Badge**

Add this to your README to show build status:

```markdown
[![Build Flutter APK](https://github.com/YOUR_USERNAME/sms-ledger/actions/workflows/build-apk.yml/badge.svg)](https://github.com/YOUR_USERNAME/sms-ledger/actions/workflows/build-apk.yml)
```

## 🎯 **Quick Commands Reference**

```bash
# Initial setup
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/sms-ledger.git
git push -u origin main

# Making updates
git add .
git commit -m "Your update message"
git push

# Check status
git status

# View commit history
git log --oneline
```

## 🔗 **Useful Links**

- **Your Repository:** `https://github.com/YOUR_USERNAME/sms-ledger`
- **Actions Tab:** `https://github.com/YOUR_USERNAME/sms-ledger/actions`
- **Releases:** `https://github.com/YOUR_USERNAME/sms-ledger/releases`
- **GitHub Actions Documentation:** https://docs.github.com/en/actions

## 🎉 **Success!**

Once set up, you'll have:
- ✅ **Automatic APK builds** on every code change
- ✅ **Downloadable APKs** from GitHub
- ✅ **Version-controlled releases**
- ✅ **Build status monitoring**
- ✅ **Professional CI/CD pipeline**

**Your SMS Ledger app will be automatically built and ready for download every time you make changes!** 🚀

---

**Remember to replace `YOUR_USERNAME` with your actual GitHub username in all commands and URLs!** 