// android/app/build.gradle.kts
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.dbs.dateconverter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.dbs.dateconverter"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = 2
        versionName = "1.0.1"
    }

    // 🔑 تحميل بيانات التوقيع من key.properties
    signingConfigs {
        val keystoreProperties = Properties()
        val keystoreFile = rootProject.file("key.properties")

        if (keystoreFile.exists()) {
            FileInputStream(keystoreFile).use { fis ->
                keystoreProperties.load(fis)
            }
        }

        create("release") {
            storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
            storePassword = keystoreProperties.getProperty("storePassword")?.toString()
            keyAlias = keystoreProperties.getProperty("keyAlias")?.toString()
            keyPassword = keystoreProperties.getProperty("keyPassword")?.toString()
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")

            // ✅ تقليل الحجم
            isMinifyEnabled = true
            isShrinkResources = true

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }

        debug {
            // نستخدم نفس التوقيع حتى بالـ debug
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}