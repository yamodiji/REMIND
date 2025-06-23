# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Hive
-keep class hive.** { *; }
-keep class com.hivedb.** { *; }
-keep class * extends hive.HiveObject { *; }
-keepnames class * extends hive.HiveAdapter { *; }

# Notification plugins
-keep class com.dexterous.** { *; }
-keep class androidx.work.** { *; }

# Permission handler
-keep class com.baseflow.permissionhandler.** { *; }

# Android 15 compatibility
-keep class androidx.core.** { *; }
-keep class androidx.activity.** { *; }
-keep class androidx.fragment.** { *; }

# Keep model classes for Hive
-keep class com.yamodiji.reminder_app.models.** { *; }

# General Android rules
-keep class android.support.v7.widget.** { *; }
-keep class androidx.** { *; }

# Gson (if used)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.stream.** { *; }

# Remove debug logs in release
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# Keep crash reporting
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception 