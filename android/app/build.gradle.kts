import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties for release signing
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// Read APP_NAME from .env file
fun readAppNameFromEnv(): String {
    val envFile = rootProject.file("../.env")
    if (envFile.exists()) {
        envFile.readLines().forEach { line ->
            if (line.startsWith("APP_NAME=")) {
                val value = line.substringAfter("APP_NAME=").trim()
                // Remove surrounding quotes if present
                return value.trim('"', '\'')
            }
        }
    }
    return "Super App" // Default fallback
}

val appNameFromEnv = readAppNameFromEnv()

android {
    namespace = "id.carik.superapp_demo"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Enable core library desugaring for flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "id.carik.superapp_demo"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Required for flutter_local_notifications
        multiDexEnabled = true

        // Set app_name from .env APP_NAME value
        resValue("string", "app_name", appNameFromEnv)
    }

    signingConfigs {
        // Debug signing configuration - uses custom debug.keystore from keystores folder
        getByName("debug") {
            if (keystorePropertiesFile.exists() && keystoreProperties.containsKey("debugStoreFile")) {
                keyAlias = keystoreProperties["debugKeyAlias"] as String
                keyPassword = keystoreProperties["debugKeyPassword"] as String
                storeFile = rootProject.file(keystoreProperties["debugStoreFile"] as String)
                storePassword = keystoreProperties["debugStorePassword"] as String
            }
        }
        // Release signing configuration
        create("release") {
            if (keystorePropertiesFile.exists() && keystoreProperties.containsKey("storeFile")) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = rootProject.file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
        release {
            // Use release signing if key.properties exists, otherwise fallback to debug
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }

            // Enable R8 shrinking to reduce APK size
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    // Core library desugaring for Java 8+ APIs on older Android versions
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
