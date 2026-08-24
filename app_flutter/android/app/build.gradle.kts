import java.util.Properties

// Credenciales de firma fuera del repo. Si el archivo no esta (CI sin
// secrets, o un clone recien hecho), el build de release cae a la firma de
// debug en vez de romper — asi `flutter run --release` sigue andando.
val propsFirma = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}
val hayFirma = propsFirma.getProperty("storeFile") != null

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.mirame.mirame"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Exigido por flutter_local_notifications: usa java.time, que no
        // existe en las versiones de Android que soporta minSdk. Sin esto el
        // build falla en :app:checkReleaseAarMetadata.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.mirame.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hayFirma) {
            create("release") {
                keyAlias = propsFirma.getProperty("keyAlias")
                keyPassword = propsFirma.getProperty("keyPassword")
                storeFile = rootProject.file(propsFirma.getProperty("storeFile"))
                storePassword = propsFirma.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName(if (hayFirma) "release" else "debug")
            // Sin shrink por ahora: R8 necesita reglas para los modelos de
            // Drift y los plugins de Firebase, y una regla faltante se
            // manifiesta recien en runtime en el APK de release.
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Version minima que pide flutter_local_notifications 22.x.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
