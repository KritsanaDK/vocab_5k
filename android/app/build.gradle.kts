import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.ksn.vocab_5k"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.ksn.vocab_5k"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = 2
        versionName = "1.0.0"
    }

    signingConfigs {
        create("release") {
            val keystoreFile = rootProject.file("key.properties")
            if (!keystoreFile.exists()) {
                throw GradleException("key.properties not found!")
            }

            val props = Properties()
            props.load(FileInputStream(keystoreFile))

            keyAlias = props.getProperty("keyAlias") ?: throw GradleException("keyAlias missing")
            keyPassword = props.getProperty("keyPassword") ?: throw GradleException("keyPassword missing")
            storePassword = props.getProperty("storePassword") ?: throw GradleException("storePassword missing")

            val storeFilePath = props.getProperty("storeFile")
                ?: throw GradleException("storeFile missing")
            storeFile = rootProject.file(storeFilePath)
            if (!storeFile!!.exists()) {
                throw GradleException("Keystore file not found at $storeFile")
            }

            println("Signing Config Loaded: $keyAlias -> $storeFile")
        }
    }


    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
