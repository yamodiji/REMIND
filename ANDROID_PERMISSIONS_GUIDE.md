# Android Notification Permission Guide for Reminder App

## Understanding Permission Requests

If you're seeing permission requests for notifications or exact alarms, this is Android's protection feature to ensure apps only get the permissions they need for their core functionality.

## Why These Permissions Are Needed

The Reminder App requires specific permissions to function properly:
- **Notifications** - To show reminder alerts when they're due
- **Exact Alarms** - To trigger reminders at precise times (Android 12+)
- **Full Screen Intent** - To display call-screen style reminders

## How to Fix This Issue

### Method 1: Enable Restricted Settings (Recommended)

1. **Open your phone's Settings app**
2. **Navigate to Apps** (may be called "Application Manager" or "App Management")
3. **Find "SMS Ledger"** in the app list
4. **Tap on SMS Ledger**
5. **Look for "More" or three-dot menu** and tap it
6. **Select "Allow restricted settings"**
7. **Follow the on-screen instructions** - Android will explain the risks
8. **Confirm that you trust this app**
9. **Go back and grant SMS permission**

### Method 2: Through App Permissions

1. **Open Settings → Apps → SMS Ledger**
2. **Tap "Permissions"**
3. **Find "SMS" permission**
4. **If you see a warning about restricted settings, tap "Allow"**
5. **Grant the SMS permission**

### Method 3: From the App

1. **Open SMS Ledger app**
2. **When you see the permission dialog, tap "Open Settings"**
3. **Follow the steps above**
4. **Return to the app and refresh**

## What Happens If You Don't Grant Permission?

- The app will work with **demo/sample data**
- You'll see example transactions from banks like HDFC, ICICI, SBI, Axis
- All features work normally, but with fake data
- You can still test the app's functionality

## Is It Safe to Grant SMS Permission?

**Yes, for SMS Ledger it's safe because:**

✅ **Open Source**: The code is publicly available on GitHub  
✅ **Local Processing**: SMS data is processed only on your device  
✅ **No Data Upload**: Your SMS messages never leave your phone  
✅ **Read-Only**: The app only reads SMS, never sends or modifies them  
✅ **Bank Focus**: Only looks for transaction-related messages  
✅ **Transparent**: You can see exactly what data is being used  

## Troubleshooting

### Still Can't Grant Permission?

1. **Restart your phone** and try again
2. **Clear SMS Ledger app data**:
   - Settings → Apps → SMS Ledger → Storage → Clear Data
3. **Reinstall the app**
4. **Check if your phone has additional security apps** that might be blocking permissions

### Permission Keeps Getting Revoked?

Some phones have aggressive battery optimization that revokes permissions:

1. **Settings → Battery → Battery Optimization**
2. **Find SMS Ledger and set to "Don't optimize"**
3. **Or add SMS Ledger to "Protected apps" list**

### Different Android Versions

**Android 13+**: Follow the restricted settings method above  
**Android 11-12**: Regular permission grant should work  
**Android 10 and below**: Standard permission dialog  

## Alternative Solutions

If you absolutely cannot grant SMS permission:

1. **Use the app with demo data** to test functionality
2. **Manually add transactions** (if we add this feature in future updates)
3. **Export bank statements** and import them (future feature)

## Privacy Assurance

**What SMS Ledger does:**
- Reads SMS messages locally on your device
- Identifies bank transaction messages using keywords
- Extracts amount, date, and bank information
- Displays this in a clean interface

**What SMS Ledger does NOT do:**
- Send your SMS data to any server
- Store SMS content permanently
- Access non-financial SMS messages
- Share your data with third parties
- Require internet connection for SMS reading

## Need Help?

If you're still having issues:

1. **Check the app's permission status** in Settings → Apps → SMS Ledger → Permissions
2. **Look for any security apps** that might be interfering
3. **Try the app with demo data** to ensure it works properly
4. **Contact support** with your Android version and phone model

---

**Remember**: Android's restricted settings are there to protect you. Only grant SMS permission to apps you trust, and SMS Ledger is designed to be completely transparent about how it uses this permission. 