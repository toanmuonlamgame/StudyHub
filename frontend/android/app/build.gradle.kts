plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val studyHubTestAdMobAppId = "ca-app-pub-3940256099942544~3347511713"
val studyHubProductionAdMobAppId = providers.gradleProperty("STUDYHUB_ADMOB_APP_ID").orNull
val studyHubAdBuildMode = providers
    .gradleProperty("STUDYHUB_AD_BUILD_MODE")
    .getOrElse("disabled")

if (studyHubAdBuildMode !in setOf("disabled", "test", "production")) {
    throw GradleException("Unsupported STUDYHUB_AD_BUILD_MODE: $studyHubAdBuildMode")
}
if (studyHubAdBuildMode == "production" && studyHubProductionAdMobAppId.isNullOrBlank()) {
    throw GradleException(
        "Production advertising builds require -PSTUDYHUB_ADMOB_APP_ID."
    )
}

android {
    namespace = "com.toanmuonlamgame.studyhub"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.toanmuonlamgame.studyhub"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["studyHubAdMobAppId"] =
            if (studyHubAdBuildMode == "production") {
                studyHubProductionAdMobAppId!!
            } else {
                studyHubTestAdMobAppId
            }
    }

    buildTypes {
        release {
            // Local release-candidate builds only. Production distribution must
            // provide a private upload signing configuration outside Git.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
