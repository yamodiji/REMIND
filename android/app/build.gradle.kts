import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load signing properties
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.yamodiji.reminder_app"
    compileSdk = 35

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.yamodiji.reminder_app"
        minSdk = 23  // Required for modern plugins
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Multi-dex support for large apps
        multiDexEnabled = true
        
        // Android 15 compatibility
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    // Signing configuration for release APKs
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias") ?: "androiddebugkey"
            keyPassword = keystoreProperties.getProperty("keyPassword") ?: "android"
            storeFile = file(keystoreProperties.getProperty("storeFile") ?: "debug-keystore.jks")
            storePassword = keystoreProperties.getProperty("storePassword") ?: "android"
        }
    }

    buildTypes {
        release {
            // Use signing config
            signingConfig = signingConfigs.getByName("release")
            
            // Release optimizations
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            
            // Android 15 compatibility flags
            manifestPlaceholders["enableBackupEncryption"] = "true"
        }
        debug {
            applicationIdSuffix = ".debug"
            isDebuggable = true
        }
    }

    // Android 15 packaging options
    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
            excludes += "/META-INF/versions/9/previous-compilation-data.bin"
        }
    }

    // Lint options for Android 15
    lint {
        checkReleaseBuilds = false
        abortOnError = false
        warningsAsErrors = false
    }

    // Split APKs by ABI for smaller downloads
    splits {
        abi {
            isEnable = true
            reset()
            include("arm64-v8a", "armeabi-v7a", "x86_64")
            isUniversalApk = true
        }
    }
}

dependencies {
    // Core library desugaring for Android 15
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    
    // Multi-dex support
    implementation("androidx.multidex:multidex:2.0.1")
    
    // Android 15 compatibility
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.activity:activity-ktx:1.9.1")
    implementation("androidx.fragment:fragment-ktx:1.8.2")
    
    // Testing
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.2.1")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.6.1")
}

flutter {
    source = "../.."
}
