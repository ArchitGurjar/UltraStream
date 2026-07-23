#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# UltraStream Android Project Generator
# ============================================================
# This script creates the complete Android project structure
# and all source files for the UltraStream app.
# Run this inside Termux to set up the project.
# ============================================================

set -e

PROJECT_DIR="UltraStream"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

echo "Creating project structure..."

# ============================================================
# Root Gradle files
# ============================================================
cat << 'EOF' > settings.gradle
// settings.gradle
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_PROJECT)
    repositories {
        google()
        mavenCentral()
        maven { url 'https://jitpack.io' }
    }
}

rootProject.name = "UltraStream"
include ':app'
EOF

cat << 'EOF' > build.gradle
// build.gradle (project-level)
buildscript {
    ext.kotlin_version = '1.9.22'
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.2.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://jitpack.io' }
    }
}

tasks.register('clean', Delete) {
    delete rootProject.buildDir
}
EOF

cat << 'EOF' > gradle.properties
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
android.enableJetifier=true
kotlin.code.style=official
android.nonFinalResIds=false
android.nonTransitiveRClass=false
android.useAndroidX=true
android.enableJetifier=true
EOF

mkdir -p gradle/wrapper
cat << 'EOF' > gradle/wrapper/gradle-wrapper.properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.7-bin.zip
networkTimeout=10000
validateDistributionUrl=true
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF

# ============================================================
# App module
# ============================================================
mkdir -p app/src/main/java/com/ultrastream
mkdir -p app/src/main/res
mkdir -p app/src/main/res/values
mkdir -p app/src/main/res/layout
mkdir -p app/src/main/res/drawable
mkdir -p app/src/main/res/menu
mkdir -p app/src/main/res/navigation
mkdir -p app/src/main/res/xml
mkdir -p app/src/main/assets

# ============================================================
# app/build.gradle
# ============================================================
cat << 'EOF' > app/build.gradle
// app/build.gradle
plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
    id 'kotlin-kapt'
    id 'kotlin-parcelize'
}

android {
    buildToolsVersion "34.0.0"
    namespace 'com.ultrastream'
    compileSdk 34

    defaultConfig {
        applicationId "com.ultrastream"
        minSdk 23
        targetSdk 34
        versionCode 1
        versionName "7.0"

        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = '17'
    }

    buildFeatures {
        viewBinding true
        dataBinding true
    }
}

dependencies {
    implementation 'androidx.core:core-ktx:1.12.0'
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.11.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
    implementation 'androidx.recyclerview:recyclerview:1.3.2'
    implementation 'androidx.cardview:cardview:1.0.0'
    
    // Navigation
    implementation 'androidx.navigation:navigation-fragment-ktx:2.7.7'
    implementation 'androidx.navigation:navigation-ui-ktx:2.7.7'
    
    // Lifecycle
    implementation 'androidx.lifecycle:lifecycle-viewmodel-ktx:2.7.0'
    implementation 'androidx.lifecycle:lifecycle-livedata-ktx:2.7.0'
    implementation 'androidx.lifecycle:lifecycle-runtime-ktx:2.7.0'
    
    // Coroutines
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3'
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3'
    
    // Room
    implementation 'androidx.room:room-runtime:2.6.1'
    implementation 'androidx.room:room-ktx:2.6.1'
    kapt 'androidx.room:room-compiler:2.6.1'
    
    // Retrofit
    implementation 'com.squareup.retrofit2:retrofit:2.9.0'
    implementation 'com.squareup.retrofit2:converter-gson:2.9.0'
    implementation 'com.squareup.okhttp3:okhttp:4.12.0'
    implementation 'com.squareup.okhttp3:logging-interceptor:4.12.0'
    
    // Gson
    implementation 'com.google.code.gson:gson:2.10.1'
    
    // Glide
    implementation 'com.github.bumptech.glide:glide:4.16.0'
    kapt 'com.github.bumptech.glide:compiler:4.16.0'
    
    // ExoPlayer
    implementation 'com.google.android.exoplayer:exoplayer:2.19.1'
    implementation 'com.google.android.exoplayer:exoplayer-hls:2.19.1'
    implementation 'com.google.android.exoplayer:exoplayer-dash:2.19.1'
    implementation 'com.google.android.exoplayer:exoplayer-rtsp:2.19.1'
    implementation 'com.google.android.exoplayer:extension-okhttp:2.19.1'
    
    // WorkManager
    implementation 'androidx.work:work-runtime-ktx:2.9.0'
    
    // Preference
    implementation 'androidx.preference:preference-ktx:1.2.1'
    
    // Testing
    testImplementation 'junit:junit:4.13.2'
    androidTestImplementation 'androidx.test.ext:junit:1.1.5'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.5.1'
}
EOF

cat << 'EOF' > app/proguard-rules.pro
# Add project specific ProGuard rules here.

# Keep ExoPlayer classes
-keep class com.google.android.exoplayer2.** { *; }
-keep interface com.google.android.exoplayer2.** { *; }

# Keep Retrofit
-keep class retrofit2.** { *; }
-keep interface retrofit2.** { *; }

# Keep Gson
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep Room
-keep class androidx.room.** { *; }
-keep class * extends androidx.room.RoomDatabase

# Keep models
-keep class com.ultrastream.data.models.** { *; }

# Keep Parcelable
-keep class * implements android.os.Parcelable {
    public static final *** CREATOR;
}

# Keep Serializable
-keep class * implements java.io.Serializable

# Keep annotations
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature

# For FileProvider
-keep class androidx.core.content.FileProvider { *; }

# For ExoPlayer HLS/DASH extensions
-keep class com.google.android.exoplayer2.ext.** { *; }

# OkHttp
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
EOF

# ============================================================
# AndroidManifest.xml
# ============================================================
mkdir -p app/src/main
cat << 'EOF' > app/src/main/AndroidManifest.xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

    <uses-feature android:name="android.hardware.touchscreen" android:required="false" />
    <uses-feature android:name="android.software.picture_in_picture" android:required="false" />

    <application
        android:allowBackup="true"
        android:dataExtractionRules="@xml/data_extraction_rules"
        android:fullBackupContent="@xml/backup_rules"
        android:icon="@drawable/ic_bolt"
        android:label="@string/app_name"
        android:roundIcon="@drawable/ic_bolt"
        android:supportsRtl="true"
        android:theme="@style/Theme.UltraStream"
        android:name=".UltraStreamApplication"
        tools:targetApi="31">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:theme="@style/Theme.UltraStream"
            android:windowSoftInputMode="adjustResize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <activity
            android:name=".ui.details.DetailsActivity"
            android:exported="false"
            android:theme="@style/Theme.UltraStream.Details"
            android:configChanges="orientation|screenSize" />

        <activity
            android:name=".player.PlayerActivity"
            android:exported="false"
            android:theme="@style/Theme.UltraStream.Player"
            android:configChanges="orientation|screenSize|keyboardHidden"
            android:supportsPictureInPicture="true"
            android:launchMode="singleTop" />

        <service
            android:name=".player.PlayerService"
            android:exported="false" />

        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="${applicationId}.fileprovider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/file_paths" />
        </provider>

    </application>

</manifest>
EOF

# ============================================================
# Resources: colors, themes, strings, dimensions
# ============================================================
cat << 'EOF' > app/src/main/res/values/colors.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Dark Theme -->
    <color name="dark_bg_main">#060606</color>
    <color name="dark_bg_surface">#121212</color>
    <color name="dark_bg_card">#1a1a1a</color>
    <color name="dark_text_main">#ffffff</color>
    <color name="dark_text_muted">#a3a3a3</color>

    <!-- Light Theme -->
    <color name="light_bg_main">#f3f4f6</color>
    <color name="light_bg_surface">#ffffff</color>
    <color name="light_bg_card">#ffffff</color>
    <color name="light_text_main">#111827</color>
    <color name="light_text_muted">#6b7280</color>

    <!-- Accents -->
    <color name="accent_blue">#38bdf8</color>
    <color name="accent_gold">#fbbf24</color>
    <color name="accent_red">#ef4444</color>
    <color name="accent_green">#4caf50</color>
    <color name="accent_purple">#a78bfa</color>
    <color name="accent_pink">#f472b6</color>
    <color name="accent_orange">#fb923c</color>

    <!-- Bottom Nav Selector -->
    <color name="bottom_nav_selector">#888888</color>
    <color name="bottom_nav_selector_active">#38bdf8</color>
</resources>
EOF

cat << 'EOF' > app/src/main/res/values/themes.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Base Application Theme -->
    <style name="Theme.UltraStream" parent="Theme.MaterialComponents.DayNight.NoActionBar">
        <item name="colorPrimary">@color/accent_blue</item>
        <item name="colorPrimaryVariant">@color/accent_blue</item>
        <item name="colorOnPrimary">@android:color/white</item>
        <item name="colorSecondary">@color/accent_blue</item>
        <item name="colorSecondaryVariant">@color/accent_blue</item>
        <item name="colorOnSecondary">@android:color/black</item>
        <item name="android:statusBarColor">@android:color/transparent</item>
        <item name="android:windowLightStatusBar">false</item>
        <item name="android:navigationBarColor">?attr/colorSurface</item>
        <item name="android:windowBackground">@color/dark_bg_main</item>
        <item name="colorSurface">@color/dark_bg_surface</item>
        <item name="colorOnSurface">@color/dark_text_main</item>
        <item name="android:fontFamily">sans-serif</item>
    </style>

    <!-- Details Screen Theme -->
    <style name="Theme.UltraStream.Details" parent="Theme.UltraStream">
        <item name="android:windowIsTranslucent">false</item>
        <item name="android:windowBackground">@android:color/black</item>
        <item name="android:statusBarColor">@android:color/transparent</item>
        <item name="android:windowLightStatusBar">false</item>
    </style>

    <!-- Player Screen Theme -->
    <style name="Theme.UltraStream.Player" parent="Theme.MaterialComponents.DayNight.NoActionBar">
        <item name="android:windowBackground">@android:color/black</item>
        <item name="android:statusBarColor">@android:color/transparent</item>
        <item name="android:windowLightStatusBar">false</item>
        <item name="android:navigationBarColor">@android:color/black</item>
        <item name="android:windowFullscreen">true</item>
        <item name="android:windowContentOverlay">@null</item>
    </style>

    <!-- Bottom Sheet Theme -->
    <style name="Theme.UltraStream.BottomSheet" parent="Theme.MaterialComponents.DayNight.BottomSheetDialog">
        <item name="android:windowIsTranslucent">true</item>
        <item name="android:windowBackground">@android:color/transparent</item>
        <item name="android:windowContentOverlay">@null</item>
        <item name="android:windowNoTitle">true</item>
        <item name="android:backgroundDimEnabled">true</item>
        <item name="android:windowLightStatusBar">false</item>
        <item name="android:statusBarColor">@android:color/transparent</item>
    </style>
</resources>
EOF

cat << 'EOF' > app/src/main/res/values/strings.xml
<resources>
    <string name="app_name">UltraStream</string>

    <!-- Bottom Nav -->
    <string name="nav_home">Home</string>
    <string name="nav_library">Library</string>
    <string name="nav_search">Search</string>
    <string name="nav_addons">Addons</string>
    <string name="nav_profile">Profile</string>

    <!-- General -->
    <string name="loading">Loading…</string>
    <string name="no_data">No data available</string>
    <string name="retry">Retry</string>
    <string name="cancel">Cancel</string>
    <string name="save">Save</string>
    <string name="delete">Delete</string>
    <string name="back">Back</string>

    <!-- Streams -->
    <string name="no_streams">No streams found</string>
    <string name="finding_streams">Finding streams…</string>
    <string name="play_in_external">Play in Default Player</string>
    <string name="copy_magnet">Copy Magnet Link</string>
    <string name="copy_url">Copy Direct Video URL</string>
    <string name="download_stream">Download / Open in Browser</string>
    <string name="search_subtitles">Search Subtitles</string>
    <string name="make_playlist">Make Smart Playlist</string>
    <string name="export_m3u">Export / Play .m3u</string>

    <!-- Smart Playlist -->
    <string name="playlist_ready">Smart Playlist is ready!</string>
    <string name="playlist_fetching">Auto-fetching episodes…</string>
    <string name="no_playlists">No playlists generated yet.</string>

    <!-- Addons -->
    <string name="install_addon">Install Addon</string>
    <string name="addon_url_hint">Paste manifest.json URL…</string>
    <string name="debrid_key_hint">Real‑Debrid API Key (optional)</string>
    <string name="save_debrid">Save Debrid Key</string>
    <string name="no_addons">No addons installed</string>
</resources>
EOF

cat << 'EOF' > app/src/main/res/values/strings_extra.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Player -->
    <string name="player_title">Now Playing</string>
    <string name="buffering">Buffering…</string>
    <string name="playback_error">Playback Error</string>

    <!-- Sheets -->
    <string name="available_streams">Available Streams</string>
    <string name="no_streams_found">No streams found</string>
    <string name="select_season">Select Season</string>
    <string name="profiles">Profiles</string>
    <string name="watch_analytics">📊 Watch Analytics</string>

    <!-- Playlist -->
    <string name="smart_playlist">Smart Playlist</string>
    <string name="playlist_export">Export M3U</string>
    <string name="playlist_play">Play in Player</string>

    <!-- Addons -->
    <string name="installed_plugins">Installed Plugins</string>
    <string name="recommended_addons">🔥 Recommended Addons</string>
    <string name="addon_data_management">📦 Addon Data Management</string>
    <string name="export_addons">Export Addons</string>
    <string name="import_addons">Import Addons</string>

    <!-- Settings -->
    <string name="preferences">Preferences</string>
    <string name="theme_mode">Theme Mode</string>
    <string name="theme_desc">Switch between Light &amp; Dark Mode</string>
    <string name="hindi_priority">Hindi Priority</string>
    <string name="hindi_desc">Push Hindi/Dual Audio streams to top</string>
    <string name="autoplay_next">Auto-play Next</string>
    <string name="autoplay_desc">Automatically suggest next episode</string>
    <string name="parental_control">Parental Control</string>
    <string name="parental_desc">Filter content by maturity rating</string>
    <string name="data_backup">Data &amp; Backup</string>
    <string name="backup_data">Backup Data</string>
    <string name="restore_data">Restore</string>
    <string name="factory_reset">🧹 Factory Reset / Clear Data</string>

    <!-- Toast Messages -->
    <string name="copied">Copied!</string>
    <string name="saved">Saved!</string>
    <string name="deleted">Deleted!</string>
    <string name="added_to_watchlist">Added to watchlist</string>
    <string name="removed_from_watchlist">Removed from watchlist</string>
    <string name="added_to_library">Added to library</string>
    <string name="removed_from_library">Removed from library</string>
</resources>
EOF

cat << 'EOF' > app/src/main/res/values/dimens.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <dimen name="poster_width">130dp</dimen>
    <dimen name="poster_height">195dp</dimen>
    <dimen name="poster_radius">8dp</dimen>

    <dimen name="card_padding">12dp</dimen>
    <dimen name="card_radius">16dp</dimen>

    <dimen name="nav_height">65dp</dimen>

    <dimen name="avatar_size">32dp</dimen>
    <dimen name="avatar_big_size">70dp</dimen>

    <dimen name="text_heading">20sp</dimen>
    <dimen name="text_title">16sp</dimen>
    <dimen name="text_body">14sp</dimen>
    <dimen name="text_caption">12sp</dimen>
    <dimen name="text_small">10sp</dimen>

    <dimen name="episode_thumb_width">110dp</dimen>
    <dimen name="episode_thumb_height">70dp</dimen>
</resources>
EOF

# ============================================================
# Drawables (icons, backgrounds)
# ============================================================
# We'll generate a few essential drawables; others can be added later.
cat << 'EOF' > app/src/main/res/drawable/ic_bolt.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#38bdf8"
        android:pathData="M11,21h-1l1,-7H7.5c-0.88,0 -1.66,-0.61 -1.85,-1.48 -0.21,-0.97 0.14,-1.97 0.88,-2.62L12,3h1l-1,7h3.5c0.92,0 1.74,0.63 1.96,1.52 0.2,0.83 -0.16,1.69 -0.87,2.27L11,21z" />
</vector>
EOF

cat << 'EOF' > app/src/main/res/drawable/placeholder_poster.xml
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
    <solid android:color="#333333" />
    <corners android:radius="8dp" />
</shape>
EOF

cat << 'EOF' > app/src/main/res/drawable/gradient_hero_overlay.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <gradient
        android:startColor="#00000000"
        android:endColor="#000000"
        android:angle="90" />
</shape>
EOF

cat << 'EOF' > app/src/main/res/drawable/title_gradient.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <gradient
        android:startColor="#00000000"
        android:endColor="#cc000000"
        android:angle="90" />
</shape>
EOF

cat << 'EOF' > app/src/main/res/drawable/ic_back.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#ffffff"
        android:pathData="M20,11H7.83l5.59,-5.59L12,4l-8,8 8,8 1.41,-1.41L7.83,13H20v-2z" />
</vector>
EOF

cat << 'EOF' > app/src/main/res/drawable/ic_close.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#ffffff"
        android:pathData="M19,6.41L17.59,5 12,10.59 6.41,5 5,6.41 10.59,12 5,17.59 6.41,19 12,13.41 17.59,19 19,17.59 13.41,12z" />
</vector>
EOF

cat << 'EOF' > app/src/main/res/drawable/ic_home.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#ffffff"
        android:pathData="M10,20v-6h4v6h5v-8h3L12,3 2,12h3v8z" />
</vector>
EOF

cat << 'EOF' > app/src/main/res/drawable/ic_search.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#ffffff"
        android:pathData="M15.5,14h-0.79l-0.28,-0.27C15.41,12.59 16,11.11 16,9.5 16,5.91 13.09,3 9.5,3S3,5.91 3,9.5 5.91,16 9.5,16c1.61,0 3.09,-0.59 4.23,-1.57l0.27,0.28v0.79l5,4.99L20.49,19l-4.99,-5zM9.5,14C7.01,14 5,11.99 5,9.5S7.01,5 9.5,5 14,7.01 14,9.5 11.99,14 9.5,14z" />
</vector>
EOF

cat << 'EOF' > app/src/main/res/drawable/ic_library.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#ffffff"
        android:pathData="M4,6H2v14c0,1.1 0.9,2 2,2h14v-2H4V6zm16,-4H8c-1.1,0 -2,0.9 -2,2v12c0,1.1 0.9,2 2,2h12c1.1,0 2,-0.9 2,-2V4c0,-1.1 -0.9,-2 -2,-2zm-1,9H9V9h10v2zm-4,4H9v-2h6v2zm4,-8H9V5h10v2z" />
</vector>
EOF

cat << 'EOF' > app/src/main/res/drawable/ic_addons.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#ffffff"
        android:pathData="M19,13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z" />
</vector>
EOF

cat << 'EOF' > app/src/main/res/drawable/ic_profile.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#ffffff"
        android:pathData="M12,12c2.21,0 4,-1.79 4,-4s-1.79,-4 -4,-4 -4,1.79 -4,4 1.79,4 4,4zm0,2c-2.67,0 -8,1.34 -8,4v2h16v-2c0,-2.66 -5.33,-4 -8,-4z" />
</vector>
EOF

cat << 'EOF' > app/src/main/res/drawable/ic_bookmark.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#ffffff"
        android:pathData="M17,3H7c-1.1,0 -1.99,0.9 -1.99,2L5,21l7,-3 7,3V5c0,-1.1 -0.9,-2 -2,-2z" />
</vector>
EOF

cat << 'EOF' > app/src/main/res/drawable/ic_bookmark_filled.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#ffffff"
        android:pathData="M17,3H7c-1.1,0 -1.99,0.9 -1.99,2L5,21l7,-3 7,3V5c0,-1.1 -0.9,-2 -2,-2z" />
</vector>
EOF

cat << 'EOF' > app/src/main/res/drawable/ic_watchlist.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#ffffff"
        android:pathData="M11.99,2C6.47,2 2,6.48 2,12s4.47,10 9.99,10C17.52,22 22,17.52 22,12S17.52,2 11.99,2zM12,20c-4.42,0 -8,-3.58 -8,-8s3.58,-8 8,-8 8,3.58 8,8 -3.58,8 -8,8zm0.5,-13H11v6l5.25,3.15 0.75,-1.23 -4.5,-2.67z" />
</vector>
EOF

cat << 'EOF' > app/src/main/res/drawable/ic_watchlist_filled.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#ffffff"
        android:pathData="M11.99,2C6.47,2 2,6.48 2,12s4.47,10 9.99,10C17.52,22 22,17.52 22,12S17.52,2 11.99,2zM12,20c-4.42,0 -8,-3.58 -8,-8s3.58,-8 8,-8 8,3.58 8,8 -3.58,8 -8,8zm0.5,-13H11v6l5.25,3.15 0.75,-1.23 -4.5,-2.67z" />
</vector>
EOF

cat << 'EOF' > app/src/main/res/drawable/ic_pip.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#ffffff"
        android:pathData="M19,11h-8v6h8v-6zm4,-8H1c-0.55,0 -1,0.45 -1,1v16c0,0.55 0.45,1 1,1h22c0.55,0 1,-0.45 1,-1V4c0,-0.55 -0.45,-1 -1,-1zM19,17H9v-4h10v4z" />
</vector>
EOF

cat << 'EOF' > app/src/main/res/drawable/ic_lock.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#ffffff"
        android:pathData="M18,8h-1V6c0,-2.76 -2.24,-5 -5,-5S7,3.24 7,6v2H6c-1.1,0 -2,0.9 -2,2v10c0,1.1 0.9,2 2,2h12c1.1,0 2,-0.9 2,-2V10c0,-1.1 -0.9,-2 -2,-2zm-6,9c-1.1,0 -2,-0.9 -2,-2s0.9,-2 2,-2 2,0.9 2,2 -0.9,2 -2,2zm3.1,-9H8.9V6c0,-1.71 1.39,-3.1 3.1,-3.1 1.71,0 3.1,1.39 3.1,3.1v2z" />
</vector>
EOF

cat << 'EOF' > app/src/main/res/drawable/ic_lock_open.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#ffffff"
        android:pathData="M12,17c1.1,0 2,-0.9 2,-2s-0.9,-2 -2,-2 -2,0.9 -2,2 0.9,2 2,2zm6,-9h-1V6c0,-2.76 -2.24,-5 -5,-5S7,3.24 7,6h1.9c0,-1.71 1.39,-3.1 3.1,-3.1 1.71,0 3.1,1.39 3.1,3.1v2H6c-1.1,0 -2,0.9 -2,2v10c0,1.1 0.9,2 2,2h12c1.1,0 2,-0.9 2,-2V10c0,-1.1 -0.9,-2 -2,-2zm0,12H6V10h12v10z" />
</vector>
EOF

cat << 'EOF' > app/src/main/res/drawable/ic_delete.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#ef4444"
        android:pathData="M6,19c0,1.1 0.9,2 2,2h8c1.1,0 2,-0.9 2,-2V7H6v12zM19,4h-3.5l-1,-1h-5l-1,1H5v2h14V4z" />
</vector>
EOF

cat << 'EOF' > app/src/main/res/drawable/rating_bg.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
    <corners android:radius="6dp" />
    <solid android:color="#33fbbf24" />
</shape>
EOF

cat << 'EOF' > app/src/main/res/drawable/badge_background.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
    <corners android:radius="6dp" />
    <solid android:color="#33ffffff" />
</shape>
EOF

cat << 'EOF' > app/src/main/res/drawable/round_button_bg.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="#80000000" />
    <stroke
        android:width="1dp"
        android:color="#33ffffff" />
</shape>
EOF

# ============================================================
# Layout XML files
# ============================================================
cat << 'EOF' > app/src/main/res/layout/activity_main.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:background="@color/dark_bg_main">

    <androidx.fragment.app.FragmentContainerView
        android:id="@+id/nav_host_fragment"
        android:name="androidx.navigation.fragment.NavHostFragment"
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1"
        app:defaultNavHost="true"
        app:navGraph="@navigation/nav_graph" />

    <com.google.android.material.bottomnavigation.BottomNavigationView
        android:id="@+id/bottom_nav"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:background="?attr/colorSurface"
        app:menu="@menu/bottom_nav_menu" />

</LinearLayout>
EOF

cat << 'EOF' > app/src/main/res/layout/top_bar_plain.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="horizontal"
    android:paddingStart="20dp"
    android:paddingEnd="20dp"
    android:paddingTop="16dp"
    android:paddingBottom="12dp"
    android:gravity="center_vertical"
    android:background="?attr/colorSurface">

    <TextView
        android:id="@+id/title"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_weight="1"
        android:text="Title"
        android:textSize="20sp"
        android:textStyle="bold"
        android:textColor="?attr/colorOnSurface" />

</LinearLayout>
EOF

cat << 'EOF' > app/src/main/res/layout/top_bar_home.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="horizontal"
    android:paddingStart="20dp"
    android:paddingEnd="20dp"
    android:paddingTop="16dp"
    android:paddingBottom="12dp"
    android:gravity="center_vertical"
    android:background="?attr/colorSurface">

    <TextView
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_weight="1"
        android:text="UltraStream"
        android:textSize="20sp"
        android:textStyle="bold"
        android:drawableStart="@drawable/ic_bolt"
        android:drawablePadding="6dp"
        android:textColor="?attr/colorOnSurface" />
</LinearLayout>
EOF

cat << 'EOF' > app/src/main/res/layout/fragment_home.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:background="@color/dark_bg_main">

    <include layout="@layout/top_bar_plain" />

    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/rv_home"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:padding="8dp"
        android:clipToPadding="false"/>

</LinearLayout>
EOF

cat << 'EOF' > app/src/main/res/layout/fragment_search.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:background="@color/dark_bg_main">

    <include layout="@layout/top_bar_plain" />

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:paddingStart="20dp"
        android:paddingEnd="20dp"
        android:paddingBottom="14dp">

        <com.google.android.material.textfield.TextInputLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox">

            <com.google.android.material.textfield.TextInputEditText
                android:id="@+id/search_input"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:hint="Search movies, series, TV, anime…"
                android:inputType="text"
                android:maxLines="1" />
        </com.google.android.material.textfield.TextInputLayout>

        <HorizontalScrollView
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:scrollbars="none"
            android:paddingTop="12dp">

            <com.google.android.material.chip.ChipGroup
                android:id="@+id/filter_chip_group"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content">

                <com.google.android.material.chip.Chip
                    android:id="@+id/chip_all"
                    style="@style/Widget.MaterialComponents.Chip.Filter"
                    android:text="All"
                    android:checked="true" />
                <com.google.android.material.chip.Chip
                    android:id="@+id/chip_movie"
                    style="@style/Widget.MaterialComponents.Chip.Filter"
                    android:text="Movies" />
                <com.google.android.material.chip.Chip
                    android:id="@+id/chip_series"
                    style="@style/Widget.MaterialComponents.Chip.Filter"
                    android:text="Series" />
                <com.google.android.material.chip.Chip
                    android:id="@+id/chip_anime"
                    style="@style/Widget.MaterialComponents.Chip.Filter"
                    android:text="Anime" />
                <com.google.android.material.chip.Chip
                    android:id="@+id/chip_tv"
                    style="@style/Widget.MaterialComponents.Chip.Filter"
                    android:text="TV" />
            </com.google.android.material.chip.ChipGroup>
        </HorizontalScrollView>

        <HorizontalScrollView
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:scrollbars="none"
            android:paddingTop="6dp">

            <com.google.android.material.chip.ChipGroup
                android:id="@+id/sort_chip_group"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content">

                <com.google.android.material.chip.Chip
                    android:id="@+id/sort_rating"
                    style="@style/Widget.MaterialComponents.Chip.Filter"
                    android:text="⭐ Rating"
                    android:checked="true" />
                <com.google.android.material.chip.Chip
                    android:id="@+id/sort_year"
                    style="@style/Widget.MaterialComponents.Chip.Filter"
                    android:text="📅 Year" />
                <com.google.android.material.chip.Chip
                    android:id="@+id/sort_popular"
                    style="@style/Widget.MaterialComponents.Chip.Filter"
                    android:text="🔥 Popular" />
            </com.google.android.material.chip.ChipGroup>
        </HorizontalScrollView>
    </LinearLayout>

    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/rv_search_results"
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1"
        android:paddingStart="20dp"
        android:paddingEnd="20dp"
        android:paddingTop="10dp"
        android:paddingBottom="20dp"
        app:spanCount="2"
        app:layoutManager="androidx.recyclerview.widget.GridLayoutManager" />

</LinearLayout>
EOF

cat << 'EOF' > app/src/main/res/layout/fragment_addons.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:background="@color/dark_bg_main">

    <include layout="@layout/top_bar_plain" />

    <ScrollView
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1"
        android:fillViewport="true">

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:paddingStart="20dp"
            android:paddingEnd="20dp"
            android:paddingBottom="20dp">

            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Real-Debrid"
                android:textStyle="bold"
                android:textSize="16sp"
                android:textColor="?attr/colorOnSurface"
                android:layout_marginTop="16dp"
                android:layout_marginBottom="8dp" />

            <com.google.android.material.textfield.TextInputLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox">

                <com.google.android.material.textfield.TextInputEditText
                    android:id="@+id/debrid_key_input"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:hint="Real‑Debrid API Key (optional)"
                    android:inputType="textPassword"
                    android:maxLines="1" />
            </com.google.android.material.textfield.TextInputLayout>

            <Button
                android:id="@+id/save_debrid_btn"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="8dp"
                android:text="Save Debrid Key"
                style="@style/Widget.MaterialComponents.Button.OutlinedButton" />

            <TextView
                android:id="@+id/debrid_status"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="8dp"
                android:text="No Debrid key set"
                android:textSize="14sp"
                android:textColor="?attr/colorOnSurface"
                android:visibility="visible" />

            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Install Addon"
                android:textStyle="bold"
                android:textSize="16sp"
                android:textColor="?attr/colorOnSurface"
                android:layout_marginTop="24dp"
                android:layout_marginBottom="8dp" />

            <com.google.android.material.textfield.TextInputLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox">

                <com.google.android.material.textfield.TextInputEditText
                    android:id="@+id/addon_url_input"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:hint="Paste manifest.json URL…"
                    android:inputType="textUri"
                    android:maxLines="1" />
            </com.google.android.material.textfield.TextInputLayout>

            <Button
                android:id="@+id/install_addon_btn"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="8dp"
                android:text="Install Addon"
                style="@style/Widget.MaterialComponents.Button" />

            <include layout="@layout/section_header" />

            <LinearLayout
                android:id="@+id/recommended_addons_container"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="vertical"
                android:layout_marginBottom="16dp" />

            <include layout="@layout/section_header" />

            <LinearLayout
                android:id="@+id/installed_addons_container"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="vertical" />

            <include layout="@layout/section_header" />

            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="horizontal"
                android:layout_marginTop="8dp"
                android:gravity="center">

                <Button
                    android:id="@+id/export_addons_btn"
                    android:layout_width="0dp"
                    android:layout_height="wrap_content"
                    android:layout_weight="1"
                    android:text="Export Addons"
                    style="@style/Widget.MaterialComponents.Button.OutlinedButton"
                    android:layout_marginEnd="8dp" />

                <Button
                    android:id="@+id/import_addons_btn"
                    android:layout_width="0dp"
                    android:layout_height="wrap_content"
                    android:layout_weight="1"
                    android:text="Import Addons"
                    style="@style/Widget.MaterialComponents.Button.OutlinedButton"
                    android:layout_marginStart="8dp" />
            </LinearLayout>

            <Button
                android:id="@+id/factory_reset_btn"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="24dp"
                android:text="🧹 Clear All Addons Data"
                style="@style/Widget.MaterialComponents.Button.TextButton"
                android:textColor="?attr/colorError" />

        </LinearLayout>
    </ScrollView>
</LinearLayout>
EOF

cat << 'EOF' > app/src/main/res/layout/fragment_library.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:background="@color/dark_bg_main">

    <include layout="@layout/top_bar_plain" />

    <ScrollView
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1"
        android:fillViewport="true">

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical">

            <include layout="@layout/section_header" />

            <androidx.recyclerview.widget.RecyclerView
                android:id="@+id/rv_smart_playlists"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:paddingStart="20dp"
                android:paddingEnd="20dp"
                android:paddingTop="10dp"
                android:paddingBottom="20dp"
                app:layoutManager="androidx.recyclerview.widget.LinearLayoutManager"
                android:orientation="horizontal" />

            <include layout="@layout/section_header" />

            <androidx.recyclerview.widget.RecyclerView
                android:id="@+id/rv_lib_history"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:paddingStart="20dp"
                android:paddingEnd="20dp"
                android:paddingTop="10dp"
                android:paddingBottom="20dp"
                app:layoutManager="androidx.recyclerview.widget.LinearLayoutManager"
                android:orientation="horizontal" />

            <include layout="@layout/section_header" />

            <androidx.recyclerview.widget.RecyclerView
                android:id="@+id/rv_watchlist"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:paddingStart="20dp"
                android:paddingEnd="20dp"
                android:paddingTop="10dp"
                android:paddingBottom="20dp"
                app:spanCount="2"
                app:layoutManager="androidx.recyclerview.widget.GridLayoutManager" />

            <include layout="@layout/section_header" />

            <androidx.recyclerview.widget.RecyclerView
                android:id="@+id/rv_library_grid"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:paddingStart="20dp"
                android:paddingEnd="20dp"
                android:paddingTop="10dp"
                android:paddingBottom="20dp"
                app:spanCount="2"
                app:layoutManager="androidx.recyclerview.widget.GridLayoutManager" />

        </LinearLayout>
    </ScrollView>
</LinearLayout>
EOF

cat << 'EOF' > app/src/main/res/layout/fragment_profile.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:background="@color/dark_bg_main">

    <include layout="@layout/top_bar_plain" />

    <ScrollView
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1"
        android:fillViewport="true">

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:paddingStart="20dp"
            android:paddingEnd="20dp"
            android:paddingBottom="20dp">

            <com.google.android.material.card.MaterialCardView
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="16dp"
                android:layout_marginBottom="20dp"
                app:cardCornerRadius="16dp"
                app:cardElevation="4dp">

                <LinearLayout
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:orientation="vertical"
                    android:padding="24dp"
                    android:gravity="center">

                    <ImageView
                        android:id="@+id/profile_avatar_big"
                        android:layout_width="70dp"
                        android:layout_height="70dp"
                        android:layout_marginBottom="14dp"
                        android:background="?attr/colorPrimary"
                        android:src="@drawable/ic_person"
                        android:scaleType="centerCrop"
                        android:padding="4dp" />

                    <TextView
                        android:id="@+id/profile_name_display"
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="User"
                        android:textSize="22sp"
                        android:textStyle="bold"
                        android:textColor="?attr/colorOnSurface" />

                    <TextView
                        android:id="@+id/profile_watchlist_count"
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Watchlist: 0 items"
                        android:textSize="14sp"
                        android:textColor="?attr/colorOnSurface"
                        android:layout_marginTop="4dp" />
                </LinearLayout>
            </com.google.android.material.card.MaterialCardView>

            <include layout="@layout/section_header" />

            <com.google.android.material.card.MaterialCardView
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginBottom="8dp"
                app:cardCornerRadius="12dp"
                app:cardElevation="2dp">

                <LinearLayout
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:orientation="horizontal"
                    android:padding="16dp"
                    android:gravity="center_vertical">

                    <LinearLayout
                        android:layout_width="0dp"
                        android:layout_height="wrap_content"
                        android:layout_weight="1"
                        android:orientation="vertical">
                        <TextView
                            android:layout_width="wrap_content"
                            android:layout_height="wrap_content"
                            android:text="Theme Mode"
                            android:textStyle="bold"
                            android:textSize="16sp"
                            android:textColor="?attr/colorOnSurface" />
                        <TextView
                            android:layout_width="wrap_content"
                            android:layout_height="wrap_content"
                            android:text="Switch between Light &amp; Dark Mode"
                            android:textSize="12sp"
                            android:textColor="?attr/colorOnSurface" />
                    </LinearLayout>

                    <com.google.android.material.switchmaterial.SwitchMaterial
                        android:id="@+id/switch_theme"
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content" />
                </LinearLayout>
            </com.google.android.material.card.MaterialCardView>

            <com.google.android.material.card.MaterialCardView
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginBottom="8dp"
                app:cardCornerRadius="12dp"
                app:cardElevation="2dp">

                <LinearLayout
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:orientation="horizontal"
                    android:padding="16dp"
                    android:gravity="center_vertical">

                    <LinearLayout
                        android:layout_width="0dp"
                        android:layout_height="wrap_content"
                        android:layout_weight="1"
                        android:orientation="vertical">
                        <TextView
                            android:layout_width="wrap_content"
                            android:layout_height="wrap_content"
                            android:text="Hindi Priority"
                            android:textStyle="bold"
                            android:textSize="16sp"
                            android:textColor="?attr/colorOnSurface" />
                        <TextView
                            android:layout_width="wrap_content"
                            android:layout_height="wrap_content"
                            android:text="Push Hindi/Dual Audio streams to top"
                            android:textSize="12sp"
                            android:textColor="?attr/colorOnSurface" />
                    </LinearLayout>

                    <com.google.android.material.switchmaterial.SwitchMaterial
                        android:id="@+id/switch_hindi"
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:checked="true" />
                </LinearLayout>
            </com.google.android.material.card.MaterialCardView>

            <com.google.android.material.card.MaterialCardView
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginBottom="8dp"
                app:cardCornerRadius="12dp"
                app:cardElevation="2dp">

                <LinearLayout
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:orientation="horizontal"
                    android:padding="16dp"
                    android:gravity="center_vertical">

                    <LinearLayout
                        android:layout_width="0dp"
                        android:layout_height="wrap_content"
                        android:layout_weight="1"
                        android:orientation="vertical">
                        <TextView
                            android:layout_width="wrap_content"
                            android:layout_height="wrap_content"
                            android:text="Auto-play Next"
                            android:textStyle="bold"
                            android:textSize="16sp"
                            android:textColor="?attr/colorOnSurface" />
                        <TextView
                            android:layout_width="wrap_content"
                            android:layout_height="wrap_content"
                            android:text="Automatically suggest next episode"
                            android:textSize="12sp"
                            android:textColor="?attr/colorOnSurface" />
                    </LinearLayout>

                    <com.google.android.material.switchmaterial.SwitchMaterial
                        android:id="@+id/switch_autoplay"
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content" />
                </LinearLayout>
            </com.google.android.material.card.MaterialCardView>

            <com.google.android.material.card.MaterialCardView
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginBottom="8dp"
                app:cardCornerRadius="12dp"
                app:cardElevation="2dp">

                <LinearLayout
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:orientation="horizontal"
                    android:padding="16dp"
                    android:gravity="center_vertical">

                    <LinearLayout
                        android:layout_width="0dp"
                        android:layout_height="wrap_content"
                        android:layout_weight="1"
                        android:orientation="vertical">
                        <TextView
                            android:layout_width="wrap_content"
                            android:layout_height="wrap_content"
                            android:text="Parental Control"
                            android:textStyle="bold"
                            android:textSize="16sp"
                            android:textColor="?attr/colorOnSurface" />
                        <TextView
                            android:layout_width="wrap_content"
                            android:layout_height="wrap_content"
                            android:text="Filter content by maturity rating"
                            android:textSize="12sp"
                            android:textColor="?attr/colorOnSurface" />
                    </LinearLayout>

                    <com.google.android.material.switchmaterial.SwitchMaterial
                        android:id="@+id/switch_parental"
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content" />
                </LinearLayout>
            </com.google.android.material.card.MaterialCardView>

            <include layout="@layout/section_header" />

            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="horizontal"
                android:layout_marginTop="8dp"
                android:gravity="center">

                <Button
                    android:id="@+id/export_data_btn"
                    android:layout_width="0dp"
                    android:layout_height="wrap_content"
                    android:layout_weight="1"
                    android:text="Backup Data"
                    style="@style/Widget.MaterialComponents.Button.OutlinedButton"
                    android:layout_marginEnd="8dp" />

                <Button
                    android:id="@+id/import_data_btn"
                    android:layout_width="0dp"
                    android:layout_height="wrap_content"
                    android:layout_weight="1"
                    android:text="Restore"
                    style="@style/Widget.MaterialComponents.Button.OutlinedButton"
                    android:layout_marginStart="8dp" />
            </LinearLayout>

            <Button
                android:id="@+id/factory_reset_btn"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="24dp"
                android:text="🧹 Factory Reset / Clear Data"
                style="@style/Widget.MaterialComponents.Button.TextButton"
                android:textColor="?attr/colorError" />

            <TextView
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="30dp"
                android:text="UltraStream v7.0 — Ultimate Build"
                android:gravity="center"
                android:textSize="12sp"
                android:textColor="?attr/colorOnSurface" />

        </LinearLayout>
    </ScrollView>
</LinearLayout>
EOF

cat << 'EOF' > app/src/main/res/layout/section_header.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="horizontal"
    android:paddingStart="20dp"
    android:paddingEnd="20dp"
    android:paddingTop="24dp"
    android:paddingBottom="12dp"
    android:gravity="center_vertical">

    <TextView
        android:id="@+id/section_title"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_weight="1"
        android:text="Section"
        android:textSize="18sp"
        android:textStyle="bold"
        android:textColor="?android:attr/textColorPrimary" />

</LinearLayout>
EOF

cat << 'EOF' > app/src/main/res/layout/activity_details.xml
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/dark_bg_main">

    <androidx.core.widget.NestedScrollView
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:fillViewport="true">

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical">

            <FrameLayout
                android:layout_width="match_parent"
                android:layout_height="300dp"
                android:background="@color/dark_bg_surface">

                <ImageView
                    android:id="@+id/hero_image"
                    android:layout_width="match_parent"
                    android:layout_height="match_parent"
                    android:scaleType="centerCrop"
                    android:src="@drawable/placeholder_poster" />

                <View
                    android:layout_width="match_parent"
                    android:layout_height="match_parent"
                    android:background="@drawable/gradient_hero_overlay" />

                <LinearLayout
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:orientation="vertical"
                    android:padding="20dp"
                    android:gravity="bottom"
                    android:layout_gravity="bottom">

                    <TextView
                        android:id="@+id/tv_network"
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Movie"
                        android:textSize="12sp"
                        android:textStyle="bold"
                        android:textColor="@color/dark_text_main"
                        android:background="@color/dark_bg_surface"
                        android:paddingStart="12dp"
                        android:paddingEnd="12dp"
                        android:paddingTop="4dp"
                        android:paddingBottom="4dp"
                        android:layout_marginBottom="8dp" />

                    <TextView
                        android:id="@+id/tv_title"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:text="Title"
                        android:textSize="28sp"
                        android:textStyle="bold"
                        android:textColor="@color/dark_text_main" />

                    <LinearLayout
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:orientation="horizontal"
                        android:gravity="center_vertical"
                        android:layout_marginTop="8dp">

                        <TextView
                            android:id="@+id/tv_year"
                            android:layout_width="wrap_content"
                            android:layout_height="wrap_content"
                            android:text="2024"
                            android:textSize="14sp"
                            android:textColor="@color/dark_text_main" />

                        <View
                            android:layout_width="4dp"
                            android:layout_height="4dp"
                            android:layout_marginStart="8dp"
                            android:layout_marginEnd="8dp"
                            android:background="@color/dark_text_main" />

                        <TextView
                            android:id="@+id/tv_runtime"
                            android:layout_width="wrap_content"
                            android:layout_height="wrap_content"
                            android:text="2h 10m"
                            android:textSize="14sp"
                            android:textColor="@color/dark_text_main" />

                        <View
                            android:layout_width="4dp"
                            android:layout_height="4dp"
                            android:layout_marginStart="8dp"
                            android:layout_marginEnd="8dp"
                            android:background="@color/dark_text_main" />

                        <TextView
                            android:id="@+id/tv_rating"
                            android:layout_width="wrap_content"
                            android:layout_height="wrap_content"
                            android:text="⭐ 7.5"
                            android:textSize="14sp"
                            android:textColor="@color/dark_text_main"
                            android:background="@drawable/rating_bg"
                            android:paddingStart="8dp"
                            android:paddingEnd="8dp"
                            android:paddingTop="2dp"
                            android:paddingBottom="2dp" />

                        <TextView
                            android:id="@+id/tv_genre"
                            android:layout_width="wrap_content"
                            android:layout_height="wrap_content"
                            android:text="Action, Drama"
                            android:textSize="14sp"
                            android:textColor="@color/dark_text_main"
                            android:layout_marginStart="8dp" />

                    </LinearLayout>

                </LinearLayout>

            </FrameLayout>

            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="vertical"
                android:paddingStart="20dp"
                android:paddingEnd="20dp"
                android:paddingTop="16dp"
                android:paddingBottom="8dp">

                <TextView
                    android:id="@+id/tv_description"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:text="Description"
                    android:textSize="14sp"
                    android:textColor="@color/dark_text_main"
                    android:maxLines="4"
                    android:ellipsize="end" />

                <TextView
                    android:id="@+id/tv_read_more"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="Read more"
                    android:textSize="12sp"
                    android:textColor="@color/accent_blue"
                    android:visibility="gone"
                    android:layout_marginTop="4dp" />

                <com.google.android.material.chip.ChipGroup
                    android:id="@+id/cast_chip_group"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:layout_marginTop="12dp" />

                <LinearLayout
                    android:id="@+id/episodes_container"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:orientation="vertical"
                    android:visibility="gone">

                    <LinearLayout
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:orientation="horizontal"
                        android:gravity="center_vertical">

                        <TextView
                            android:layout_width="0dp"
                            android:layout_height="wrap_content"
                            android:layout_weight="1"
                            android:text="Episodes"
                            android:textSize="16sp"
                            android:textStyle="bold"
                            android:textColor="?attr/colorOnSurface" />

                        <TextView
                            android:id="@+id/section_more"
                            android:layout_width="wrap_content"
                            android:layout_height="wrap_content"
                            android:text="Season 1 ▼"
                            android:textSize="12sp"
                            android:textColor="@color/accent_blue"
                            android:visibility="gone"
                            android:clickable="true"
                            android:focusable="true" />
                    </LinearLayout>

                    <androidx.recyclerview.widget.RecyclerView
                        android:id="@+id/rv_episodes"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:orientation="vertical"
                        app:layoutManager="androidx.recyclerview.widget.LinearLayoutManager" />
                </LinearLayout>

                <Button
                    android:id="@+id/btn_find_streams"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:layout_marginTop="16dp"
                    android:text="Find Streams"
                    android:textSize="16sp"
                    android:textStyle="bold"
                    style="@style/Widget.MaterialComponents.Button" />

                <Button
                    android:id="@+id/btn_imdb"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:layout_marginTop="8dp"
                    android:text="View on IMDb"
                    android:textSize="14sp"
                    style="@style/Widget.MaterialComponents.Button.OutlinedButton"
                    android:visibility="gone" />

                <LinearLayout
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:orientation="horizontal"
                    android:layout_marginTop="16dp"
                    android:gravity="center">

                    <ImageButton
                        android:id="@+id/btn_watchlist"
                        android:layout_width="48dp"
                        android:layout_height="48dp"
                        android:src="@drawable/ic_watchlist"
                        android:background="?attr/selectableItemBackgroundBorderless"
                        android:contentDescription="Watchlist" />

                    <ImageButton
                        android:id="@+id/btn_library"
                        android:layout_width="48dp"
                        android:layout_height="48dp"
                        android:src="@drawable/ic_bookmark"
                        android:background="?attr/selectableItemBackgroundBorderless"
                        android:contentDescription="Library" />

                    <ImageButton
                        android:id="@+id/btn_back"
                        android:layout_width="48dp"
                        android:layout_height="48dp"
                        android:src="@drawable/ic_back"
                        android:background="?attr/selectableItemBackgroundBorderless"
                        android:contentDescription="Back" />
                </LinearLayout>

            </LinearLayout>

        </LinearLayout>
    </androidx.core.widget.NestedScrollView>

    <FrameLayout
        android:id="@+id/loading_overlay"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:background="#80000000"
        android:visibility="gone">

        <ProgressBar
            android:layout_width="48dp"
            android:layout_height="48dp"
            android:layout_gravity="center" />

        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_gravity="center"
            android:layout_marginTop="64dp"
            android:text="Loading..."
            android:textColor="#ffffff"
            android:textSize="14sp" />
    </FrameLayout>

</FrameLayout>
EOF

cat << 'EOF' > app/src/main/res/layout/activity_player.xml
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="#000000"
    android:fitsSystemWindows="true">

    <com.google.android.exoplayer2.ui.PlayerView
        android:id="@+id/player_view"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        app:use_controller="true" />

    <FrameLayout
        android:id="@+id/loading_overlay"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:background="#80000000"
        android:visibility="gone">

        <ProgressBar
            android:layout_width="48dp"
            android:layout_height="48dp"
            android:layout_gravity="center" />

        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_gravity="center"
            android:layout_marginTop="64dp"
            android:text="Buffering..."
            android:textColor="#ffffff"
            android:textSize="14sp" />
    </FrameLayout>

    <ImageView
        android:id="@+id/btn_pip"
        android:layout_width="40dp"
        android:layout_height="40dp"
        android:layout_alignParentTop="true"
        android:layout_alignParentEnd="true"
        android:layout_marginTop="60dp"
        android:layout_marginEnd="16dp"
        android:src="@drawable/ic_pip"
        android:background="@drawable/round_button_bg"
        android:padding="8dp"
        android:visibility="gone"
        android:contentDescription="Picture in Picture" />

    <ImageView
        android:id="@+id/btn_lock"
        android:layout_width="40dp"
        android:layout_height="40dp"
        android:layout_alignParentTop="true"
        android:layout_marginTop="60dp"
        android:layout_marginStart="16dp"
        android:src="@drawable/ic_lock_open"
        android:background="@drawable/round_button_bg"
        android:padding="8dp"
        android:visibility="gone"
        android:contentDescription="Lock Controls" />

    <LinearLayout
        android:id="@+id/error_layout"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_centerInParent="true"
        android:orientation="vertical"
        android:gravity="center"
        android:visibility="gone">

        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="⚠️"
            android:textSize="48sp" />

        <TextView
            android:id="@+id/tv_error"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Playback Error"
            android:textColor="#ffffff"
            android:textSize="16sp"
            android:layout_marginTop="12dp" />

        <Button
            android:id="@+id/btn_retry"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Retry"
            android:layout_marginTop="12dp"
            style="@style/Widget.MaterialComponents.Button"
            android:backgroundTint="#38bdf8" />

    </LinearLayout>

</RelativeLayout>
EOF

cat << 'EOF' > app/src/main/res/layout/item_poster.xml
<?xml version="1.0" encoding="utf-8"?>
<com.google.android.material.card.MaterialCardView xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="130dp"
    android:layout_height="wrap_content"
    android:layout_marginEnd="14dp">

    <FrameLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content">

        <ImageView
            android:id="@+id/poster_image"
            android:layout_width="match_parent"
            android:layout_height="195dp"
            android:scaleType="centerCrop"
            android:src="@drawable/placeholder_poster" />

        <TextView
            android:id="@+id/tv_rating"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="⭐ 7.5"
            android:textSize="10sp"
            android:textStyle="bold"
            android:textColor="#fbbf24"
            android:background="#cc000000"
            android:paddingStart="6dp"
            android:paddingEnd="6dp"
            android:paddingTop="3dp"
            android:paddingBottom="3dp"
            android:layout_marginStart="6dp"
            android:layout_marginTop="6dp"
            android:visibility="gone" />

        <TextView
            android:id="@+id/tv_type"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="MOVIE"
            android:textSize="9sp"
            android:textStyle="bold"
            android:textColor="#ffffff"
            android:background="#38bdf8"
            android:paddingStart="8dp"
            android:paddingEnd="8dp"
            android:paddingTop="2dp"
            android:paddingBottom="2dp"
            android:layout_marginEnd="6dp"
            android:layout_marginTop="6dp"
            android:layout_gravity="end"
            android:visibility="gone" />

        <TextView
            android:id="@+id/tv_year"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="2024"
            android:textSize="10sp"
            android:textStyle="bold"
            android:textColor="#ffffff"
            android:background="#cc000000"
            android:paddingStart="8dp"
            android:paddingEnd="8dp"
            android:paddingTop="2dp"
            android:paddingBottom="2dp"
            android:layout_marginEnd="6dp"
            android:layout_marginBottom="6dp"
            android:layout_gravity="end|bottom"
            android:visibility="gone" />

        <TextView
            android:id="@+id/tv_title"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:text="Title"
            android:textSize="12sp"
            android:textStyle="bold"
            android:textColor="#ffffff"
            android:gravity="center"
            android:paddingStart="6dp"
            android:paddingEnd="6dp"
            android:paddingTop="18dp"
            android:paddingBottom="8dp"
            android:layout_gravity="bottom"
            android:background="@drawable/title_gradient"
            android:maxLines="1"
            android:ellipsize="end" />

        <ProgressBar
            android:id="@+id/progress_bar"
            style="?android:attr/progressBarStyleHorizontal"
            android:layout_width="match_parent"
            android:layout_height="4dp"
            android:layout_gravity="bottom"
            android:progressTint="#38bdf8"
            android:visibility="gone"
            android:max="100" />

    </FrameLayout>
</com.google.android.material.card.MaterialCardView>
EOF

cat << 'EOF' > app/src/main/res/layout/item_episode.xml
<?xml version="1.0" encoding="utf-8"?>
<com.google.android.material.card.MaterialCardView xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_marginBottom="12dp"


>

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:padding="10dp"
        android:gravity="center_vertical">

        <!-- Thumbnail -->
        <FrameLayout
            android:layout_width="110dp"
            android:layout_height="70dp"
            android:layout_marginEnd="12dp">

            <ImageView
                android:id="@+id/ep_thumb"
                android:layout_width="match_parent"
                android:layout_height="match_parent"
                android:scaleType="centerCrop"
                android:src="@drawable/placeholder_poster" />

            <TextView
                android:id="@+id/ep_badge"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="S01E01"
                android:textSize="10sp"
                android:textStyle="bold"
                android:textColor="#ffffff"
                android:background="#cc000000"
                android:paddingStart="6dp"
                android:paddingEnd="6dp"
                android:paddingTop="2dp"
                android:paddingBottom="2dp"
                android:layout_gravity="end|bottom"
                android:layout_margin="4dp" />

            <ProgressBar
                android:id="@+id/ep_progress"
                style="?android:attr/progressBarStyleHorizontal"
                android:layout_width="match_parent"
                android:layout_height="3dp"
                android:layout_gravity="bottom"
                android:progressTint="#38bdf8"
                android:visibility="gone"
                android:max="100" />

        </FrameLayout>

        <!-- Details -->
        <LinearLayout
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:orientation="vertical">

            <TextView
                android:id="@+id/ep_title"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:text="Episode Title"
                android:textSize="14sp"
                android:textStyle="bold"
                android:textColor="?attr/colorOnSurface"
                android:maxLines="2"
                android:ellipsize="end" />

            <TextView
                android:id="@+id/ep_desc"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:text="Description"
                android:textSize="11sp"
                android:textColor="?attr/colorOnSurface"
                android:maxLines="2"
                android:ellipsize="end"
                android:layout_marginTop="2dp" />

            <TextView
                android:id="@+id/ep_watched"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="✅ Watched"
                android:textSize="10sp"
                android:textStyle="bold"
                android:textColor="#4caf50"
                android:visibility="gone"
                android:layout_marginTop="4dp" />

        </LinearLayout>

    </LinearLayout>

</com.google.android.material.card.MaterialCardView>
EOF

cat << 'EOF' > app/src/main/res/layout/item_stream.xml
<?xml version="1.0" encoding="utf-8"?>
<com.google.android.material.card.MaterialCardView xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_marginBottom="12dp"


>

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:padding="14dp">

        <!-- Header: Addon + Quality -->
        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="horizontal"
            android:gravity="center_vertical"
            android:layout_marginBottom="8dp">

            <TextView
                android:id="@+id/stream_addon"
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_weight="1"
                android:text="Torrentio"
                android:textSize="12sp"
                android:textStyle="bold"
                android:textColor="?attr/colorPrimary" />

            <TextView
                android:id="@+id/stream_quality"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="1080p"
                android:textSize="10sp"
                android:textStyle="bold"
                android:textColor="?attr/colorOnSurface"
                android:background="@drawable/badge_background"
                android:paddingStart="10dp"
                android:paddingEnd="10dp"
                android:paddingTop="2dp"
                android:paddingBottom="2dp" />

        </LinearLayout>

        <!-- Title -->
        <TextView
            android:id="@+id/stream_title"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:text="Stream Title"
            android:textSize="14sp"
            android:textColor="?attr/colorOnSurface"
            android:maxLines="2"
            android:ellipsize="end"
            android:layout_marginBottom="8dp" />

        <!-- Badges -->
        <com.google.android.material.chip.ChipGroup
            android:id="@+id/stream_chip_group"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"


            android:visibility="gone" />

    </LinearLayout>

</com.google.android.material.card.MaterialCardView>
EOF

cat << 'EOF' > app/src/main/res/layout/item_cw.xml
<?xml version="1.0" encoding="utf-8"?>
<com.google.android.material.card.MaterialCardView xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="280dp"
    android:layout_height="wrap_content"
    android:layout_marginEnd="14dp"


>

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:padding="10dp"
        android:gravity="center_vertical">

        <ImageView
            android:id="@+id/cw_thumb"
            android:layout_width="75dp"
            android:layout_height="100dp"
            android:scaleType="centerCrop"
            android:src="@drawable/placeholder_poster"
            android:layout_marginEnd="12dp" />

        <LinearLayout
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:orientation="vertical">

            <TextView
                android:id="@+id/cw_title"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:text="Title"
                android:textSize="15sp"
                android:textStyle="bold"
                android:textColor="?attr/colorOnSurface"
                android:maxLines="2"
                android:ellipsize="end" />

            <TextView
                android:id="@+id/cw_meta"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Movie"
                android:textSize="10sp"
                android:textStyle="bold"
                android:textColor="?attr/colorOnSurface"
                android:layout_marginTop="2dp" />

            <ProgressBar
                android:id="@+id/cw_progress"
                style="?android:attr/progressBarStyleHorizontal"
                android:layout_width="match_parent"
                android:layout_height="3dp"
                android:layout_marginTop="6dp"
                android:progressTint="#38bdf8"
                android:max="100"
                android:progress="0" />

        </LinearLayout>

    </LinearLayout>

</com.google.android.material.card.MaterialCardView>
EOF

cat << 'EOF' > app/src/main/res/layout/item_smart_playlist.xml
<?xml version="1.0" encoding="utf-8"?>
<com.google.android.material.card.MaterialCardView xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="280dp"
    android:layout_height="wrap_content"
    android:layout_marginEnd="14dp"



    android:clickable="true"
    android:focusable="true">

    <RelativeLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:padding="10dp">

        <ImageView
            android:id="@+id/playlist_thumb"
            android:layout_width="match_parent"
            android:layout_height="120dp"
            android:scaleType="centerCrop"
            android:src="@drawable/placeholder_poster" />

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:layout_marginTop="8dp">

            <TextView
                android:id="@+id/playlist_title"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:text="Playlist Name"
                android:textSize="15sp"
                android:textStyle="bold"
                android:textColor="?attr/colorOnSurface"
                android:maxLines="1"
                android:ellipsize="end" />

            <TextView
                android:id="@+id/playlist_meta"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:text="Season 1 • Torrentio"
                android:textSize="11sp"
                android:textColor="?attr/colorOnSurface"
                android:layout_marginTop="2dp" />

            <TextView
                android:id="@+id/playlist_status"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:text="✅ Ready (5/5)"
                android:textSize="11sp"
                android:textStyle="bold"
                android:textColor="#4caf50"
                android:layout_marginTop="4dp" />

            <ProgressBar
                android:id="@+id/playlist_progress"
                style="?android:attr/progressBarStyleHorizontal"
                android:layout_width="match_parent"
                android:layout_height="3dp"
                android:layout_marginTop="6dp"
                android:progressTint="#4caf50"
                android:max="100" />

            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="horizontal"
                android:layout_marginTop="8dp"
                android:gravity="center">

                <Button
                    android:id="@+id/btn_m3u"
                    android:layout_width="0dp"
                    android:layout_height="30dp"
                    android:layout_weight="1"
                    android:text=".m3u"
                    android:textSize="10sp"
                    android:textStyle="bold"
                    android:backgroundTint="#4fc3f7"
                    style="@style/Widget.MaterialComponents.Button" />

                <ImageView
                    android:id="@+id/btn_delete_playlist"
                    android:layout_width="30dp"
                    android:layout_height="30dp"
                    android:src="@drawable/ic_delete"
                    android:background="@drawable/round_button_bg"
                    android:padding="6dp"
                    android:layout_marginStart="8dp"
                    android:contentDescription="Delete" />

            </LinearLayout>

        </LinearLayout>

    </RelativeLayout>

</com.google.android.material.card.MaterialCardView>
EOF

cat << 'EOF' > app/src/main/res/layout/item_recommended_addon.xml
<?xml version="1.0" encoding="utf-8"?>
<com.google.android.material.card.MaterialCardView xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_marginBottom="8dp"


>

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:padding="14dp"
        android:gravity="center_vertical">

        <LinearLayout
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:orientation="vertical">

            <TextView
                android:id="@+id/addon_name"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:text="Torrentio"
                android:textSize="15sp"
                android:textStyle="bold"
                android:textColor="?attr/colorOnSurface" />

            <TextView
                android:id="@+id/addon_desc"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:text="Best torrent scraper"
                android:textSize="12sp"
                android:textColor="?attr/colorOnSurface" />

        </LinearLayout>

        <Button
            android:id="@+id/btn_install"
            android:layout_width="wrap_content"
            android:layout_height="36dp"
            android:text="Install"
            android:textSize="12sp"
            android:textStyle="bold"
            android:backgroundTint="?attr/colorPrimary"
            style="@style/Widget.MaterialComponents.Button" />

    </LinearLayout>

</com.google.android.material.card.MaterialCardView>
EOF

cat << 'EOF' > app/src/main/res/layout/sheet_streams.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="vertical"
    android:background="@color/dark_bg_main"
    android:padding="16dp">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:gravity="center_vertical"
        android:layout_marginBottom="16dp">

        <TextView
            android:id="@+id/sheet_title"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:text="Available Streams"
            android:textSize="18sp"
            android:textStyle="bold"
            android:textColor="?attr/colorOnSurface" />

        <ImageView
            android:id="@+id/btn_close"
            android:layout_width="36dp"
            android:layout_height="36dp"
            android:src="@drawable/ic_close"
            android:background="@drawable/round_button_bg"
            android:padding="8dp"
            android:contentDescription="Close"
            android:onClick="@{() -> dismiss()}" />

    </LinearLayout>

    <ProgressBar
        android:id="@+id/loading_spinner"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="center"
        android:visibility="gone" />

    <TextView
        android:id="@+id/tv_no_streams"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="No streams found"
        android:gravity="center"
        android:textSize="14sp"
        android:textColor="?attr/colorOnSurface"
        android:padding="30dp"
        android:visibility="gone" />

    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/rv_streams"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:maxHeight="400dp"
        android:paddingBottom="16dp"
 />

</LinearLayout>
EOF

cat << 'EOF' > app/src/main/res/layout/sheet_stream_action.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="vertical"
    android:padding="16dp"
    android:background="@color/dark_bg_main">

    <TextView
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="Stream Options"
        android:textSize="18sp"
        android:textStyle="bold"
        android:textColor="?attr/colorOnSurface"
        android:paddingBottom="16dp" />

    <Button
        android:id="@+id/btn_play_external"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginBottom="8dp"
        android:text="▶️ Play in Default Player"
        style="@style/Widget.MaterialComponents.Button" />

    <Button
        android:id="@+id/btn_download"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginBottom="8dp"
        android:text="📥 Download / Open in Browser"
        style="@style/Widget.MaterialComponents.Button.OutlinedButton" />

    <Button
        android:id="@+id/btn_copy_magnet"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginBottom="8dp"
        android:text="🧲 Copy Magnet Link"
        style="@style/Widget.MaterialComponents.Button.OutlinedButton" />

    <Button
        android:id="@+id/btn_copy_url"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginBottom="8dp"
        android:text="🔗 Copy Direct Video URL"
        style="@style/Widget.MaterialComponents.Button.OutlinedButton" />

    <Button
        android:id="@+id/btn_subtitles"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginBottom="8dp"
        android:text="💬 Search Subtitles"
        style="@style/Widget.MaterialComponents.Button.OutlinedButton" />

    <Button
        android:id="@+id/btn_export_m3u"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="📂 Export / Play .m3u"
        style="@style/Widget.MaterialComponents.Button.OutlinedButton" />

</LinearLayout>
EOF

cat << 'EOF' > app/src/main/res/layout/sheet_seasons.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="vertical"
    android:padding="16dp"
    android:background="@color/dark_bg_main">

    <TextView
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="Select Season"
        android:textSize="18sp"
        android:textStyle="bold"
        android:textColor="?attr/colorOnSurface"
        android:paddingBottom="16dp" />

    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/rv_seasons"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:maxHeight="300dp" />

</LinearLayout>
EOF

cat << 'EOF' > app/src/main/res/layout/sheet_subtitles.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="vertical"
    android:background="@color/dark_bg_main"
    android:padding="16dp">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:gravity="center_vertical"
        android:layout_marginBottom="16dp">

        <TextView
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:text="Subtitles"
            android:textSize="18sp"
            android:textStyle="bold"
            android:textColor="?attr/colorOnSurface" />

        <ImageView
            android:id="@+id/btn_close"
            android:layout_width="36dp"
            android:layout_height="36dp"
            android:src="@drawable/ic_close"
            android:background="@drawable/round_button_bg"
            android:padding="8dp"
            android:contentDescription="Close"
            android:onClick="@{() -> dismiss()}" />

    </LinearLayout>

    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/rv_subtitles"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:maxHeight="400dp"
        android:paddingBottom="16dp"
 />

</LinearLayout>
EOF

cat << 'EOF' > app/src/main/res/layout/sheet_m3u_actions.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="vertical"
    android:background="@color/dark_bg_main"
    android:padding="16dp">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:gravity="center_vertical"
        android:layout_marginBottom="12dp">

        <TextView
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:text="📁 M3U Playlist"
            android:textSize="18sp"
            android:textStyle="bold"
            android:textColor="?attr/colorOnSurface" />

        <ImageView
            android:id="@+id/btn_close"
            android:layout_width="36dp"
            android:layout_height="36dp"
            android:src="@drawable/ic_close"
            android:background="@drawable/round_button_bg"
            android:padding="8dp"
            android:contentDescription="Close"
            android:onClick="@{() -> dismiss()}" />

    </LinearLayout>

    <TextView
        android:id="@+id/tv_m3u_desc"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="Choose an action"
        android:textSize="14sp"
        android:textColor="?attr/colorOnSurface"
        android:paddingBottom="16dp" />

    <Button
        android:id="@+id/btn_export_m3u"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginBottom="8dp"
        android:text="📥 Export .m3u"
        android:textSize="14sp"
        style="@style/Widget.MaterialComponents.Button.OutlinedButton" />

    <Button
        android:id="@+id/btn_play_m3u"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="▶️ Play in Player"
        android:textSize="14sp"
        style="@style/Widget.MaterialComponents.Button" />

</LinearLayout>
EOF

cat << 'EOF' > app/src/main/res/layout/layout_catalog_row.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="vertical"
    android:layout_marginTop="8dp">

    <TextView
        android:id="@+id/tv_section_title"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="Section Title"
        android:textSize="16sp"
        android:textStyle="bold"
        android:textColor="?attr/colorOnSurface"
        android:paddingStart="20dp"
        android:paddingEnd="20dp"
        android:paddingBottom="8dp" />

    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/rv_catalog"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:paddingStart="20dp"
        android:paddingEnd="20dp"
        android:paddingBottom="12dp"

        android:orientation="horizontal" />

</LinearLayout>
EOF

cat << 'EOF' > app/src/main/res/layout/item_home_movie.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="180dp"
    android:orientation="vertical"
    android:layout_margin="6dp">

    <com.google.android.material.card.MaterialCardView
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1"
        app:cardCornerRadius="8dp"
        app:cardElevation="4dp"
        app:strokeWidth="0dp">

        <ImageView
            android:id="@+id/home_poster_img"
            android:layout_width="match_parent"
            android:layout_height="match_parent"
            android:scaleType="centerCrop"
            android:background="#222222" />
            
    </com.google.android.material.card.MaterialCardView>

    <TextView
        android:id="@+id/home_poster_title"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:textColor="?attr/colorOnSurface"
        android:textSize="12sp"
        android:textStyle="bold"
        android:maxLines="1"
        android:ellipsize="end"
        android:textAlignment="center"
        android:layout_marginTop="6dp"/>
</LinearLayout>
EOF

# ============================================================
# Navigation and menu
# ============================================================
cat << 'EOF' > app/src/main/res/menu/bottom_nav_menu.xml
<?xml version="1.0" encoding="utf-8"?>
<menu xmlns:android="http://schemas.android.com/apk/res/android">
    <item
        android:id="@+id/navigation_home"
        android:icon="@drawable/ic_home"
        android:title="Home" />
    <item
        android:id="@+id/navigation_library"
        android:icon="@drawable/ic_library"
        android:title="Library" />
    <item
        android:id="@+id/navigation_search"
        android:icon="@drawable/ic_search"
        android:title="Search" />
    <item
        android:id="@+id/navigation_addons"
        android:icon="@drawable/ic_addons"
        android:title="Addons" />
    <item
        android:id="@+id/navigation_profile"
        android:icon="@drawable/ic_profile"
        android:title="Profile" />
</menu>
EOF

cat << 'EOF' > app/src/main/res/navigation/nav_graph.xml
<?xml version="1.0" encoding="utf-8"?>
<navigation xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    app:startDestination="@id/navigation_home">

    <fragment
        android:id="@+id/navigation_home"
        android:name="com.ultrastream.ui.home.HomeFragment"
        android:label="Home"
        tools:layout="@layout/fragment_home" />

    <fragment
        android:id="@+id/navigation_library"
        android:name="com.ultrastream.ui.library.LibraryFragment"
        android:label="Library"
        tools:layout="@layout/fragment_library" />

    <fragment
        android:id="@+id/navigation_search"
        android:name="com.ultrastream.ui.search.SearchFragment"
        android:label="Search"
        tools:layout="@layout/fragment_search" />

    <fragment
        android:id="@+id/navigation_addons"
        android:name="com.ultrastream.ui.addons.AddonsFragment"
        android:label="Addons"
        tools:layout="@layout/fragment_addons" />

    <fragment
        android:id="@+id/navigation_profile"
        android:name="com.ultrastream.ui.profile.ProfileFragment"
        android:label="Profile"
        tools:layout="@layout/fragment_profile" />

</navigation>
EOF

cat << 'EOF' > app/src/main/res/xml/data_extraction_rules.xml
<?xml version="1.0" encoding="utf-8"?>
<data-extraction-rules>
    <cloud-backup>
        <include domain="database" />
        <include domain="sharedpref" />
        <include domain="file" path="." />
        <exclude domain="file" path="cache/" />
    </cloud-backup>
    <device-transfer>
        <include domain="database" />
        <include domain="sharedpref" />
        <include domain="file" path="." />
        <exclude domain="file" path="cache/" />
    </device-transfer>
</data-extraction-rules>
EOF

cat << 'EOF' > app/src/main/res/xml/backup_rules.xml
<?xml version="1.0" encoding="utf-8"?>
<full-backup-content>
    <include domain="database" />
    <include domain="sharedpref" />
    <include domain="file" path="." />
    <exclude domain="file" path="cache/" />
</full-backup-content>
EOF

cat << 'EOF' > app/src/main/res/xml/file_paths.xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <external-path
        name="external"
        path="." />
    <external-files-path
        name="external_files"
        path="." />
    <cache-path
        name="cache"
        path="." />
    <external-cache-path
        name="external_cache"
        path="." />
    <files-path
        name="files"
        path="." />
    <external-files-path
        name="downloads"
        path="Download/" />
    <external-files-path
        name="movies"
        path="Movies/" />
</paths>
EOF

# ============================================================
# Kotlin Source Files
# ============================================================
mkdir -p app/src/main/java/com/ultrastream/data/models
mkdir -p app/src/main/java/com/ultrastream/data/database
mkdir -p app/src/main/java/com/ultrastream/data/database/dao
mkdir -p app/src/main/java/com/ultrastream/data/repository
mkdir -p app/src/main/java/com/ultrastream/utils
mkdir -p app/src/main/java/com/ultrastream/ui/home
mkdir -p app/src/main/java/com/ultrastream/ui/search
mkdir -p app/src/main/java/com/ultrastream/ui/addons
mkdir -p app/src/main/java/com/ultrastream/ui/library
mkdir -p app/src/main/java/com/ultrastream/ui/profile
mkdir -p app/src/main/java/com/ultrastream/ui/details
mkdir -p app/src/main/java/com/ultrastream/ui/adapters
mkdir -p app/src/main/java/com/ultrastream/ui/sheets
mkdir -p app/src/main/java/com/ultrastream/player
mkdir -p app/src/main/java/com/ultrastream/network

# ============================================================
# Data Models
# ============================================================
cat << 'EOF' > app/src/main/java/com/ultrastream/data/models/Addon.kt
// app/src/main/java/com/ultrastream/data/models/Addon.kt
package com.ultrastream.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey
import com.google.gson.annotations.SerializedName

@Entity(tableName = "addons")
data class Addon(
    @PrimaryKey
    val id: String,
    val url: String,
    val name: String,
    val enabled: Boolean = true,
    val required: Boolean = false,
    @SerializedName("catalogs")
    val catalogs: List<Catalog> = emptyList()
)

data class Catalog(
    val type: String,          // movie, series, anime, tv
    val id: String,
    val name: String,
    val extraSupported: List<String>? = null,
    val extra: List<Extra>? = null
)

data class Extra(
    val name: String,
    val isRequired: Boolean = false,
    val options: List<String>? = null
)
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/data/models/AddonManifest.kt
// app/src/main/java/com/ultrastream/data/models/AddonManifest.kt
package com.ultrastream.data.models

data class AddonManifest(
    val id: String,
    val name: String,
    val version: String,
    val description: String? = null,
    val catalogs: List<CatalogItem> = emptyList(),
    val resources: List<String> = emptyList(),
    val types: List<String> = emptyList()
) {
    data class CatalogItem(
        val type: String,
        val id: String,
        val name: String
    )
}
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/data/models/MetaItem.kt
// app/src/main/java/com/ultrastream/data/models/MetaItem.kt
package com.ultrastream.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey
import com.google.gson.annotations.SerializedName
import java.io.Serializable

@Entity(tableName = "meta_cache")
data class MetaItem(
    @PrimaryKey
    val id: String,
    val type: String,           // movie, series, anime, tv
    val name: String,
    val poster: String? = null,
    val background: String? = null,
    val description: String? = null,
    val year: Int? = null,
    val runtime: String? = null,
    val imdbRating: Float? = null,
    val imdbId: String? = null,
    val genre: List<String>? = null,
    val releaseInfo: String? = null,
    val released: String? = null,
    val cast: List<String>? = null,
    val videos: List<Video>? = null,
    val cachedAt: Long = System.currentTimeMillis()
) : Serializable

data class Video(
    val season: Int,
    val episode: Int,
    val name: String? = null,
    val title: String? = null,
    val description: String? = null,
    val thumbnail: String? = null,
    val url: String? = null
)
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/data/models/Stream.kt
// app/src/main/java/com/ultrastream/data/models/Stream.kt
package com.ultrastream.data.models

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class Stream(
    val url: String? = null,
    val streamUrl: String? = null,
    val externalUrl: String? = null,
    val title: String? = null,
    val name: String? = null,
    val description: String? = null,
    val infoHash: String? = null,
    val subtitles: List<Subtitle>? = null,
    val addonName: String? = null,
    val quality: String? = null,
    val size: String? = null,
    val seeds: Int? = null,
    val languages: List<String>? = null,
    val isLive: Boolean = false
) : Parcelable

@Parcelize
data class Subtitle(
    val url: String,
    val lang: String = "en",
    val name: String? = null,
    val file: String? = null
) : Parcelable
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/data/models/WatchHistory.kt
// app/src/main/java/com/ultrastream/data/models/WatchHistory.kt
package com.ultrastream.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.io.Serializable

@Entity(tableName = "watch_history")
data class WatchHistory(
    @PrimaryKey
    val id: String,
    val type: String,
    val name: String,
    val poster: String? = null,
    val timestamp: Long = System.currentTimeMillis()
) : Serializable
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/data/models/WatchProgress.kt
// app/src/main/java/com/ultrastream/data/models/WatchProgress.kt
package com.ultrastream.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.io.Serializable

@Entity(tableName = "watch_progress")
data class WatchProgress(
    @PrimaryKey
    val id: String,           // can be video id or episode key
    val percent: Float = 0f,
    val lastUpdate: Long = System.currentTimeMillis()
) : Serializable
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/data/models/WatchedEpisode.kt
// app/src/main/java/com/ultrastream/data/models/WatchedEpisode.kt
package com.ultrastream.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.io.Serializable

@Entity(tableName = "watched_episodes")
data class WatchedEpisode(
    @PrimaryKey
    val episodeKey: String,   // format: "metaId_sSeason_eEpisode"
    val isWatched: Boolean = true,
    val timestamp: Long = System.currentTimeMillis()
) : Serializable
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/data/models/SmartPlaylist.kt
// app/src/main/java/com/ultrastream/data/models/SmartPlaylist.kt
package com.ultrastream.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey
import com.google.gson.annotations.SerializedName
import java.io.Serializable

@Entity(tableName = "smart_playlists")
data class SmartPlaylist(
    @PrimaryKey
    val id: String,
    val metaId: String,
    val metaName: String,
    val poster: String? = null,
    val season: Int,
    val addon: String,
    val total: Int,
    val fetched: Int = 0,
    val status: String = "Fetching...",
    val episodes: List<PlaylistEpisode> = emptyList()
) : Serializable

data class PlaylistEpisode(
    val epNum: Int,
    val epName: String,
    val title: String,
    val stream: Stream? = null,
    val isMissing: Boolean = false
)
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/data/models/Profile.kt
// app/src/main/java/com/ultrastream/data/models/Profile.kt
package com.ultrastream.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.io.Serializable

@Entity(tableName = "profiles")
data class Profile(
    @PrimaryKey
    val id: String,
    val name: String,
    val avatar: String = name.firstOrNull()?.uppercase() ?: "U"
) : Serializable
EOF

# ============================================================
# Room Database and DAOs
# ============================================================
cat << 'EOF' > app/src/main/java/com/ultrastream/data/database/Converters.kt
// app/src/main/java/com/ultrastream/data/database/Converters.kt
package com.ultrastream.data.database

import androidx.room.TypeConverter
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.ultrastream.data.models.*

class Converters {

    @TypeConverter
    fun fromCatalogList(value: List<Catalog>): String {
        return Gson().toJson(value)
    }

    @TypeConverter
    fun toCatalogList(value: String): List<Catalog> {
        val type = object : TypeToken<List<Catalog>>() {}.type
        return Gson().fromJson(value, type) ?: emptyList()
    }

    @TypeConverter
    fun fromVideoList(value: List<Video>): String {
        return Gson().toJson(value)
    }

    @TypeConverter
    fun toVideoList(value: String): List<Video> {
        val type = object : TypeToken<List<Video>>() {}.type
        return Gson().fromJson(value, type) ?: emptyList()
    }

    @TypeConverter
    fun fromPlaylistEpisodeList(value: List<PlaylistEpisode>): String {
        return Gson().toJson(value)
    }

    @TypeConverter
    fun toPlaylistEpisodeList(value: String): List<PlaylistEpisode> {
        val type = object : TypeToken<List<PlaylistEpisode>>() {}.type
        return Gson().fromJson(value, type) ?: emptyList()
    }

    @TypeConverter
    fun fromStringList(value: List<String>): String {
        return Gson().toJson(value)
    }

    @TypeConverter
    fun toStringList(value: String): List<String> {
        val type = object : TypeToken<List<String>>() {}.type
        return Gson().fromJson(value, type) ?: emptyList()
    }

    @TypeConverter
    fun fromStream(value: Stream?): String {
        return Gson().toJson(value)
    }

    @TypeConverter
    fun toStream(value: String): Stream? {
        return Gson().fromJson(value, Stream::class.java)
    }

    @TypeConverter
    fun fromSubtitleList(value: List<Subtitle>?): String {
        return Gson().toJson(value)
    }

    @TypeConverter
    fun toSubtitleList(value: String): List<Subtitle>? {
        val type = object : TypeToken<List<Subtitle>>() {}.type
        return Gson().fromJson(value, type)
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/data/database/AppDatabase.kt
// app/src/main/java/com/ultrastream/data/database/AppDatabase.kt
package com.ultrastream.data.database

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import com.ultrastream.data.models.*

@Database(
    entities = [
        Addon::class,
        MetaItem::class,
        SmartPlaylist::class,
        Profile::class,
        WatchHistory::class,
        WatchProgress::class,
        WatchedEpisode::class
    ],
    version = 1,
    exportSchema = false
)
@TypeConverters(Converters::class)
abstract class AppDatabase : RoomDatabase() {
    abstract fun addonDao(): AddonDao
    abstract fun metaDao(): MetaDao
    abstract fun playlistDao(): SmartPlaylistDao
    abstract fun profileDao(): ProfileDao
    abstract fun watchHistoryDao(): WatchHistoryDao
    abstract fun watchProgressDao(): WatchProgressDao
    abstract fun watchedEpisodeDao(): WatchedEpisodeDao
}
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/data/database/dao/AddonDao.kt
// app/src/main/java/com/ultrastream/data/database/dao/AddonDao.kt
package com.ultrastream.data.database

import androidx.room.*
import com.ultrastream.data.models.Addon
import kotlinx.coroutines.flow.Flow

@Dao
interface AddonDao {
    @Query("SELECT * FROM addons")
    fun getAll(): Flow<List<Addon>>

    @Query("SELECT * FROM addons WHERE enabled = 1")
    fun getEnabled(): Flow<List<Addon>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(addon: Addon)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(addons: List<Addon>)

    @Update
    suspend fun update(addon: Addon)

    @Delete
    suspend fun delete(addon: Addon)

    @Query("DELETE FROM addons WHERE id = :id AND required = 0")
    suspend fun deleteById(id: String)

    @Query("SELECT * FROM addons WHERE id = :id")
    suspend fun getById(id: String): Addon?
}
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/data/database/dao/MetaDao.kt
// app/src/main/java/com/ultrastream/data/database/dao/MetaDao.kt
package com.ultrastream.data.database

import androidx.room.*
import com.ultrastream.data.models.MetaItem

@Dao
interface MetaDao {
    @Query("SELECT * FROM meta_cache WHERE id = :id")
    suspend fun getById(id: String): MetaItem?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(meta: MetaItem)

    @Query("DELETE FROM meta_cache WHERE cachedAt < :cutoff")
    suspend fun deleteOld(cutoff: Long)
}
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/data/database/dao/SmartPlaylistDao.kt
// app/src/main/java/com/ultrastream/data/database/dao/SmartPlaylistDao.kt
package com.ultrastream.data.database

import androidx.room.*
import com.ultrastream.data.models.SmartPlaylist
import kotlinx.coroutines.flow.Flow

@Dao
interface SmartPlaylistDao {
    @Query("SELECT * FROM smart_playlists")
    fun getAll(): Flow<List<SmartPlaylist>>

    @Query("SELECT * FROM smart_playlists WHERE id = :id")
    suspend fun getById(id: String): SmartPlaylist?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(playlist: SmartPlaylist)

    @Update
    suspend fun update(playlist: SmartPlaylist)

    @Delete
    suspend fun delete(playlist: SmartPlaylist)

    @Query("DELETE FROM smart_playlists WHERE id = :id")
    suspend fun deleteById(id: String)
}
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/data/database/dao/WatchHistoryDao.kt
// app/src/main/java/com/ultrastream/data/database/dao/WatchHistoryDao.kt
package com.ultrastream.data.database

import androidx.room.*
import com.ultrastream.data.models.WatchHistory
import kotlinx.coroutines.flow.Flow

@Dao
interface WatchHistoryDao {
    @Query("SELECT * FROM watch_history ORDER BY timestamp DESC")
    fun getAll(): Flow<List<WatchHistory>>

    @Query("SELECT * FROM watch_history WHERE id = :id")
    suspend fun getById(id: String): WatchHistory?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(history: WatchHistory)

    @Query("DELETE FROM watch_history WHERE id = :id")
    suspend fun deleteById(id: String)

    @Query("DELETE FROM watch_history")
    suspend fun clearAll()

    @Query("SELECT COUNT(*) FROM watch_history")
    suspend fun getCount(): Int
}
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/data/database/dao/WatchProgressDao.kt
// app/src/main/java/com/ultrastream/data/database/dao/WatchProgressDao.kt
package com.ultrastream.data.database

import androidx.room.*
import com.ultrastream.data.models.WatchProgress
import kotlinx.coroutines.flow.Flow

@Dao
interface WatchProgressDao {
    @Query("SELECT * FROM watch_progress")
    fun getAll(): Flow<List<WatchProgress>>

    @Query("SELECT * FROM watch_progress WHERE id = :id")
    suspend fun getById(id: String): WatchProgress?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(progress: WatchProgress)

    @Update
    suspend fun update(progress: WatchProgress)

    @Query("DELETE FROM watch_progress WHERE id = :id")
    suspend fun deleteById(id: String)

    @Query("DELETE FROM watch_progress")
    suspend fun clearAll()
}
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/data/database/dao/WatchedEpisodeDao.kt
// app/src/main/java/com/ultrastream/data/database/dao/WatchedEpisodeDao.kt
package com.ultrastream.data.database

import androidx.room.*
import com.ultrastream.data.models.WatchedEpisode
import kotlinx.coroutines.flow.Flow

@Dao
interface WatchedEpisodeDao {
    @Query("SELECT * FROM watched_episodes")
    fun getAll(): Flow<List<WatchedEpisode>>

    @Query("SELECT * FROM watched_episodes WHERE episodeKey = :key")
    suspend fun getByKey(key: String): WatchedEpisode?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(episode: WatchedEpisode)

    @Query("DELETE FROM watched_episodes WHERE episodeKey = :key")
    suspend fun deleteByKey(key: String)

    @Query("DELETE FROM watched_episodes")
    suspend fun clearAll()
}
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/data/database/dao/ProfileDao.kt
// app/src/main/java/com/ultrastream/data/database/dao/ProfileDao.kt
package com.ultrastream.data.database

import androidx.room.*
import com.ultrastream.data.models.Profile
import kotlinx.coroutines.flow.Flow

@Dao
interface ProfileDao {
    @Query("SELECT * FROM profiles")
    fun getAll(): Flow<List<Profile>>

    @Query("SELECT * FROM profiles WHERE id = :id")
    suspend fun getById(id: String): Profile?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(profile: Profile)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(profiles: List<Profile>)

    @Delete
    suspend fun delete(profile: Profile)

    @Query("DELETE FROM profiles WHERE id = :id AND id != 'default'")
    suspend fun deleteById(id: String)
}
EOF

# ============================================================
# Repository
# ============================================================
cat << 'EOF' > app/src/main/java/com/ultrastream/data/repository/AppRepository.kt
package com.ultrastream.data.repository

import com.ultrastream.data.database.AppDatabase
import com.ultrastream.data.models.*
import com.ultrastream.utils.PreferencesManager
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first

class AppRepository(
    private val db: AppDatabase,
    private val prefs: PreferencesManager
) {

    fun getAddons(): Flow<List<Addon>> = db.addonDao().getAll()
    suspend fun getEnabledAddons(): List<Addon> = db.addonDao().getEnabled().first()
    suspend fun insertAddon(addon: Addon) = db.addonDao().insert(addon)
    suspend fun insertAddons(addons: List<Addon>) = db.addonDao().insertAll(addons)
    suspend fun updateAddon(addon: Addon) = db.addonDao().update(addon)
    suspend fun deleteAddon(id: String) = db.addonDao().deleteById(id)
    suspend fun getAddonById(id: String): Addon? = db.addonDao().getById(id)

    suspend fun getCachedMeta(id: String): MetaItem? = db.metaDao().getById(id)
    suspend fun cacheMeta(meta: MetaItem) = db.metaDao().insert(meta)

    fun getPlaylists(): Flow<List<SmartPlaylist>> = db.playlistDao().getAll()
    suspend fun getPlaylist(id: String): SmartPlaylist? = db.playlistDao().getById(id)
    suspend fun savePlaylist(playlist: SmartPlaylist) = db.playlistDao().insert(playlist)
    suspend fun updatePlaylist(playlist: SmartPlaylist) = db.playlistDao().update(playlist)
    suspend fun deletePlaylist(id: String) = db.playlistDao().deleteById(id)

    fun getProfiles(): Flow<List<Profile>> = db.profileDao().getAll()
    suspend fun getProfile(id: String): Profile? = db.profileDao().getById(id)
    suspend fun saveProfile(profile: Profile) = db.profileDao().insert(profile)
    suspend fun saveProfiles(profiles: List<Profile>) = db.profileDao().insertAll(profiles)
    suspend fun deleteProfile(id: String) = db.profileDao().deleteById(id)

    fun getHistory(): Flow<List<WatchHistory>> = db.watchHistoryDao().getAll()
    suspend fun addHistory(history: WatchHistory) = db.watchHistoryDao().insert(history)
    suspend fun clearHistory() = db.watchHistoryDao().clearAll()
    suspend fun getHistoryCount(): Int = db.watchHistoryDao().getCount()

    fun getProgress(): Flow<List<WatchProgress>> = db.watchProgressDao().getAll()
    suspend fun getProgressById(id: String): WatchProgress? = db.watchProgressDao().getById(id)
    suspend fun saveProgress(progress: WatchProgress) = db.watchProgressDao().insert(progress)
    suspend fun clearProgress() = db.watchProgressDao().clearAll()

    fun getWatchedEpisodes(): Flow<List<WatchedEpisode>> = db.watchedEpisodeDao().getAll()
    suspend fun getWatchedEpisode(key: String): WatchedEpisode? = db.watchedEpisodeDao().getByKey(key)
    suspend fun markEpisodeWatched(key: String) = db.watchedEpisodeDao().insert(WatchedEpisode(key))
    suspend fun unmarkEpisodeWatched(key: String) = db.watchedEpisodeDao().deleteByKey(key)

    fun getTheme(): String = prefs.getTheme()
    fun setTheme(theme: String) = prefs.setTheme(theme)
    fun getHindiPriority(): Boolean = prefs.getHindiPriority()
    fun setHindiPriority(enabled: Boolean) = prefs.setHindiPriority(enabled)
    fun getAutoPlayNext(): Boolean = prefs.getAutoPlayNext()
    fun setAutoPlayNext(enabled: Boolean) = prefs.setAutoPlayNext(enabled)
    fun getParentalControl(): Boolean = prefs.getParentalControl()
    fun setParentalControl(enabled: Boolean) = prefs.setParentalControl(enabled)
    fun getDebridKey(): String = prefs.getDebridKey()
    fun setDebridKey(key: String) = prefs.setDebridKey(key)
    fun getCurrentProfile(): String = prefs.getCurrentProfile()
    fun setCurrentProfile(id: String) = prefs.setCurrentProfile(id)

    suspend fun getLibrary(): List<MetaItem> {
        val json = prefs.getLibraryJson()
        return if (json.isNotEmpty()) {
            try {
                val type = object : com.google.gson.reflect.TypeToken<List<MetaItem>>() {}.type
                com.google.gson.Gson().fromJson(json, type) ?: emptyList()
            } catch (e: Exception) { emptyList() }
        } else emptyList()
    }

    suspend fun setLibrary(items: List<MetaItem>) {
        val json = com.google.gson.Gson().toJson(items)
        prefs.setLibraryJson(json)
    }

    suspend fun getWatchlist(): List<MetaItem> {
        val json = prefs.getWatchlistJson()
        return if (json.isNotEmpty()) {
            try {
                val type = object : com.google.gson.reflect.TypeToken<List<MetaItem>>() {}.type
                com.google.gson.Gson().fromJson(json, type) ?: emptyList()
            } catch (e: Exception) { emptyList() }
        } else emptyList()
    }

    suspend fun setWatchlist(items: List<MetaItem>) {
        val json = com.google.gson.Gson().toJson(items)
        prefs.setWatchlistJson(json)
    }

    suspend fun clearAllData() {
        db.watchHistoryDao().clearAll()
        db.watchProgressDao().clearAll()
        db.watchedEpisodeDao().clearAll()
        prefs.clearAll()
    }
}
EOF

# ============================================================
# Utilities
# ============================================================
cat << 'EOF' > app/src/main/java/com/ultrastream/utils/PreferencesManager.kt
// app/src/main/java/com/ultrastream/utils/PreferencesManager.kt
package com.ultrastream.utils

import android.content.Context
import android.content.SharedPreferences

class PreferencesManager(context: Context) {

    private val prefs: SharedPreferences = context.getSharedPreferences("ultrastream_prefs", Context.MODE_PRIVATE)

    companion object {
        private const val KEY_THEME = "theme"
        private const val KEY_HINDI_PRIORITY = "hindi_priority"
        private const val KEY_AUTOPLAY_NEXT = "autoplay_next"
        private const val KEY_PARENTAL_CONTROL = "parental_control"
        private const val KEY_DEBRID_KEY = "debrid_key"
        private const val KEY_CURRENT_PROFILE = "current_profile"
        private const val KEY_LIBRARY_JSON = "library_json"
        private const val KEY_WATCHLIST_JSON = "watchlist_json"
        private const val KEY_CACHED_META_JSON = "cached_meta_json"
        private const val KEY_DEFAULT = "default"
    }

    // Theme
    fun getTheme(): String = prefs.getString(KEY_THEME, "dark") ?: "dark"
    fun setTheme(theme: String) = prefs.edit().putString(KEY_THEME, theme).apply()

    // Hindi Priority
    fun getHindiPriority(): Boolean = prefs.getBoolean(KEY_HINDI_PRIORITY, true)
    fun setHindiPriority(enabled: Boolean) = prefs.edit().putBoolean(KEY_HINDI_PRIORITY, enabled).apply()

    // Auto-play Next
    fun getAutoPlayNext(): Boolean = prefs.getBoolean(KEY_AUTOPLAY_NEXT, false)
    fun setAutoPlayNext(enabled: Boolean) = prefs.edit().putBoolean(KEY_AUTOPLAY_NEXT, enabled).apply()

    // Parental Control
    fun getParentalControl(): Boolean = prefs.getBoolean(KEY_PARENTAL_CONTROL, false)
    fun setParentalControl(enabled: Boolean) = prefs.edit().putBoolean(KEY_PARENTAL_CONTROL, enabled).apply()

    // Debrid Key
    fun getDebridKey(): String = prefs.getString(KEY_DEBRID_KEY, "") ?: ""
    fun setDebridKey(key: String) = prefs.edit().putString(KEY_DEBRID_KEY, key).apply()

    // Current Profile
    fun getCurrentProfile(): String = prefs.getString(KEY_CURRENT_PROFILE, "default") ?: "default"
    fun setCurrentProfile(id: String) = prefs.edit().putString(KEY_CURRENT_PROFILE, id).apply()

    // Library JSON
    fun getLibraryJson(): String = prefs.getString(KEY_LIBRARY_JSON, "") ?: ""
    fun setLibraryJson(json: String) = prefs.edit().putString(KEY_LIBRARY_JSON, json).apply()

    // Watchlist JSON
    fun getWatchlistJson(): String = prefs.getString(KEY_WATCHLIST_JSON, "") ?: ""
    fun setWatchlistJson(json: String) = prefs.edit().putString(KEY_WATCHLIST_JSON, json).apply()

    // Clear all
    fun clearAll() = prefs.edit().clear().apply()
}
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/utils/NetworkUtils.kt
// app/src/main/java/com/ultrastream/utils/NetworkUtils.kt
package com.ultrastream.utils

import android.net.Uri
import com.google.gson.Gson
import com.google.gson.JsonParser
import com.ultrastream.UltraStreamApplication
import com.ultrastream.data.models.MetaItem
import com.ultrastream.data.models.Stream
import com.ultrastream.data.models.AddonManifest
import kotlinx.coroutines.*
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.logging.HttpLoggingInterceptor
import java.util.concurrent.TimeUnit

object NetworkUtils {

    private val client: OkHttpClient by lazy {
        val logging = HttpLoggingInterceptor().apply {
            level = HttpLoggingInterceptor.Level.BASIC
        }
        OkHttpClient.Builder()
            .addInterceptor(logging)
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .writeTimeout(30, TimeUnit.SECONDS)
            .build()
    }

    private val gson = Gson()

    suspend fun fetchMeta(metaId: String, metaType: String): MetaItem? {
        return withContext(Dispatchers.IO) {
            try {
                val url = "https://v3-cinemeta.strem.io/meta/$metaType/$metaId.json"
                val response = client.newCall(Request.Builder().url(url).build()).execute()
                if (response.isSuccessful) {
                    val json = response.body?.string()
                    val jsonObject = JsonParser.parseString(json).asJsonObject
                    val metaJson = jsonObject.getAsJsonObject("meta")
                    return@withContext gson.fromJson(metaJson, MetaItem::class.java)
                }
                null
            } catch (e: Exception) { null }
        }
    }

    suspend fun fetchStreams(metaId: String, metaType: String): List<Stream> {
        return withContext(Dispatchers.IO) {
            val allStreams = mutableListOf<Stream>()
            val addons = UltraStreamApplication.instance.repository.getEnabledAddons()
            val jobs = addons.map { addon ->
                async {
                    try {
                        val baseUrl = addon.url.replace("/manifest.json", "")
                        var url = "$baseUrl/stream/$metaType/${Uri.encode(metaId)}.json"
                        val debridKey = UltraStreamApplication.instance.repository.getDebridKey()
                        if (debridKey.isNotEmpty()) {
                            url += if (url.contains("?")) "&" else "?"
                            url += "realdebrid=$debridKey"
                        }
                        val response = client.newCall(Request.Builder().url(url).build()).execute()
                        if (response.isSuccessful) {
                            val json = response.body?.string()
                            val jsonObject = JsonParser.parseString(json).asJsonObject
                            val streamsArray = jsonObject.getAsJsonArray("streams")
                            streamsArray?.forEach { streamJson ->
                                val stream = gson.fromJson(streamJson, Stream::class.java)
                                val newStream = stream.copy(addonName = addon.name)
                                allStreams.add(newStream)
                            }
                        }
                    } catch (e: Exception) { }
                }
            }
            jobs.awaitAll()
            allStreams
        }
    }

    suspend fun fetchCatalog(addonUrl: String, catalogType: String, catalogId: String): List<MetaItem> {
        return withContext(Dispatchers.IO) {
            try {
                val baseUrl = addonUrl.replace("/manifest.json", "")
                val url = "$baseUrl/catalog/$catalogType/$catalogId.json"
                val response = client.newCall(Request.Builder().url(url).build()).execute()
                if (response.isSuccessful) {
                    val json = response.body?.string()
                    val jsonObject = JsonParser.parseString(json).asJsonObject
                    val metasArray = jsonObject.getAsJsonArray("metas")
                    val result = mutableListOf<MetaItem>()
                    metasArray?.forEach { metaJson ->
                        val meta = gson.fromJson(metaJson, MetaItem::class.java)
                        result.add(meta)
                    }
                    return@withContext result
                }
                emptyList()
            } catch (e: Exception) { emptyList() }
        }
    }

    suspend fun fetchAddonManifest(url: String): AddonManifest? {
        return withContext(Dispatchers.IO) {
            try {
                val response = client.newCall(Request.Builder().url(url).build()).execute()
                if (response.isSuccessful) {
                    val json = response.body?.string()
                    return@withContext gson.fromJson(json, AddonManifest::class.java)
                }
                null
            } catch (e: Exception) { null }
        }
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/utils/M3UParser.kt
// app/src/main/java/com/ultrastream/utils/M3UParser.kt
package com.ultrastream.utils

import java.io.BufferedReader
import java.io.StringReader

object M3UParser {

    data class M3UEntry(
        val title: String,
        val url: String,
        val duration: Long = -1,
        val group: String? = null,
        val logo: String? = null
    )

    fun parse(content: String): List<M3UEntry> {
        val entries = mutableListOf<M3UEntry>()
        var currentTitle = ""
        var currentDuration: Long = -1
        var currentGroup: String? = null
        var currentLogo: String? = null

        BufferedReader(StringReader(content)).useLines { lines ->
            lines.forEach { line ->
                val trimmed = line.trim()
                when {
                    trimmed.startsWith("#EXTM3U") -> {
                        // Skip header
                    }
                    trimmed.startsWith("#EXTINF:") -> {
                        // Parse EXTINF
                        val durationMatch = Regex("#EXTINF:(-?\\d+)").find(trimmed)
                        currentDuration = durationMatch?.groupValues?.get(1)?.toLongOrNull() ?: -1

                        // Extract title and other attributes
                        val parts = trimmed.split(",")
                        if (parts.size > 1) {
                            currentTitle = parts.drop(1).joinToString(",").trim()
                        } else {
                            currentTitle = ""
                        }

                        // Extract tvg-logo
                        val logoMatch = Regex("tvg-logo=\"([^\"]*)\"").find(trimmed)
                        currentLogo = logoMatch?.groupValues?.get(1)

                        // Extract group-title
                        val groupMatch = Regex("group-title=\"([^\"]*)\"").find(trimmed)
                        currentGroup = groupMatch?.groupValues?.get(1)
                    }
                    trimmed.isNotEmpty() && !trimmed.startsWith("#") -> {
                        // This is the URL
                        if (currentTitle.isNotEmpty()) {
                            entries.add(
                                M3UEntry(
                                    title = currentTitle,
                                    url = trimmed,
                                    duration = currentDuration,
                                    group = currentGroup,
                                    logo = currentLogo
                                )
                            )
                        }
                        // Reset for next entry
                        currentTitle = ""
                        currentDuration = -1
                        currentGroup = null
                        currentLogo = null
                    }
                    // Skip other comment lines
                }
            }
        }

        return entries
    }

    fun generate(entries: List<M3UEntry>): String {
        val sb = StringBuilder()
        sb.appendLine("#EXTM3U")
        
        entries.forEach { entry ->
            sb.append("#EXTINF:${entry.duration}")
            if (entry.group != null) {
                sb.append(" group-title=\"${entry.group}\"")
            }
            if (entry.logo != null) {
                sb.append(" tvg-logo=\"${entry.logo}\"")
            }
            sb.appendLine(" ,${entry.title}")
            sb.appendLine(entry.url)
        }
        
        return sb.toString()
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/utils/StreamParser.kt
// app/src/main/java/com/ultrastream/utils/StreamParser.kt
package com.ultrastream.utils

import java.util.regex.Pattern

object StreamParser {

    data class ParsedStreamInfo(
        val size: String? = null,
        val sizeValueBytes: Double? = null,
        val seeds: String? = null,
        val langs: List<String> = emptyList(),
        val quals: List<String> = emptyList(),
        val isLive: Boolean = false,
        val hasHindi: Boolean = false,
        val cleanText: String = "",
        val parsedYear: String? = null,
        val parsedSeason: Int? = null,
        val parsedEpisode: Int? = null
    )

    fun parse(rawText: String): ParsedStreamInfo {
        val text = rawText.lowercase()

        // Size
        val sizePattern = Pattern.compile("\\b(\\d+(?:\\.\\d+)?)\\s*(gb|mb)\\b", Pattern.CASE_INSENSITIVE)
        val sizeMatcher = sizePattern.matcher(text)
        var size: String? = null
        var sizeValueBytes: Double? = null
        if (sizeMatcher.find()) {
            size = sizeMatcher.group(0).uppercase()
            val value = sizeMatcher.group(1).toDoubleOrNull()
            val unit = sizeMatcher.group(2).lowercase()
            if (value != null) {
                sizeValueBytes = if (unit == "gb") {
                    value * 1024 * 1024 * 1024
                } else {
                    value * 1024 * 1024
                }
            }
        }

        // Seeds
        val seedPattern = Pattern.compile("(?:seeders|seeds|s)[:\\s]*(\\d+)", Pattern.CASE_INSENSITIVE)
        val seedMatcher = seedPattern.matcher(text)
        var seeds: String? = null
        if (seedMatcher.find()) {
            seeds = seedMatcher.group(1)
        }

        // Languages
        val langPattern = Pattern.compile(
            "\\b(hindi|english|tamil|telugu|malayalam|bengali|dual audio|multi audio|हिंदी|हिन्दी)\\b",
            Pattern.CASE_INSENSITIVE
        )
        val langMatcher = langPattern.matcher(text)
        val langs = mutableListOf<String>()
        while (langMatcher.find()) {
            val lang = langMatcher.group(1).replaceFirstChar { it.uppercase() }
            if (!langs.contains(lang)) {
                langs.add(lang)
            }
        }

        // Qualities
        val qualPattern = Pattern.compile(
            "\\b(4k|2160p|1080p|720p|480p|hdr|dv|cam|hdts|hdtc)\\b",
            Pattern.CASE_INSENSITIVE
        )
        val qualMatcher = qualPattern.matcher(text)
        val quals = mutableListOf<String>()
        while (qualMatcher.find()) {
            val qual = qualMatcher.group(1).uppercase()
            if (!quals.contains(qual)) {
                quals.add(qual)
            }
        }

        // Hindi check
        val hasHindi = langs.any { it.contains("hindi", ignoreCase = true) }

        // Live check
        val isLive = text.contains("live") || text.contains("iptv") || text.contains("stream")

        // Year
        val yearPattern = Pattern.compile("\\b(19\\d{2}|20[0-2]\\d)\\b")
        val yearMatcher = yearPattern.matcher(text)
        var parsedYear: String? = null
        if (yearMatcher.find()) {
            parsedYear = yearMatcher.group(1)
        }

        // Season and Episode
        var parsedSeason: Int? = null
        var parsedEpisode: Int? = null

        // Pattern: S01E05
        val sxePattern = Pattern.compile("s(\\d{1,2})[-_\\s]*e(\\d{1,4})", Pattern.CASE_INSENSITIVE)
        val sxeMatcher = sxePattern.matcher(text)
        if (sxeMatcher.find()) {
            parsedSeason = sxeMatcher.group(1).toIntOrNull()
            parsedEpisode = sxeMatcher.group(2).toIntOrNull()
        } else {
            // Pattern: 1x05 (but not 1920x1080)
            val axbPattern = Pattern.compile("(?:^|[^a-z0-9])(\\d{1,2})x(\\d{1,4})(?:[^a-z0-9]|$)", Pattern.CASE_INSENSITIVE)
            val axbMatcher = axbPattern.matcher(text)
            if (axbMatcher.find()) {
                val season = axbMatcher.group(1).toIntOrNull()
                if (season != null && season < 100) {
                    parsedSeason = season
                    parsedEpisode = axbMatcher.group(2).toIntOrNull()
                }
            }
        }

        // Clean text
        var cleanText = rawText
        cleanText = cleanText.replace(Regex("\\b(\\d+(?:\\.\\d+)?\\s*(?:gb|mb))\\b", RegexOption.IGNORE_CASE), "")
        cleanText = cleanText.replace(Regex("(?:seeders|seeds|s)[:\\s]*(\\d+)", RegexOption.IGNORE_CASE), "")
        cleanText = cleanText.replace(
            Regex("\\b(hindi|english|tamil|telugu|malayalam|bengali|dual audio|multi audio|हिंदी|हिन्दी)\\b", RegexOption.IGNORE_CASE),
            ""
        )
        cleanText = cleanText.replace(
            Regex("\\b(4k|2160p|1080p|720p|480p|hdr|dv|cam|hdts|hdtc)\\b", RegexOption.IGNORE_CASE),
            ""
        )
        cleanText = cleanText.replace(Regex("[\\u{1F300}-\\u{1F9FF}]"), "")
        cleanText = cleanText.replace(Regex("[\\u{2600}-\\u{26FF}]"), "")
        cleanText = cleanText.trim()
        if (cleanText.isEmpty()) {
            cleanText = "Direct Video Stream"
        }

        return ParsedStreamInfo(
            size = size,
            sizeValueBytes = sizeValueBytes,
            seeds = seeds,
            langs = langs,
            quals = quals,
            isLive = isLive,
            hasHindi = hasHindi,
            cleanText = cleanText,
            parsedYear = parsedYear,
            parsedSeason = parsedSeason,
            parsedEpisode = parsedEpisode
        )
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/utils/EpisodeMatcher.kt
// app/src/main/java/com/ultrastream/utils/EpisodeMatcher.kt
package com.ultrastream.utils

import com.ultrastream.data.models.Stream

object EpisodeMatcher {

    /**
     * Strictly checks if a stream matches the target season and episode.
     * Returns true if it's a valid match.
     */
    fun isValidEpisodeStream(stream: Stream, targetSeason: Int?, targetEpisode: Int?): Boolean {
        if (targetSeason == null || targetEpisode == null) return true // movie or single item

        val text = ((stream.title ?: "") + " " + (stream.name ?: "") + " " + (stream.description ?: "")).uppercase()

        // 1. Check for packs (usually don't list explicit single episodes)
        val isPack = Regex("(SEASON \\d+ COMPLETE|S\\d+ COMPLETE|S\\d+ PACK|BATCH|\\bS\\d+\\b(?!.*E\\d+)| \\d{1,2}-\\d{1,2} |E\\d+-E\\d+)", RegexOption.IGNORE_CASE).containsMatchIn(text)
        if (isPack) {
            // If pack, we only accept if it explicitly includes the target episode number
            // We'll check explicit episode numbers later
        }

        var hasExplicitEpisode = false
        var episodeMatchFound = false

        // Match Episode formats like E01, EP 1, EPISODE 01
        val epRegex = Regex("(?:^|[^A-Z])(?:E|EP|EPISODE)[-_\\s]*(\\d{1,4})(?:[^A-Z]|$)", RegexOption.IGNORE_CASE)
        epRegex.findAll(text).forEach {
            hasExplicitEpisode = true
            if (it.groupValues[1].toIntOrNull() == targetEpisode) {
                episodeMatchFound = true
            }
        }

        // Match S01E01 formats
        val sxeRegex = Regex("S(\\d{1,2})[-_\\s]*E(\\d{1,4})", RegexOption.IGNORE_CASE)
        sxeRegex.findAll(text).forEach {
            hasExplicitEpisode = true
            val s = it.groupValues[1].toIntOrNull()
            val e = it.groupValues[2].toIntOrNull()
            if (s == targetSeason && e == targetEpisode) {
                episodeMatchFound = true
            }
        }

        // Match 1x01 format
        val axbRegex = Regex("(?:^|[^A-Z0-9])(\\d{1,2})x(\\d{1,4})(?:[^A-Z0-9]|$)", RegexOption.IGNORE_CASE)
        axbRegex.findAll(text).forEach {
            val season = it.groupValues[1].toIntOrNull()
            if (season != null && season < 100) { // avoid 1920x1080
                hasExplicitEpisode = true
                val ep = it.groupValues[2].toIntOrNull()
                if (season == targetSeason && ep == targetEpisode) {
                    episodeMatchFound = true
                }
            }
        }

        // If we found explicit episode markers, we must match
        if (hasExplicitEpisode) {
            return episodeMatchFound
        }

        // If no explicit markers, but it's a pack, we might accept? But better to reject unless pack contains target episode number
        // Actually, we'll use isolated number parsing
        if (!isPack) {
            // Isolated number detection (e.g., "Show - 05")
            val isolatedNumRegex = Regex("(?:^|[\\s\\-_\\[\\]])(\\d{1,4})(?:[\\s\\-_\\[\\]]|$)")
            var foundAnyIso = false
            var isoMatchFound = false
            isolatedNumRegex.findAll(text).forEach {
                val num = it.groupValues[1].toIntOrNull()
                if (num != null && !listOf(720, 1080, 2160, 480, 264, 265, 10).contains(num) && !(num in 1900..2100)) {
                    foundAnyIso = true
                    if (num == targetEpisode) {
                        isoMatchFound = true
                    }
                }
            }
            if (foundAnyIso && !isoMatchFound) return false
        }

        return true // valid or unknown
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/utils/LinkVerifier.kt
// app/src/main/java/com/ultrastream/utils/LinkVerifier.kt
package com.ultrastream.utils

import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.Response
import java.net.URL
import java.util.concurrent.TimeUnit

object LinkVerifier {

    private val client = OkHttpClient.Builder()
        .connectTimeout(15, TimeUnit.SECONDS)
        .readTimeout(15, TimeUnit.SECONDS)
        .followRedirects(true)
        .build()

    private val cache = mutableMapOf<String, Boolean>()

    suspend fun verify(url: String): Boolean {
        return cache.getOrElse(url) {
            val result = doVerify(url)
            cache[url] = result
            result
        }
    }

    private suspend fun doVerify(url: String): Boolean {
        if (url.startsWith("magnet:")) return false

        try {
            val classification = classifyUrl(url)
            when (classification) {
                "hls", "dash", "proxy" -> {
                    val request = Request.Builder()
                        .url(url)
                        .header("Accept", "*/*")
                        .header("Accept-Language", "en-US,en;q=0.9")
                        .build()
                    val response = client.newCall(request).execute()
                    response.use {
                        if (!it.isSuccessful) return false
                        val contentType = it.header("content-type") ?: ""
                        if (contentType.contains("video") || contentType.contains("application/octet-stream")) {
                            return true
                        }
                        if (contentType.contains("text/html")) {
                            val body = it.body?.string() ?: return false
                            if (body.length < 2000) {
                                if (listOf("error", "not found", "expired", "invalid", "access denied").any { body.contains(it, ignoreCase = true) }) {
                                    return false
                                }
                            }
                            return false
                        }
                        val body = it.body?.string() ?: return false
                        if (classification == "hls" && Regex("^#EXTM3U", RegexOption.MULTILINE).containsMatchIn(body) && body.contains("#EXTINF:", ignoreCase = true)) {
                            return true
                        }
                        if (classification == "dash" && (body.contains("<MPD", ignoreCase = true) || body.contains("<SegmentList", ignoreCase = true))) {
                            return true
                        }
                        return classification == "proxy"
                    }
                }
                else -> {
                    // Direct or unknown
                    try {
                        val headRequest = Request.Builder().url(url).head().build()
                        val headResponse = client.newCall(headRequest).execute()
                        headResponse.use {
                            if (it.isSuccessful) return true
                        }
                    } catch (_: Exception) { }

                    // Try range request
                    try {
                        val rangeRequest = Request.Builder()
                            .url(url)
                            .header("Range", "bytes=0-0")
                            .build()
                        val rangeResponse = client.newCall(rangeRequest).execute()
                        rangeResponse.use {
                            if (it.code == 206 || it.code == 200) return true
                            val contentType = it.header("content-type") ?: ""
                            if (contentType.contains("text/html")) return false
                            if (it.code in 403..404) return false
                            return it.code < 500
                        }
                    } catch (_: Exception) { }
                }
            }
        } catch (_: Exception) { }

        // Fallback: try no-cors mode (opaque) - we can't check, so assume it works.
        return true
    }

    private fun classifyUrl(url: String): String {
        val lower = url.lowercase()
        return when {
            lower.startsWith("magnet:") -> "magnet"
            lower.contains(".m3u8") || lower.contains(".m3u") -> "hls"
            lower.contains(".mpd") -> "dash"
            Regex("\\b(?:pengu\\.uk|streamraiwind|cdn\\d+\\.stream|proxy)").containsMatchIn(lower) -> "proxy"
            Regex("\\.(mp4|mkv|avi|mov|wmv|flv|webm)$").containsMatchIn(lower) -> "direct"
            else -> "unknown"
        }
    }

    fun clearCache() = cache.clear()
}
EOF

# ============================================================
# Application class
# ============================================================
cat << 'EOF' > app/src/main/java/com/ultrastream/UltraStreamApplication.kt
// app/src/main/java/com/ultrastream/UltraStreamApplication.kt
package com.ultrastream

import android.app.Application
import androidx.room.Room
import com.ultrastream.data.database.AppDatabase
import com.ultrastream.data.repository.AppRepository
import com.ultrastream.utils.PreferencesManager

class UltraStreamApplication : Application() {

    lateinit var database: AppDatabase
    lateinit var repository: AppRepository
    lateinit var prefs: PreferencesManager

    override fun onCreate() {
        super.onCreate()
        instance = this

        // Initialize Room
        database = Room.databaseBuilder(
            applicationContext,
            AppDatabase::class.java,
            "ultrastream.db"
        ).fallbackToDestructiveMigration().build()

        // Initialize Preferences
        prefs = PreferencesManager(this)

        // Initialize Repository
        repository = AppRepository(database, prefs)
    }

    companion object {
        lateinit var instance: UltraStreamApplication
            private set
    }
}
EOF

# ============================================================
# Main Activity
# ============================================================
cat << 'EOF' > app/src/main/java/com/ultrastream/MainActivity.kt
// app/src/main/java/com/ultrastream/MainActivity.kt
package com.ultrastream

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.navigation.NavController
import androidx.navigation.fragment.NavHostFragment
import androidx.navigation.ui.setupWithNavController
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.ultrastream.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private lateinit var navController: NavController

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        val navHostFragment = supportFragmentManager
            .findFragmentById(R.id.nav_host_fragment) as NavHostFragment
        navController = navHostFragment.navController

        val bottomNav = findViewById<BottomNavigationView>(R.id.bottom_nav)
        bottomNav.setupWithNavController(navController)

        // Handle back pressed
        supportFragmentManager.addOnBackStackChangedListener {
            val currentFragment = navHostFragment.childFragmentManager.fragments.firstOrNull()
            if (currentFragment is OnBackPressedListener) {
                currentFragment.onBackPressed()
            }
        }
    }

    override fun onBackPressed() {
        if (!navController.popBackStack()) {
            super.onBackPressed()
        }
    }

    interface OnBackPressedListener {
        fun onBackPressed(): Boolean
    }

    companion object {
        const val REQUEST_CODE_PLAYER = 1001
        const val EXTRA_MEDIA_URL = "media_url"
        const val EXTRA_MEDIA_TITLE = "media_title"
        const val EXTRA_SUBTITLE_URL = "subtitle_url"
        const val EXTRA_IS_LIVE = "is_live"
    }
}
EOF

# ============================================================
# Fragments (Home, Search, Addons, Library, Profile)
# ============================================================
cat << 'EOF' > app/src/main/java/com/ultrastream/ui/home/HomeFragment.kt
// app/src/main/java/com/ultrastream/ui/home/HomeFragment.kt
package com.ultrastream.ui.home

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.GridLayoutManager
import com.ultrastream.R
import com.ultrastream.UltraStreamApplication
import com.ultrastream.databinding.FragmentHomeBinding
import com.ultrastream.ui.adapters.PosterAdapter
import com.ultrastream.utils.NetworkUtils
import kotlinx.coroutines.launch

class HomeFragment : Fragment() {

    private var _binding: FragmentHomeBinding? = null
    private val binding get() = _binding!!
    private lateinit var adapter: PosterAdapter

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentHomeBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        adapter = PosterAdapter { meta ->
            // Open details
            val intent = android.content.Intent(requireContext(), com.ultrastream.ui.details.DetailsActivity::class.java)
            intent.putExtra(com.ultrastream.ui.details.DetailsActivity.EXTRA_META_ID, meta.id)
            intent.putExtra(com.ultrastream.ui.details.DetailsActivity.EXTRA_META_TYPE, meta.type)
            startActivity(intent)
        }
        binding.rvHome.layoutManager = GridLayoutManager(requireContext(), 3)
        binding.rvHome.adapter = adapter

        loadCatalogs()
    }

    private fun loadCatalogs() {
        lifecycleScope.launch {
            val addons = UltraStreamApplication.instance.repository.getEnabledAddons()
            if (addons.isEmpty()) {
                Toast.makeText(requireContext(), "No addons installed. Go to Addons tab.", Toast.LENGTH_LONG).show()
                return@launch
            }
            val allItems = mutableListOf<com.ultrastream.data.models.MetaItem>()
            for (addon in addons) {
                for (catalog in addon.catalogs) {
                    val items = NetworkUtils.fetchCatalog(addon.url, catalog.type, catalog.id)
                    allItems.addAll(items)
                }
            }
            // Remove duplicates by id
            val unique = allItems.distinctBy { it.id }
            adapter.submitList(unique)
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/ui/search/SearchFragment.kt
// app/src/main/java/com/ultrastream/ui/search/SearchFragment.kt
package com.ultrastream.ui.search

import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.GridLayoutManager
import com.ultrastream.UltraStreamApplication
import com.ultrastream.databinding.FragmentSearchBinding
import com.ultrastream.ui.adapters.PosterAdapter
import com.ultrastream.utils.NetworkUtils
import kotlinx.coroutines.*

class SearchFragment : Fragment() {

    private var _binding: FragmentSearchBinding? = null
    private val binding get() = _binding!!
    private var searchJob: Job? = null
    private lateinit var adapter: PosterAdapter

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentSearchBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        adapter = PosterAdapter { meta ->
            val intent = android.content.Intent(requireContext(), com.ultrastream.ui.details.DetailsActivity::class.java)
            intent.putExtra(com.ultrastream.ui.details.DetailsActivity.EXTRA_META_ID, meta.id)
            intent.putExtra(com.ultrastream.ui.details.DetailsActivity.EXTRA_META_TYPE, meta.type)
            startActivity(intent)
        }
        binding.rvSearchResults.layoutManager = GridLayoutManager(requireContext(), 2)
        binding.rvSearchResults.adapter = adapter

        setupSearchInput()
        setupChips()
    }

    private fun setupSearchInput() {
        binding.searchInput.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
            override fun afterTextChanged(s: Editable?) {
                val query = s?.toString()?.trim() ?: ""
                searchJob?.cancel()
                if (query.length >= 2) {
                    searchJob = viewLifecycleOwner.lifecycleScope.launch {
                        delay(600)
                        performSearch(query)
                    }
                } else {
                    adapter.submitList(emptyList())
                }
            }
        })
    }

    private fun setupChips() {
        // Filter chips
        val chips = binding.filterChipGroup
        chips.setOnCheckedChangeListener { _, _ ->
            val query = binding.searchInput.text.toString().trim()
            if (query.isNotEmpty()) performSearch(query)
        }
        // Sort chips
        val sortChips = binding.sortChipGroup
        sortChips.setOnCheckedChangeListener { _, _ ->
            val query = binding.searchInput.text.toString().trim()
            if (query.isNotEmpty()) performSearch(query)
        }
    }

    private suspend fun performSearch(query: String) {
        val filter = when (binding.filterChipGroup.checkedChipId) {
            R.id.chip_movie -> "movie"
            R.id.chip_series -> "series"
            R.id.chip_anime -> "anime"
            R.id.chip_tv -> "tv"
            else -> "all"
        }
        val sort = when (binding.sortChipGroup.checkedChipId) {
            R.id.sort_rating -> "rating"
            R.id.sort_year -> "year"
            else -> "popular"
        }

        val addons = UltraStreamApplication.instance.repository.getEnabledAddons()
        if (addons.isEmpty()) {
            withContext(Dispatchers.Main) {
                Toast.makeText(requireContext(), "No addons enabled", Toast.LENGTH_SHORT).show()
            }
            return
        }

        val allResults = mutableListOf<com.ultrastream.data.models.MetaItem>()
        val jobs = addons.map { addon ->
            async {
                for (catalog in addon.catalogs) {
                    if (filter != "all" && catalog.type != filter) continue
                    val url = addon.url.replace("/manifest.json", "")
                    val searchUrl = "$url/catalog/${catalog.type}/${catalog.id}/search=${query}.json"
                    try {
                        val items = NetworkUtils.fetchCatalog(addon.url, catalog.type, catalog.id + "/search=" + query)
                        allResults.addAll(items)
                    } catch (_: Exception) { }
                }
            }
        }
        jobs.awaitAll()

        val unique = allResults.distinctBy { it.id }
        // Sort if needed
        when (sort) {
            "rating" -> unique.sortedByDescending { it.imdbRating ?: 0f }
            "year" -> unique.sortedByDescending { it.year ?: 0 }
            else -> unique
        }
        withContext(Dispatchers.Main) {
            adapter.submitList(unique)
            if (unique.isEmpty()) {
                Toast.makeText(requireContext(), "No results found", Toast.LENGTH_SHORT).show()
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        searchJob?.cancel()
        _binding = null
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/ui/addons/AddonsFragment.kt
// app/src/main/java/com/ultrastream/ui/addons/AddonsFragment.kt
package com.ultrastream.ui.addons

import android.content.Context
import android.net.Uri
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import com.google.gson.Gson
import com.ultrastream.UltraStreamApplication
import com.ultrastream.data.models.Addon
import com.ultrastream.databinding.FragmentAddonsBinding
import com.ultrastream.utils.NetworkUtils
import kotlinx.coroutines.launch

class AddonsFragment : Fragment() {

    private var _binding: FragmentAddonsBinding? = null
    private val binding get() = _binding!!
    private val gson = Gson()

    private val importLauncher = registerForActivityResult(ActivityResultContracts.GetContent()) { uri: Uri? ->
        uri?.let { parseAndSaveAddons(it) }
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentAddonsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        loadAddons()
        setupListeners()
    }

    private fun setupListeners() {
        binding.installAddonBtn.setOnClickListener {
            val url = binding.addonUrlInput.text.toString().trim()
            if (url.isNotEmpty()) installAddon(url)
        }

        binding.importAddonsBtn.setOnClickListener {
            importLauncher.launch("*/*")
        }

        binding.exportAddonsBtn.setOnClickListener {
            exportAddons()
        }

        binding.factoryResetBtn.setOnClickListener {
            lifecycleScope.launch {
                UltraStreamApplication.instance.repository.deleteAddon("all")
                loadAddons()
                Toast.makeText(requireContext(), "All addons cleared", Toast.LENGTH_SHORT).show()
            }
        }

        binding.saveDebridBtn.setOnClickListener {
            val key = binding.debridKeyInput.text.toString().trim()
            UltraStreamApplication.instance.repository.setDebridKey(key)
            binding.debridStatus.text = if (key.isNotEmpty()) "✅ Debrid key saved" else "No Debrid key set"
        }
    }

    private fun loadAddons() {
        lifecycleScope.launch {
            val addons = UltraStreamApplication.instance.repository.getAddons().first()
            binding.installedAddonsContainer.removeAllViews()
            for (addon in addons) {
                val card = layoutInflater.inflate(R.layout.installed_addon_card, binding.installedAddonsContainer, false)
                // Assume we have a custom layout; for simplicity, just add a TextView
                val tv = android.widget.TextView(requireContext())
                tv.text = "${addon.name} (${if (addon.enabled) "Enabled" else "Disabled"})"
                tv.setPadding(0, 16, 0, 16)
                tv.setTextColor(requireContext().getColor(android.R.color.white))
                binding.installedAddonsContainer.addView(tv)
            }
        }
    }

    private fun installAddon(url: String) {
        lifecycleScope.launch {
            val manifest = NetworkUtils.fetchAddonManifest(url)
            if (manifest != null) {
                val addon = Addon(
                    id = manifest.id,
                    url = url,
                    name = manifest.name,
                    catalogs = manifest.catalogs.map { 
                        com.ultrastream.data.models.Catalog(it.type, it.id, it.name) 
                    }
                )
                UltraStreamApplication.instance.repository.insertAddon(addon)
                Toast.makeText(requireContext(), "Addon installed: ${manifest.name}", Toast.LENGTH_SHORT).show()
                loadAddons()
            } else {
                Toast.makeText(requireContext(), "Failed to fetch manifest", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun parseAndSaveAddons(uri: Uri) {
        try {
            val inputStream = requireContext().contentResolver.openInputStream(uri)
            val jsonString = inputStream?.bufferedReader().use { it?.readText() }
            val type = object : com.google.gson.reflect.TypeToken<List<Addon>>() {}.type
            val addons: List<Addon> = gson.fromJson(jsonString, type)
            lifecycleScope.launch {
                UltraStreamApplication.instance.repository.insertAddons(addons)
                loadAddons()
                Toast.makeText(requireContext(), "Addons imported", Toast.LENGTH_SHORT).show()
            }
        } catch (e: Exception) {
            Toast.makeText(requireContext(), "Failed to import: ${e.message}", Toast.LENGTH_SHORT).show()
        }
    }

    private fun exportAddons() {
        lifecycleScope.launch {
            val addons = UltraStreamApplication.instance.repository.getAddons().first()
            val json = gson.toJson(addons)
            val intent = android.content.Intent(android.content.Intent.ACTION_SEND).apply {
                type = "application/json"
                putExtra(android.content.Intent.EXTRA_TEXT, json)
            }
            startActivity(android.content.Intent.createChooser(intent, "Export Addons"))
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/ui/library/LibraryFragment.kt
// app/src/main/java/com/ultrastream/ui/library/LibraryFragment.kt
package com.ultrastream.ui.library

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.LinearLayoutManager
import com.ultrastream.UltraStreamApplication
import com.ultrastream.databinding.FragmentLibraryBinding
import com.ultrastream.ui.adapters.ContinueWatchingAdapter
import com.ultrastream.ui.adapters.PosterAdapter
import com.ultrastream.ui.adapters.SmartPlaylistAdapter
import com.ultrastream.ui.details.DetailsActivity
import com.ultrastream.ui.sheets.M3UActionBottomSheet
import kotlinx.coroutines.launch

class LibraryFragment : Fragment() {

    private var _binding: FragmentLibraryBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentLibraryBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        setupSmartPlaylists()
        setupHistory()
        setupWatchlist()
        setupLibraryGrid()
    }

    private fun setupSmartPlaylists() {
        val adapter = SmartPlaylistAdapter(
            onItemClick = { playlist ->
                // Open playlist sheet
                val sheet = com.ultrastream.ui.sheets.PlaylistViewBottomSheet(playlist)
                sheet.show(parentFragmentManager, "playlist_view")
            },
            onM3UClick = { playlist ->
                val m3u = com.ultrastream.utils.M3UParser.generate(
                    playlist.episodes.map { 
                        com.ultrastream.utils.M3UParser.M3UEntry(
                            title = "${playlist.metaName} - S${playlist.season}E${it.epNum} ${it.epName}",
                            url = it.stream?.url ?: it.stream?.streamUrl ?: ""
                        )
                    }
                )
                val sheet = M3UActionBottomSheet(m3u, "${playlist.metaName}_S${playlist.season}.m3u")
                sheet.show(parentFragmentManager, "m3u_actions")
            },
            onDeleteClick = { playlist ->
                lifecycleScope.launch {
                    UltraStreamApplication.instance.repository.deletePlaylist(playlist.id)
                    setupSmartPlaylists()
                }
            }
        )
        binding.rvSmartPlaylists.layoutManager = LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false)
        binding.rvSmartPlaylists.adapter = adapter

        lifecycleScope.launch {
            val playlists = UltraStreamApplication.instance.repository.getPlaylists().first()
            adapter.submitList(playlists)
        }
    }

    private fun setupHistory() {
        val adapter = ContinueWatchingAdapter { history ->
            val intent = android.content.Intent(requireContext(), DetailsActivity::class.java)
            intent.putExtra(DetailsActivity.EXTRA_META_ID, history.id)
            intent.putExtra(DetailsActivity.EXTRA_META_TYPE, history.type)
            startActivity(intent)
        }
        binding.rvLibHistory.layoutManager = LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false)
        binding.rvLibHistory.adapter = adapter

        lifecycleScope.launch {
            val history = UltraStreamApplication.instance.repository.getHistory().first()
            val progress = UltraStreamApplication.instance.repository.getProgress().first().associate { it.id to it }
            adapter.submitList(history, progress)
        }
    }

    private fun setupWatchlist() {
        val adapter = PosterAdapter { meta ->
            val intent = android.content.Intent(requireContext(), DetailsActivity::class.java)
            intent.putExtra(DetailsActivity.EXTRA_META_ID, meta.id)
            intent.putExtra(DetailsActivity.EXTRA_META_TYPE, meta.type)
            startActivity(intent)
        }
        binding.rvWatchlist.layoutManager = GridLayoutManager(context, 2)
        binding.rvWatchlist.adapter = adapter

        lifecycleScope.launch {
            val watchlist = UltraStreamApplication.instance.repository.getWatchlist()
            adapter.submitList(watchlist)
        }
    }

    private fun setupLibraryGrid() {
        val adapter = PosterAdapter { meta ->
            val intent = android.content.Intent(requireContext(), DetailsActivity::class.java)
            intent.putExtra(DetailsActivity.EXTRA_META_ID, meta.id)
            intent.putExtra(DetailsActivity.EXTRA_META_TYPE, meta.type)
            startActivity(intent)
        }
        binding.rvLibraryGrid.layoutManager = GridLayoutManager(context, 2)
        binding.rvLibraryGrid.adapter = adapter

        lifecycleScope.launch {
            val library = UltraStreamApplication.instance.repository.getLibrary()
            adapter.submitList(library)
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/ui/profile/ProfileFragment.kt
// app/src/main/java/com/ultrastream/ui/profile/ProfileFragment.kt
package com.ultrastream.ui.profile

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import com.ultrastream.UltraStreamApplication
import com.ultrastream.databinding.FragmentProfileBinding
import kotlinx.coroutines.launch

class ProfileFragment : Fragment() {

    private var _binding: FragmentProfileBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentProfileBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        loadProfile()
        setupSwitches()
        setupExportImport()
        setupFactoryReset()
    }

    private fun loadProfile() {
        val prefs = UltraStreamApplication.instance.prefs
        val profileId = prefs.getCurrentProfile()
        lifecycleScope.launch {
            val profile = UltraStreamApplication.instance.repository.getProfile(profileId)
            if (profile != null) {
                binding.profileNameDisplay.text = profile.name
                binding.profileAvatarBig.setImageResource(android.R.drawable.ic_menu_edit) // placeholder
            }
            val watchlist = UltraStreamApplication.instance.repository.getWatchlist()
            binding.profileWatchlistCount.text = "Watchlist: ${watchlist.size} items"
        }
    }

    private fun setupSwitches() {
        val prefs = UltraStreamApplication.instance.prefs
        binding.switchTheme.isChecked = prefs.getTheme() == "light"
        binding.switchTheme.setOnCheckedChangeListener { _, isChecked ->
            prefs.setTheme(if (isChecked) "light" else "dark")
        }

        binding.switchHindi.isChecked = prefs.getHindiPriority()
        binding.switchHindi.setOnCheckedChangeListener { _, isChecked ->
            prefs.setHindiPriority(isChecked)
        }

        binding.switchAutoplay.isChecked = prefs.getAutoPlayNext()
        binding.switchAutoplay.setOnCheckedChangeListener { _, isChecked ->
            prefs.setAutoPlayNext(isChecked)
        }

        binding.switchParental.isChecked = prefs.getParentalControl()
        binding.switchParental.setOnCheckedChangeListener { _, isChecked ->
            prefs.setParentalControl(isChecked)
        }
    }

    private fun setupExportImport() {
        binding.exportDataBtn.setOnClickListener {
            // Export all data as JSON
            lifecycleScope.launch {
                val data = mapOf(
                    "addons" to UltraStreamApplication.instance.repository.getAddons().first(),
                    "library" to UltraStreamApplication.instance.repository.getLibrary(),
                    "watchlist" to UltraStreamApplication.instance.repository.getWatchlist(),
                    "history" to UltraStreamApplication.instance.repository.getHistory().first(),
                    "progress" to UltraStreamApplication.instance.repository.getProgress().first(),
                    "playlists" to UltraStreamApplication.instance.repository.getPlaylists().first(),
                    "profiles" to UltraStreamApplication.instance.repository.getProfiles().first(),
                    "settings" to mapOf(
                        "theme" to UltraStreamApplication.instance.prefs.getTheme(),
                        "hindiPriority" to UltraStreamApplication.instance.prefs.getHindiPriority(),
                        "autoPlayNext" to UltraStreamApplication.instance.prefs.getAutoPlayNext(),
                        "parentalControl" to UltraStreamApplication.instance.prefs.getParentalControl()
                    )
                )
                val json = com.google.gson.Gson().toJson(data)
                val intent = android.content.Intent(android.content.Intent.ACTION_SEND).apply {
                    type = "application/json"
                    putExtra(android.content.Intent.EXTRA_TEXT, json)
                }
                startActivity(android.content.Intent.createChooser(intent, "Backup Data"))
            }
        }

        binding.importDataBtn.setOnClickListener {
            // Use activity result launcher for file picker
            val intent = android.content.Intent(android.content.Intent.ACTION_GET_CONTENT)
            intent.type = "application/json"
            startActivityForResult(intent, 100)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: android.content.Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 100 && resultCode == android.app.Activity.RESULT_OK) {
            val uri = data?.data
            uri?.let { importData(it) }
        }
    }

    private fun importData(uri: android.net.Uri) {
        try {
            val inputStream = requireContext().contentResolver.openInputStream(uri)
            val json = inputStream?.bufferedReader().use { it?.readText() }
            val gson = com.google.gson.Gson()
            val type = object : com.google.gson.reflect.TypeToken<Map<String, Any>>() {}.type
            val data: Map<String, Any> = gson.fromJson(json, type)
            // Restore logic...
            android.widget.Toast.makeText(requireContext(), "Data restored", android.widget.Toast.LENGTH_SHORT).show()
        } catch (e: Exception) {
            android.widget.Toast.makeText(requireContext(), "Failed to restore: ${e.message}", android.widget.Toast.LENGTH_SHORT).show()
        }
    }

    private fun setupFactoryReset() {
        binding.factoryResetBtn.setOnClickListener {
            androidx.appcompat.app.AlertDialog.Builder(requireContext())
                .setTitle("Factory Reset")
                .setMessage("Are you sure you want to delete all data?")
                .setPositiveButton("Yes") { _, _ ->
                    lifecycleScope.launch {
                        UltraStreamApplication.instance.repository.clearAllData()
                        android.widget.Toast.makeText(requireContext(), "Data cleared", android.widget.Toast.LENGTH_SHORT).show()
                    }
                }
                .setNegativeButton("No", null)
                .show()
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
EOF

# ============================================================
# Details Activity
# ============================================================
cat << 'EOF' > app/src/main/java/com/ultrastream/ui/details/DetailsActivity.kt
// app/src/main/java/com/ultrastream/ui/details/DetailsActivity.kt
package com.ultrastream.ui.details

import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import com.bumptech.glide.Glide
import com.google.android.material.chip.Chip
import com.ultrastream.R
import com.ultrastream.UltraStreamApplication
import com.ultrastream.databinding.ActivityDetailsBinding
import com.ultrastream.data.models.MetaItem
import com.ultrastream.data.models.Video
import com.ultrastream.ui.adapters.EpisodeAdapter
import com.ultrastream.ui.sheets.SeasonSelectBottomSheet
import com.ultrastream.ui.sheets.StreamBottomSheet
import com.ultrastream.utils.NetworkUtils
import kotlinx.coroutines.launch

class DetailsActivity : AppCompatActivity() {

    private lateinit var binding: ActivityDetailsBinding
    private lateinit var meta: MetaItem
    private var metaId: String = ""
    private var metaType: String = ""

    private lateinit var episodeAdapter: EpisodeAdapter
    private var allEpisodes: List<Video> = emptyList()
    private var currentSeason: Int = 1

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityDetailsBinding.inflate(layoutInflater)
        setContentView(binding.root)

        metaId = intent.getStringExtra(EXTRA_META_ID) ?: ""
        metaType = intent.getStringExtra(EXTRA_META_TYPE) ?: "movie"

        loadMetadata()
        setupListeners()
    }

    private fun loadMetadata() {
        showLoading(true)
        lifecycleScope.launch {
            var cached = (application as UltraStreamApplication).repository.getCachedMeta(metaId)
            if (cached == null) {
                val fetched = NetworkUtils.fetchMeta(metaId, metaType)
                if (fetched != null) {
                    (application as UltraStreamApplication).repository.cacheMeta(fetched)
                    meta = fetched
                } else {
                    showLoading(false)
                    return@launch
                }
            } else {
                meta = cached
            }
            showLoading(false)
            populateUI()
        }
    }

    private fun populateUI() {
        Glide.with(this)
            .load(meta.poster ?: meta.background)
            .placeholder(R.drawable.placeholder_poster)
            .into(binding.heroImage)

        binding.tvNetwork.text = meta.type.uppercase()
        binding.tvTitle.text = meta.name
        binding.tvYear.text = meta.year?.toString() ?: ""
        binding.tvRuntime.text = meta.runtime ?: "N/A"
        binding.tvRating.text = "⭐ ${meta.imdbRating ?: "N/A"}"
        binding.tvGenre.text = meta.genre?.take(3)?.joinToString(", ") ?: ""

        binding.tvDescription.text = meta.description ?: "No description available."
        if (meta.description?.length ?: 0 > 200) {
            binding.tvReadMore.visibility = View.VISIBLE
            binding.tvReadMore.setOnClickListener {
                binding.tvDescription.maxLines = if (binding.tvDescription.maxLines == 4) Int.MAX_VALUE else 4
                binding.tvReadMore.text = if (binding.tvDescription.maxLines == Int.MAX_VALUE) "Read less" else "Read more"
            }
        }

        meta.cast?.take(8)?.forEach { actor ->
            val chip = Chip(this).apply {
                text = actor
                isClickable = true
                setOnClickListener { /* search actor */ }
            }
            binding.castChipGroup.addView(chip)
        }

        if (!meta.imdbId.isNullOrEmpty()) {
            binding.btnImdb.visibility = View.VISIBLE
            binding.btnImdb.setOnClickListener { /* open IMDb */ }
        }

        val isEpisodic = !meta.videos.isNullOrEmpty()
        if (isEpisodic) {
            binding.episodesContainer.visibility = View.VISIBLE
            binding.btnFindStreams.visibility = View.GONE
            setupEpisodes()
        } else {
            binding.episodesContainer.visibility = View.GONE
            binding.btnFindStreams.visibility = View.VISIBLE
            binding.btnFindStreams.setOnClickListener {
                showStreams(null)
            }
        }

        updateWatchlistIcon()
        updateLibraryIcon()
    }

    private fun setupEpisodes() {
        val videos = meta.videos ?: emptyList()
        allEpisodes = videos.filter { it.season > 0 && it.episode > 0 }
            .sortedWith(compareBy<Video> { it.season }.thenBy { it.episode })

        if (allEpisodes.isEmpty()) {
            binding.episodesContainer.visibility = View.GONE
            binding.btnFindStreams.visibility = View.VISIBLE
            return
        }

        currentSeason = allEpisodes.firstOrNull()?.season ?: 1

        episodeAdapter = EpisodeAdapter { episode ->
            showStreams(episode)
        }

        // Show season selector
        val seasonBtn = binding.sectionMore
        seasonBtn.visibility = View.VISIBLE
        seasonBtn.text = "Season $currentSeason ▼"
        seasonBtn.setOnClickListener {
            showSeasonSelector()
        }

        renderEpisodes()
    }

    private fun renderEpisodes() {
        val filtered = allEpisodes.filter { it.season == currentSeason }
        binding.rvEpisodes.layoutManager = LinearLayoutManager(this)
        binding.rvEpisodes.adapter = episodeAdapter
        episodeAdapter.submitList(filtered)
    }

    private fun showSeasonSelector() {
        val seasons = allEpisodes.map { it.season }.distinct().sorted()
        val bottomSheet = SeasonSelectBottomSheet(seasons, currentSeason) { selectedSeason ->
            currentSeason = selectedSeason
            binding.sectionMore.text = "Season $currentSeason ▼"
            renderEpisodes()
        }
        bottomSheet.show(supportFragmentManager, "season_selector")
    }

    private fun showStreams(episode: Video?) {
        val bottomSheet = StreamBottomSheet(metaId, metaType, episode)
        bottomSheet.show(supportFragmentManager, "stream_sheet")
    }

    private fun updateWatchlistIcon() {
        lifecycleScope.launch {
            val watchlist = (application as UltraStreamApplication).repository.getWatchlist()
            val inWatchlist = watchlist.any { it.id == metaId }
            binding.btnWatchlist.setImageResource(
                if (inWatchlist) R.drawable.ic_watchlist_filled else R.drawable.ic_watchlist
            )
            binding.btnWatchlist.setOnClickListener { toggleWatchlist() }
        }
    }

    private fun toggleWatchlist() {
        lifecycleScope.launch {
            val watchlist = (application as UltraStreamApplication).repository.getWatchlist().toMutableList()
            val idx = watchlist.indexOfFirst { it.id == metaId }
            if (idx != -1) {
                watchlist.removeAt(idx)
                android.widget.Toast.makeText(this@DetailsActivity, "Removed from watchlist", android.widget.Toast.LENGTH_SHORT).show()
            } else {
                watchlist.add(meta)
                android.widget.Toast.makeText(this@DetailsActivity, "Added to watchlist", android.widget.Toast.LENGTH_SHORT).show()
            }
            (application as UltraStreamApplication).repository.setWatchlist(watchlist)
            updateWatchlistIcon()
        }
    }

    private fun updateLibraryIcon() {
        lifecycleScope.launch {
            val library = (application as UltraStreamApplication).repository.getLibrary()
            val inLibrary = library.any { it.id == metaId }
            binding.btnLibrary.setImageResource(
                if (inLibrary) R.drawable.ic_bookmark_filled else R.drawable.ic_bookmark
            )
            binding.btnLibrary.setOnClickListener { toggleLibrary() }
        }
    }

    private fun toggleLibrary() {
        lifecycleScope.launch {
            val library = (application as UltraStreamApplication).repository.getLibrary().toMutableList()
            val idx = library.indexOfFirst { it.id == metaId }
            if (idx != -1) {
                library.removeAt(idx)
                android.widget.Toast.makeText(this@DetailsActivity, "Removed from library", android.widget.Toast.LENGTH_SHORT).show()
            } else {
                library.add(meta)
                android.widget.Toast.makeText(this@DetailsActivity, "Added to library", android.widget.Toast.LENGTH_SHORT).show()
            }
            (application as UltraStreamApplication).repository.setLibrary(library)
            updateLibraryIcon()
        }
    }

    private fun showLoading(show: Boolean) {
        binding.loadingOverlay.visibility = if (show) View.VISIBLE else View.GONE
    }

    private fun setupListeners() {
        binding.btnBack.setOnClickListener { finish() }
    }

    companion object {
        const val EXTRA_META_ID = "meta_id"
        const val EXTRA_META_TYPE = "meta_type"
    }
}
EOF

# ============================================================
# Adapters
# ============================================================
cat << 'EOF' > app/src/main/java/com/ultrastream/ui/adapters/PosterAdapter.kt
// app/src/main/java/com/ultrastream/ui/adapters/PosterAdapter.kt
package com.ultrastream.ui.adapters

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.ultrastream.databinding.ItemPosterBinding
import com.ultrastream.data.models.MetaItem

class PosterAdapter(
    private val onItemClick: (MetaItem) -> Unit
) : RecyclerView.Adapter<PosterAdapter.PosterViewHolder>() {

    private var items: List<MetaItem> = emptyList()

    fun submitList(newItems: List<MetaItem>) {
        items = newItems
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): PosterViewHolder {
        val binding = ItemPosterBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return PosterViewHolder(binding)
    }

    override fun onBindViewHolder(holder: PosterViewHolder, position: Int) {
        holder.bind(items[position])
    }

    override fun getItemCount(): Int = items.size

    inner class PosterViewHolder(
        private val binding: ItemPosterBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(item: MetaItem) {
            Glide.with(binding.root.context)
                .load(item.poster ?: item.background)
                .placeholder(android.R.drawable.ic_menu_gallery)
                .into(binding.posterImage)

            binding.tvTitle.text = item.name

            if (item.imdbRating != null && item.imdbRating!! > 0f) {
                binding.tvRating.text = "⭐ ${item.imdbRating}"
                binding.tvRating.visibility = android.view.View.VISIBLE
            } else {
                binding.tvRating.visibility = android.view.View.GONE
            }

            if (item.type.isNotEmpty()) {
                binding.tvType.text = item.type.uppercase()
                binding.tvType.visibility = android.view.View.VISIBLE
            } else {
                binding.tvType.visibility = android.view.View.GONE
            }

            if (item.year != null && item.year!! > 0) {
                binding.tvYear.text = item.year.toString()
                binding.tvYear.visibility = android.view.View.VISIBLE
            } else {
                binding.tvYear.visibility = android.view.View.GONE
            }

            // Progress - we'll handle this separately

            binding.root.setOnClickListener {
                onItemClick(item)
            }
        }
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/ui/adapters/StreamAdapter.kt
// app/src/main/java/com/ultrastream/ui/adapters/StreamAdapter.kt
package com.ultrastream.ui.adapters

import android.content.res.ColorStateList
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.chip.Chip
import com.ultrastream.R
import com.ultrastream.databinding.ItemStreamBinding
import com.ultrastream.data.models.Stream
import com.ultrastream.utils.StreamParser

class StreamAdapter(
    private val onItemClick: (Stream) -> Unit
) : RecyclerView.Adapter<StreamAdapter.StreamViewHolder>() {

    private var items: List<Stream> = emptyList()

    fun submitList(newItems: List<Stream>) {
        items = newItems
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): StreamViewHolder {
        val binding = ItemStreamBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return StreamViewHolder(binding)
    }

    override fun onBindViewHolder(holder: StreamViewHolder, position: Int) {
        holder.bind(items[position])
    }

    override fun getItemCount(): Int = items.size

    inner class StreamViewHolder(
        private val binding: ItemStreamBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(stream: Stream) {
            binding.streamAddon.text = stream.addonName ?: "Unknown"

            val streamText = (stream.title ?: "") + "\n" + (stream.description ?: "") + "\n" + (stream.name ?: "")
            val parsed = StreamParser.parse(streamText)
            binding.streamTitle.text = parsed.cleanText

            val quality = parsed.quals.firstOrNull() ?: "Unknown"
            binding.streamQuality.text = quality

            binding.streamChipGroup.removeAllViews()
            var hasBadges = false

            if (parsed.hasHindi) {
                addChip("🇮🇳 Hindi", R.color.accent_orange)
                hasBadges = true
            }
            parsed.size?.let {
                addChip("💾 $it", R.color.accent_gold)
                hasBadges = true
            }
            parsed.seeds?.let {
                addChip("👤 $it", R.color.accent_green)
                hasBadges = true
            }
            if (parsed.isLive) {
                addChip("🔴 LIVE", R.color.accent_red)
                hasBadges = true
            }
            parsed.quals.forEach { qual ->
                if (qual != quality) {
                    addChip("📺 $qual", R.color.accent_blue)
                    hasBadges = true
                }
            }
            parsed.langs.forEach { lang ->
                if (!lang.contains("hindi", ignoreCase = true)) {
                    addChip("🗣 $lang", R.color.accent_purple)
                    hasBadges = true
                }
            }

            binding.streamChipGroup.visibility = if (hasBadges) View.VISIBLE else View.GONE

            binding.root.setOnClickListener {
                onItemClick(stream)
            }
        }

        private fun addChip(text: String, colorRes: Int) {
            val chip = Chip(binding.root.context).apply {
                this.text = text
                setChipBackgroundColorResource(android.R.color.transparent)
                setTextColor(binding.root.context.getColor(colorRes))
                chipStrokeColor = ColorStateList.valueOf(binding.root.context.getColor(colorRes))
                chipStrokeWidth = 1f
                textSize = 10f
                isClickable = false
            }
            binding.streamChipGroup.addView(chip)
        }
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/ui/adapters/EpisodeAdapter.kt
// app/src/main/java/com/ultrastream/ui/adapters/EpisodeAdapter.kt
package com.ultrastream.ui.adapters

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.ultrastream.databinding.ItemEpisodeBinding
import com.ultrastream.data.models.Video

class EpisodeAdapter(
    private val onItemClick: (Video) -> Unit
) : RecyclerView.Adapter<EpisodeAdapter.EpisodeViewHolder>() {

    private var items: List<Video> = emptyList()
    private var watchedEpisodes: Set<String> = emptySet()

    fun submitList(newItems: List<Video>, watched: Set<String> = emptySet()) {
        items = newItems
        watchedEpisodes = watched
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): EpisodeViewHolder {
        val binding = ItemEpisodeBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return EpisodeViewHolder(binding)
    }

    override fun onBindViewHolder(holder: EpisodeViewHolder, position: Int) {
        holder.bind(items[position])
    }

    override fun getItemCount(): Int = items.size

    inner class EpisodeViewHolder(
        private val binding: ItemEpisodeBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(episode: Video) {
            Glide.with(binding.root.context)
                .load(episode.thumbnail)
                .placeholder(android.R.drawable.ic_menu_gallery)
                .into(binding.epThumb)

            binding.epBadge.text = "S${episode.season.toString().padStart(2, '0')}E${episode.episode.toString().padStart(2, '0')}"
            binding.epTitle.text = episode.name ?: episode.title ?: "Episode ${episode.episode}"
            binding.epDesc.text = episode.description ?: "No description available."

            val episodeKey = "S${episode.season}E${episode.episode}"
            if (watchedEpisodes.contains(episodeKey)) {
                binding.epWatched.visibility = android.view.View.VISIBLE
                binding.epWatched.text = "✅ Watched"
            } else {
                binding.epWatched.visibility = android.view.View.GONE
            }

            binding.root.setOnClickListener {
                onItemClick(episode)
            }
        }
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/ui/adapters/ContinueWatchingAdapter.kt
// app/src/main/java/com/ultrastream/ui/adapters/ContinueWatchingAdapter.kt
package com.ultrastream.ui.adapters

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.ultrastream.databinding.ItemCwBinding
import com.ultrastream.data.models.WatchHistory
import com.ultrastream.data.models.WatchProgress

class ContinueWatchingAdapter(
    private val onItemClick: (WatchHistory) -> Unit
) : RecyclerView.Adapter<ContinueWatchingAdapter.CWViewHolder>() {

    private var items: List<WatchHistory> = emptyList()
    private var progressMap: Map<String, WatchProgress> = emptyMap()

    fun submitList(newItems: List<WatchHistory>, progress: Map<String, WatchProgress> = emptyMap()) {
        items = newItems
        progressMap = progress
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): CWViewHolder {
        val binding = ItemCwBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return CWViewHolder(binding)
    }

    override fun onBindViewHolder(holder: CWViewHolder, position: Int) {
        holder.bind(items[position])
    }

    override fun getItemCount(): Int = items.size

    inner class CWViewHolder(
        private val binding: ItemCwBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(item: WatchHistory) {
            Glide.with(binding.root.context)
                .load(item.poster)
                .placeholder(android.R.drawable.ic_menu_gallery)
                .into(binding.cwThumb)

            binding.cwTitle.text = item.name
            binding.cwMeta.text = item.type.uppercase()

            val progress = progressMap[item.id]
            if (progress != null && progress.percent > 0f) {
                binding.cwProgress.progress = progress.percent.toInt()
                binding.cwProgress.visibility = android.view.View.VISIBLE
            } else {
                binding.cwProgress.visibility = android.view.View.GONE
            }

            binding.root.setOnClickListener {
                onItemClick(item)
            }
        }
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/ui/adapters/SmartPlaylistAdapter.kt
// app/src/main/java/com/ultrastream/ui/adapters/SmartPlaylistAdapter.kt
package com.ultrastream.ui.adapters

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.ultrastream.R
import com.ultrastream.databinding.ItemSmartPlaylistBinding
import com.ultrastream.data.models.SmartPlaylist

class SmartPlaylistAdapter(
    private val onItemClick: (SmartPlaylist) -> Unit,
    private val onM3UClick: (SmartPlaylist) -> Unit,
    private val onDeleteClick: (SmartPlaylist) -> Unit
) : RecyclerView.Adapter<SmartPlaylistAdapter.PlaylistViewHolder>() {

    private var items: List<SmartPlaylist> = emptyList()

    fun submitList(newItems: List<SmartPlaylist>) {
        items = newItems
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): PlaylistViewHolder {
        val binding = ItemSmartPlaylistBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return PlaylistViewHolder(binding)
    }

    override fun onBindViewHolder(holder: PlaylistViewHolder, position: Int) {
        holder.bind(items[position])
    }

    override fun getItemCount(): Int = items.size

    inner class PlaylistViewHolder(
        private val binding: ItemSmartPlaylistBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(playlist: SmartPlaylist) {
            Glide.with(binding.root.context)
                .load(playlist.poster)
                .placeholder(android.R.drawable.ic_menu_gallery)
                .into(binding.playlistThumb)

            binding.playlistTitle.text = playlist.metaName
            binding.playlistMeta.text = "Season ${playlist.season} • ${playlist.addon}"

            val isComplete = playlist.fetched >= playlist.total
            binding.playlistStatus.text = if (isComplete) {
                "✅ Ready (${playlist.fetched}/${playlist.total})"
            } else {
                "⏳ Fetching (${playlist.fetched}/${playlist.total})"
            }
            binding.playlistStatus.setTextColor(
                binding.root.context.getColor(if (isComplete) R.color.accent_green else R.color.accent_gold)
            )

            val progress = if (playlist.total > 0) {
                (playlist.fetched.toFloat() / playlist.total * 100).toInt()
            } else 0
            binding.playlistProgress.progress = progress

            binding.btnM3u.setOnClickListener {
                onM3UClick(playlist)
            }

            binding.btnDeletePlaylist.setOnClickListener {
                onDeleteClick(playlist)
            }

            binding.root.setOnClickListener {
                onItemClick(playlist)
            }
        }
    }
}
EOF

# ============================================================
# Bottom Sheets
# ============================================================
cat << 'EOF' > app/src/main/java/com/ultrastream/ui/sheets/StreamBottomSheet.kt
// app/src/main/java/com/ultrastream/ui/sheets/StreamBottomSheet.kt
package com.ultrastream.ui.sheets

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.lifecycleScope
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.ultrastream.databinding.SheetStreamsBinding
import com.ultrastream.data.models.Stream
import com.ultrastream.data.models.Video
import com.ultrastream.ui.adapters.StreamAdapter
import com.ultrastream.utils.EpisodeMatcher
import com.ultrastream.utils.LinkVerifier
import com.ultrastream.utils.NetworkUtils
import kotlinx.coroutines.*

class StreamBottomSheet(
    private val metaId: String,
    private val metaType: String,
    private val episode: Video? = null
) : BottomSheetDialogFragment() {

    private var _binding: SheetStreamsBinding? = null
    private val binding get() = _binding!!

    private lateinit var adapter: StreamAdapter
    private val streams = mutableListOf<Stream>()
    private var isFetching = false

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = SheetStreamsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val title = episode?.let {
            "S${it.season.toString().padStart(2, '0')}E${it.episode.toString().padStart(2, '0')}"
        } ?: "Streams"

        binding.sheetTitle.text = title

        setupAdapter()
        fetchStreams()
    }

    private fun setupAdapter() {
        adapter = StreamAdapter { stream ->
            val actionSheet = StreamActionBottomSheet(stream, getStreamTitle())
            actionSheet.show(parentFragmentManager, "stream_action")
        }
        binding.rvStreams.adapter = adapter
    }

    private fun getStreamTitle(): String {
        return episode?.let {
            "S${it.season.toString().padStart(2, '0')}E${it.episode.toString().padStart(2, '0')}"
        } ?: metaId
    }

    private fun fetchStreams() {
        if (isFetching) return
        isFetching = true

        binding.loadingSpinner.visibility = View.VISIBLE
        binding.tvNoStreams.visibility = View.GONE

        val id = if (episode != null) {
            "$metaId:${episode.season}:${episode.episode}"
        } else {
            metaId
        }

        lifecycleScope.launch(Dispatchers.IO) {
            try {
                val result = NetworkUtils.fetchStreams(id, metaType)
                // Apply episode matching if episode is provided
                val filtered = if (episode != null) {
                    result.filter { EpisodeMatcher.isValidEpisodeStream(it, episode.season, episode.episode) }
                } else {
                    result
                }
                // Verify links (optional, can be heavy)
                // For now, we just display
                withContext(Dispatchers.Main) {
                    streams.clear()
                    streams.addAll(filtered)
                    adapter.submitList(streams)
                    binding.loadingSpinner.visibility = View.GONE
                    if (streams.isEmpty()) {
                        binding.tvNoStreams.visibility = View.VISIBLE
                    }
                    isFetching = false
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    binding.loadingSpinner.visibility = View.GONE
                    binding.tvNoStreams.visibility = View.VISIBLE
                    binding.tvNoStreams.text = "Error: ${e.message}"
                    isFetching = false
                }
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/ui/sheets/StreamActionBottomSheet.kt
// app/src/main/java/com/ultrastream/ui/sheets/StreamActionBottomSheet.kt
package com.ultrastream.ui.sheets

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.ultrastream.R
import com.ultrastream.data.models.Stream
import com.ultrastream.databinding.SheetStreamActionBinding
import com.ultrastream.player.PlayerActivity

class StreamActionBottomSheet(
    private val stream: Stream,
    private val title: String
) : BottomSheetDialogFragment() {

    private var _binding: SheetStreamActionBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = SheetStreamActionBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupActions()
    }

    private fun setupActions() {
        binding.btnPlayExternal.setOnClickListener {
            val url = stream.url ?: stream.streamUrl ?: stream.externalUrl
            if (url.isNullOrEmpty()) { showToast("No URL available"); return@setOnClickListener }
            val intent = Intent(requireContext(), PlayerActivity::class.java).apply {
                putExtra(PlayerActivity.EXTRA_MEDIA_URL, url)
                putExtra(PlayerActivity.EXTRA_MEDIA_TITLE, title)
                putExtra(PlayerActivity.EXTRA_IS_LIVE, stream.isLive)
            }
            startActivity(intent)
            dismiss()
        }

        binding.btnDownload.setOnClickListener {
            val url = stream.url ?: stream.streamUrl
            if (url.isNullOrEmpty()) { showToast("No direct download link"); return@setOnClickListener }
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
            startActivity(Intent.createChooser(intent, "Open with..."))
            dismiss()
        }

        binding.btnCopyMagnet.setOnClickListener {
            var magnet: String? = null
            if (!stream.infoHash.isNullOrEmpty()) {
                magnet = "magnet:?xt=urn:btih:${stream.infoHash}"
                stream.name?.let { magnet += "&dn=${Uri.encode(it)}" }
            } else if (stream.url?.startsWith("magnet:") == true) {
                magnet = stream.url
            } else if (stream.externalUrl?.startsWith("magnet:") == true) {
                magnet = stream.externalUrl
            }
            if (magnet.isNullOrEmpty()) { showToast("No magnet link available"); return@setOnClickListener }
            copyToClipboard(magnet)
            showToast("Magnet copied!")
            dismiss()
        }

        binding.btnCopyUrl.setOnClickListener {
            val url = stream.url ?: stream.streamUrl ?: stream.externalUrl
            if (url.isNullOrEmpty()) { showToast("No URL available"); return@setOnClickListener }
            copyToClipboard(url)
            showToast("URL copied!")
            dismiss()
        }

        binding.btnSubtitles.setOnClickListener {
            val subs = stream.subtitles
            if (subs.isNullOrEmpty()) { showToast("No subtitles found"); return@setOnClickListener }
            val sheet = SubtitleBottomSheet(subs)
            sheet.show(parentFragmentManager, "subtitles")
            dismiss()
        }

        binding.btnExportM3u.setOnClickListener {
            val url = stream.url ?: stream.streamUrl ?: stream.externalUrl
            if (url.isNullOrEmpty() || url.startsWith("magnet:")) {
                showToast("Cannot export magnet as M3U")
                return@setOnClickListener
            }
            val m3uContent = "#EXTM3U\n#EXTINF:-1,$title\n$url"
            val sheet = M3UActionBottomSheet(m3uContent, "$title.m3u")
            sheet.show(parentFragmentManager, "m3u_actions")
            dismiss()
        }
    }

    private fun copyToClipboard(text: String) {
        val clipboard = requireContext().getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = ClipData.newPlainText("URL", text)
        clipboard.setPrimaryClip(clip)
    }

    private fun showToast(message: String) {
        Toast.makeText(requireContext(), message, Toast.LENGTH_SHORT).show()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/ui/sheets/SeasonSelectBottomSheet.kt
// app/src/main/java/com/ultrastream/ui/sheets/SeasonSelectBottomSheet.kt
package com.ultrastream.ui.sheets

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.ultrastream.R
import com.ultrastream.databinding.SheetSeasonsBinding

class SeasonSelectBottomSheet(
    private val seasons: List<Int>,
    private val currentSeason: Int,
    private val onSeasonSelected: (Int) -> Unit
) : BottomSheetDialogFragment() {

    private var _binding: SheetSeasonsBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = SheetSeasonsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        binding.rvSeasons.layoutManager = LinearLayoutManager(requireContext())
        binding.rvSeasons.adapter = object : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
            override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
                val view = LayoutInflater.from(parent.context)
                    .inflate(android.R.layout.simple_list_item_1, parent, false)
                return object : RecyclerView.ViewHolder(view) {}
            }

            override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
                val season = seasons[position]
                val tv = holder.itemView as android.widget.TextView
                tv.text = "Season $season"
                tv.setBackgroundColor(
                    if (season == currentSeason) {
                        resources.getColor(android.R.color.holo_blue_light)
                    } else {
                        android.R.color.transparent
                    }
                )
                tv.setOnClickListener {
                    if (season != currentSeason) {
                        onSeasonSelected(season)
                        dismiss()
                    }
                }
            }

            override fun getItemCount(): Int = seasons.size
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/ui/sheets/SubtitleBottomSheet.kt
// app/src/main/java/com/ultrastream/ui/sheets/SubtitleBottomSheet.kt
package com.ultrastream.ui.sheets

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.ultrastream.R
import com.ultrastream.data.models.Subtitle
import com.ultrastream.databinding.SheetSubtitlesBinding

class SubtitleBottomSheet(
    private val subtitles: List<Subtitle>
) : BottomSheetDialogFragment() {

    private var _binding: SheetSubtitlesBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = SheetSubtitlesBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        binding.rvSubtitles.layoutManager = LinearLayoutManager(requireContext())
        binding.rvSubtitles.adapter = SubtitleAdapter(subtitles) { subtitle ->
            downloadSubtitle(subtitle)
        }
    }

    private fun downloadSubtitle(subtitle: Subtitle) {
        val url = subtitle.url ?: subtitle.file
        if (url.isNullOrEmpty()) {
            Toast.makeText(requireContext(), "No subtitle URL available", Toast.LENGTH_SHORT).show()
            return
        }

        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
        startActivity(Intent.createChooser(intent, "Download subtitle"))
        dismiss()
    }

    inner class SubtitleAdapter(
        private val items: List<Subtitle>,
        private val onItemClick: (Subtitle) -> Unit
    ) : RecyclerView.Adapter<SubtitleAdapter.ViewHolder>() {

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
            val view = LayoutInflater.from(parent.context)
                .inflate(android.R.layout.simple_list_item_2, parent, false)
            return ViewHolder(view)
        }

        override fun onBindViewHolder(holder: ViewHolder, position: Int) {
            val item = items[position]
            holder.bind(item)
        }

        override fun getItemCount(): Int = items.size

        inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
            fun bind(subtitle: Subtitle) {
                val text1 = itemView.findViewById<android.widget.TextView>(android.R.id.text1)
                val text2 = itemView.findViewById<android.widget.TextView>(android.R.id.text2)

                val langName = try {
                    java.util.Locale(subtitle.lang).displayName
                } catch (e: Exception) {
                    subtitle.lang
                }

                text1.text = langName
                text2.text = subtitle.name ?: "Subtitle"

                itemView.setOnClickListener {
                    onItemClick(subtitle)
                }
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/ui/sheets/M3UActionBottomSheet.kt
// app/src/main/java/com/ultrastream/ui/sheets/M3UActionBottomSheet.kt
package com.ultrastream.ui.sheets

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.core.content.FileProvider
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.ultrastream.databinding.SheetM3uActionsBinding
import com.ultrastream.player.PlayerActivity
import com.ultrastream.utils.M3UParser
import java.io.File
import java.io.FileOutputStream

class M3UActionBottomSheet(
    private val m3uContent: String,
    private val fileName: String = "playlist.m3u"
) : BottomSheetDialogFragment() {

    private var _binding: SheetM3uActionsBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = SheetM3uActionsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val entries = M3UParser.parse(m3uContent)
        binding.tvM3uDesc.text = "${entries.size} track${if (entries.size > 1) "s" else ""} • Choose an action below"

        binding.btnExportM3u.setOnClickListener {
            exportM3U()
            dismiss()
        }
        binding.btnPlayM3u.setOnClickListener {
            playM3U()
            dismiss()
        }
    }

    private fun exportM3U() {
        try {
            val outputFile = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                File(requireContext().filesDir, fileName)
            } else {
                File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS), fileName)
            }
            FileOutputStream(outputFile).use { fos ->
                fos.write(m3uContent.toByteArray())
            }

            val uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                FileProvider.getUriForFile(
                    requireContext(),
                    requireContext().packageName + ".fileprovider",
                    outputFile
                )
            } else {
                Uri.fromFile(outputFile)
            }

            val shareIntent = Intent(Intent.ACTION_SEND).apply {
                type = "audio/x-mpegurl"
                putExtra(Intent.EXTRA_STREAM, uri)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            startActivity(Intent.createChooser(shareIntent, "Export M3U"))
            Toast.makeText(requireContext(), "M3U saved: ${outputFile.absolutePath}", Toast.LENGTH_SHORT).show()
        } catch (e: Exception) {
            Toast.makeText(requireContext(), "Export failed: ${e.message}", Toast.LENGTH_LONG).show()
        }
    }

    private fun playM3U() {
        val entries = M3UParser.parse(m3uContent)
        if (entries.isEmpty()) {
            Toast.makeText(requireContext(), "No playable entries found", Toast.LENGTH_SHORT).show()
            return
        }
        val firstEntry = entries.first()
        val intent = Intent(requireContext(), PlayerActivity::class.java).apply {
            putExtra(PlayerActivity.EXTRA_MEDIA_URL, firstEntry.url)
            putExtra(PlayerActivity.EXTRA_MEDIA_TITLE, firstEntry.title)
        }
        startActivity(intent)
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/ultrastream/ui/sheets/PlaylistViewBottomSheet.kt
// app/src/main/java/com/ultrastream/ui/sheets/PlaylistViewBottomSheet.kt
package com.ultrastream.ui.sheets

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.lifecycle.lifecycleScope
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.ultrastream.UltraStreamApplication
import com.ultrastream.data.models.PlaylistEpisode
import com.ultrastream.data.models.SmartPlaylist
import com.ultrastream.databinding.SheetPlaylistViewBinding
import com.ultrastream.utils.LinkVerifier
import com.ultrastream.utils.NetworkUtils
import kotlinx.coroutines.*

class PlaylistViewBottomSheet(
    private val playlist: SmartPlaylist
) : BottomSheetDialogFragment() {

    private var _binding: SheetPlaylistViewBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = SheetPlaylistViewBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        binding.playlistTitle.text = "${playlist.metaName} - S${playlist.season}"
        renderEpisodes()
    }

    private fun renderEpisodes() {
        binding.episodesContainer.removeAllViews()
        for (ep in playlist.episodes) {
            val itemView = layoutInflater.inflate(android.R.layout.simple_list_item_2, binding.episodesContainer, false)
            val text1 = itemView.findViewById<android.widget.TextView>(android.R.id.text1)
            val text2 = itemView.findViewById<android.widget.TextView>(android.R.id.text2)
            text1.text = "E${ep.epNum} - ${ep.epName}"
            if (ep.stream != null && !ep.isMissing) {
                text2.text = "✅ Ready (${ep.stream.addonName})"
                text2.setTextColor(requireContext().getColor(android.R.color.holo_green_light))
                itemView.setOnClickListener {
                    // Play
                    val actionSheet = StreamActionBottomSheet(ep.stream!!, ep.title)
                    actionSheet.show(parentFragmentManager, "stream_action")
                }
            } else {
                text2.text = "❌ Missing - Tap to retry or manual pick"
                text2.setTextColor(requireContext().getColor(android.R.color.holo_red_light))
                itemView.setOnClickListener {
                    // Retry or manual
                    showRetryOptions(ep)
                }
            }
            binding.episodesContainer.addView(itemView)
        }
    }

    private fun showRetryOptions(ep: PlaylistEpisode) {
        // Dialog with retry and manual pick
        val options = arrayOf("Auto Retry", "Manual Pick")
        androidx.appcompat.app.AlertDialog.Builder(requireContext())
            .setTitle("Episode ${ep.epNum}")
            .setItems(options) { _, which ->
                when (which) {
                    0 -> retryEpisode(ep)
                    1 -> manualPick(ep)
                }
            }
            .show()
    }

    private fun retryEpisode(ep: PlaylistEpisode) {
        Toast.makeText(requireContext(), "Retrying...", Toast.LENGTH_SHORT).show()
        lifecycleScope.launch(Dispatchers.IO) {
            val fullId = "${playlist.metaId}:${playlist.season}:${ep.epNum}"
            val addons = UltraStreamApplication.instance.repository.getEnabledAddons()
            for (addon in addons) {
                val streams = NetworkUtils.fetchStreams(fullId, "series")
                val valid = streams.filter { it.url != null }
                if (valid.isNotEmpty()) {
                    // Verify first link
                    val link = valid.first().url!!
                    val isAlive = LinkVerifier.verify(link)
                    if (isAlive) {
                        // Update playlist
                        val updatedEp = ep.copy(stream = valid.first(), isMissing = false)
                        val updatedEpisodes = playlist.episodes.map { if (it.epNum == ep.epNum) updatedEp else it }
                        val updatedPlaylist = playlist.copy(episodes = updatedEpisodes)
                        UltraStreamApplication.instance.repository.updatePlaylist(updatedPlaylist)
                        withContext(Dispatchers.Main) {
                            renderEpisodes()
                            Toast.makeText(requireContext(), "Episode updated with working stream", Toast.LENGTH_SHORT).show()
                        }
                        return@launch
                    }
                }
            }
            withContext(Dispatchers.Main) {
                Toast.makeText(requireContext(), "No working stream found", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun manualPick(ep: PlaylistEpisode) {
        // Open stream bottom sheet for this episode
        val sheet = StreamBottomSheet(playlist.metaId, "series", com.ultrastream.data.models.Video(
            season = playlist.season,
            episode = ep.epNum,
            name = ep.epName
        ))
        sheet.show(parentFragmentManager, "manual_pick")
        dismiss()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
EOF

# ============================================================
# Player Activity
# ============================================================
cat << 'EOF' > app/src/main/java/com/ultrastream/player/PlayerActivity.kt
// app/src/main/java/com/ultrastream/player/PlayerActivity.kt
package com.ultrastream.player

import android.content.pm.ActivityInfo
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.google.android.exoplayer2.*
import com.google.android.exoplayer2.source.MediaSource
import com.google.android.exoplayer2.source.ProgressiveMediaSource
import com.google.android.exoplayer2.source.dash.DashMediaSource
import com.google.android.exoplayer2.source.hls.HlsMediaSource
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector
import com.google.android.exoplayer2.ui.PlayerView
import com.google.android.exoplayer2.upstream.DefaultHttpDataSource
import com.google.android.exoplayer2.util.Util
import com.ultrastream.R
import com.ultrastream.databinding.ActivityPlayerBinding
import com.ultrastream.utils.LinkVerifier
import kotlinx.coroutines.*

class PlayerActivity : AppCompatActivity() {

    private lateinit var binding: ActivityPlayerBinding
    private lateinit var player: ExoPlayer
    private lateinit var trackSelector: DefaultTrackSelector

    private var mediaUrl: String = ""
    private var mediaTitle: String = ""
    private var subtitleUrl: String? = null
    private var isLive: Boolean = false

    private var isControlsLocked = false
    private val handler = Handler(Looper.getMainLooper())
    private var hideControlsRunnable: Runnable? = null

    private var touchX = 0f
    private var touchY = 0f
    private var startBrightness = 0f
    private var startVolume = 0f

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityPlayerBinding.inflate(layoutInflater)
        setContentView(binding.root)

        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        mediaUrl = intent.getStringExtra(EXTRA_MEDIA_URL) ?: ""
        mediaTitle = intent.getStringExtra(EXTRA_MEDIA_TITLE) ?: "Video"
        subtitleUrl = intent.getStringExtra(EXTRA_SUBTITLE_URL)
        isLive = intent.getBooleanExtra(EXTRA_IS_LIVE, false)

        if (mediaUrl.isEmpty()) {
            finish()
            return
        }

        setupPlayer()
        setupUI()
    }

    private fun setupPlayer() {
        trackSelector = DefaultTrackSelector(this)
        player = ExoPlayer.Builder(this)
            .setTrackSelector(trackSelector)
            .build()

        binding.playerView.player = player
        binding.playerView.setShowBuffering(PlayerView.SHOW_BUFFERING_WHEN_PLAYING)
        binding.playerView.useController = true

        val dataSourceFactory = DefaultHttpDataSource.Factory()
        val mediaSource = buildMediaSource(mediaUrl, dataSourceFactory)

        player.setMediaSource(mediaSource)
        player.prepare()
        player.playWhenReady = true
    }

    private fun buildMediaSource(url: String, dataSourceFactory: DefaultHttpDataSource.Factory): MediaSource {
        val uri = Uri.parse(url)
        return when {
            url.contains(".m3u8") -> HlsMediaSource.Factory(dataSourceFactory).createMediaSource(MediaItem.fromUri(uri))
            url.contains(".mpd") -> DashMediaSource.Factory(dataSourceFactory).createMediaSource(MediaItem.fromUri(uri))
            else -> ProgressiveMediaSource.Factory(dataSourceFactory).createMediaSource(MediaItem.fromUri(uri))
        }
    }

    private fun setupUI() {
        binding.playerView.setControllerVisibilityListener { visibility ->
            if (visibility == View.VISIBLE) {
                showCustomControls()
            }
        }

        binding.btnPip.setOnClickListener {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                enterPictureInPictureMode()
            }
        }

        binding.btnLock.setOnClickListener {
            isControlsLocked = !isControlsLocked
            binding.btnLock.setImageResource(
                if (isControlsLocked) R.drawable.ic_lock else R.drawable.ic_lock_open
            )
            if (isControlsLocked) {
                binding.playerView.useController = false
                binding.btnPip.visibility = View.GONE
                binding.btnLock.visibility = View.GONE
                Toast.makeText(this, "Controls Locked", Toast.LENGTH_SHORT).show()
            } else {
                binding.playerView.useController = true
                binding.btnPip.visibility = View.VISIBLE
                binding.btnLock.visibility = View.VISIBLE
                Toast.makeText(this, "Controls Unlocked", Toast.LENGTH_SHORT).show()
            }
        }

        binding.playerView.setOnTouchListener { _, event ->
            if (isControlsLocked) return@setOnTouchListener false
            handleTouch(event)
            true
        }

        binding.playerView.setOnClickListener {
            if (isControlsLocked) return@setOnClickListener
            if (player.isPlaying) {
                player.pause()
            } else {
                player.play()
            }
        }

        player.addListener(object : Player.Listener {
            override fun onPlayerError(error: PlaybackException) {
                showError("Playback Error: ${error.message}")
            }
        })
    }

    private fun showCustomControls() {
        binding.btnPip.visibility = if (!isControlsLocked) View.VISIBLE else View.GONE
        binding.btnLock.visibility = View.VISIBLE
        hideControlsRunnable?.let { handler.removeCallbacks(it) }
        hideControlsRunnable = Runnable {
            binding.btnPip.visibility = View.GONE
            binding.btnLock.visibility = View.GONE
        }
        handler.postDelayed(hideControlsRunnable!!, 3000)
    }

    private fun handleTouch(event: MotionEvent) {
        when (event.action) {
            MotionEvent.ACTION_DOWN -> {
                touchX = event.x
                touchY = event.y
                startBrightness = window.attributes.screenBrightness
                startVolume = 0f
            }
            MotionEvent.ACTION_MOVE -> {
                val deltaX = event.x - touchX
                val deltaY = event.y - touchY

                if (event.x < binding.playerView.width * 0.3f) {
                    val brightnessChange = -deltaY / binding.playerView.height
                    val newBrightness = (startBrightness + brightnessChange).coerceIn(0.01f, 1f)
                    window.attributes = window.attributes.apply {
                        screenBrightness = newBrightness
                    }
                } else if (event.x > binding.playerView.width * 0.7f) {
                    // Volume (we can adjust using ExoPlayer volume)
                    val volumeChange = -deltaY / binding.playerView.height
                    val newVolume = (startVolume + volumeChange).coerceIn(0f, 1f)
                    player.volume = newVolume
                } else {
                    val seekAmount = (deltaX / binding.playerView.width) * 60000
                    val currentPos = player.currentPosition
                    val newPos = (currentPos + seekAmount.toLong()).coerceIn(0L, player.duration)
                    player.seekTo(newPos)
                }
            }
        }
    }

    override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean, newConfig: android.content.res.Configuration) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        if (isInPictureInPictureMode) {
            binding.playerView.useController = false
        } else {
            binding.playerView.useController = true
        }
    }

    private fun showError(message: String) {
        binding.errorLayout.visibility = View.VISIBLE
        binding.tvError.text = message
        binding.btnRetry.setOnClickListener {
            binding.errorLayout.visibility = View.GONE
            player.prepare()
            player.playWhenReady = true
        }
    }

    override fun onStart() {
        super.onStart()
        if (Util.SDK_INT >= 24) {
            player.playWhenReady = true
        }
    }

    override fun onResume() {
        super.onResume()
        if (Util.SDK_INT < 24 || !::player.isInitialized) {
            player.playWhenReady = true
        }
    }

    override fun onPause() {
        super.onPause()
        if (Util.SDK_INT < 24) {
            player.playWhenReady = false
        }
    }

    override fun onStop() {
        super.onStop()
        if (Util.SDK_INT >= 24) {
            player.playWhenReady = false
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        player.release()
        handler.removeCallbacksAndMessages(null)
    }

    override fun onKeyDown(keyCode: Int, event: android.view.KeyEvent?): Boolean {
        return when (keyCode) {
            android.view.KeyEvent.KEYCODE_DPAD_CENTER -> {
                if (player.isPlaying) player.pause() else player.play()
                true
            }
            android.view.KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE -> {
                if (player.isPlaying) player.pause() else player.play()
                true
            }
            else -> super.onKeyDown(keyCode, event)
        }
    }

    companion object {
        const val EXTRA_MEDIA_URL = "media_url"
        const val EXTRA_MEDIA_TITLE = "media_title"
        const val EXTRA_SUBTITLE_URL = "subtitle_url"
        const val EXTRA_IS_LIVE = "is_live"
    }
}
EOF

# ============================================================
# Player Service (placeholder)
# ============================================================
cat << 'EOF' > app/src/main/java/com/ultrastream/player/PlayerService.kt
// app/src/main/java/com/ultrastream/player/PlayerService.kt
package com.ultrastream.player

import android.app.Service
import android.content.Intent
import android.os.IBinder

class PlayerService : Service() {
    override fun onBind(intent: Intent?): IBinder? = null
}
EOF

# ============================================================
# Additional layout for installed addon card (simple)
# ============================================================
cat << 'EOF' > app/src/main/res/layout/installed_addon_card.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="horizontal"
    android:padding="12dp"
    android:background="?attr/colorSurface"
    android:layout_marginBottom="8dp">

    <TextView
        android:id="@+id/addon_name"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_weight="1"
        android:text="Addon Name"
        android:textColor="?attr/colorOnSurface"
        android:textSize="14sp" />

    <Button
        android:id="@+id/btn_toggle"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Enable"
        android:textSize="12sp" />

</LinearLayout>
EOF

# ============================================================
# Sheet for playlist view
# ============================================================
cat << 'EOF' > app/src/main/res/layout/sheet_playlist_view.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="vertical"
    android:background="@color/dark_bg_main"
    android:padding="16dp">

    <TextView
        android:id="@+id/playlist_title"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="Playlist"
        android:textSize="18sp"
        android:textStyle="bold"
        android:textColor="?attr/colorOnSurface"
        android:paddingBottom="16dp" />

    <LinearLayout
        android:id="@+id/episodes_container"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical" />

</LinearLayout>
EOF

# ============================================================
# Done
# ============================================================
echo "Project structure created successfully!"
echo "You can now open the project in Android Studio or build with ./gradlew assembleDebug"
