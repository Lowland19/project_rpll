plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.project_rpll" // Sesuaikan ID aplikasi kamu
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.project_rpll"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // --- MULAI PERBAIKAN ---
        // Pastikan 'ndk' ada DI DALAM kurung kurawal 'defaultConfig'
        ndk {
            // Gunakan .add() agar aman di Kotlin
            abiFilters.add("armeabi-v7a")
            abiFilters.add("arm64-v8a")
            abiFilters.add("x86_64")
        }
        // --- SELESAI PERBAIKAN ---

    } // <--- Jangan lupa tutup kurung defaultConfig di sini (SETELAH ndk)

    buildTypes {
        release {
            // Matikan Obfuscation agar TFLite aman
            isMinifyEnabled = false
            isShrinkResources = false
            
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Matikan kompresi
    aaptOptions {
        noCompress("tflite")
        noCompress("lite")
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}