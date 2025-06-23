# 🔔 Reminder App - Call Screen Style Reminders

[![Build Flutter APK](https://github.com/yamodiji/REMIND/actions/workflows/build-apk.yml/badge.svg)](https://github.com/yamodiji/REMIND/actions/workflows/build-apk.yml)

A modern, interactive Flutter Reminder App that mimics an incoming call screen for reminders. Get reminded in style with a full-screen call-like interface that's impossible to miss!

## ✨ Features

- **📱 Call Screen Style Notifications** - Reminders appear as incoming call screens
- **🔄 Repeat Options** - Daily, weekly, monthly, and yearly repeats
- **⭐ Important Reminders** - Mark critical reminders with priority
- **😴 Snooze Functionality** - Snooze reminders for 5min, 10min, 30min, or 1 hour
- **🎨 Modern Material 3 UI** - Beautiful, responsive design
- **💾 Local Storage** - All data stored locally with Hive
- **🔔 Smart Permissions** - Handles Android 13+ notification permissions
- **🌙 Dark/Light Theme** - Automatic theme switching

## 📱 Screenshots

*Screenshots will be added after the app is built*

## 🚀 Download & Installation

### Method 1: Download from Releases (Recommended)
1. Go to [Releases](https://github.com/yamodiji/REMIND/releases)
2. Download the latest `reminder-app-release.apk`
3. Enable "Install from unknown sources" in Android settings
4. Install the APK
5. Grant notification permissions when prompted

### Method 2: Build from Source
```bash
git clone https://github.com/yamodiji/REMIND.git
cd REMIND/reminder_app
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
flutter build apk --release
```

## 🔧 Technical Details

- **Framework:** Flutter 3.24.0
- **State Management:** Provider
- **Local Storage:** Hive
- **Notifications:** Flutter Local Notifications
- **Permissions:** Permission Handler
- **UI:** Material 3 with Google Fonts
- **Animations:** Flutter Animate

## 📋 Permissions Required

- **Notifications** - Show reminder alerts
- **Schedule Exact Alarms** - Set precise reminder times
- **Vibration** - Vibrate on notifications
- **Boot Completed** - Restore reminders after device restart

## 🛠️ Development

This project uses GitHub Actions for automatic APK building. Every push to main/master triggers:
- Code analysis
- Test execution  
- APK building with retry logic
- Automatic release creation

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🆘 Support

If you encounter any issues:
1. Check the [Issues](https://github.com/yamodiji/REMIND/issues) page
2. Create a new issue with details about your problem
3. Include your Android version and device model

---

**Made with ❤️ by [yamodiji](https://github.com/yamodiji)**
