#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "==> Fixing settings.gradle (repository mode)..."
cat > settings.gradle <<'EOF_SETTINGS'
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
    }
}
rootProject.name = "UltraStream"
include ':app'
EOF_SETTINGS

echo "==> Updating root build.gradle..."
cat > build.gradle <<'EOF_BUILD'
// Top-level build file
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.4.2'
        classpath 'org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.20'
        classpath 'com.google.dagger:hilt-android-gradle-plugin:2.48'
    }
}
task clean(type: Delete) {
    delete rootProject.buildDir
}
EOF_BUILD

echo "==> Ensuring colors.xml is well-formed..."
cat > app/src/main/res/values/colors.xml <<'EOF_COLORS'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="dark_bg_main">#060606</color>
    <color name="dark_bg_surface">#121212</color>
    <color name="dark_bg_card">#1a1a1a</color>
    <color name="dark_text_main">#ffffff</color>
    <color name="dark_text_muted">#a3a3a3</color>
    <color name="light_bg_main">#f3f4f6</color>
    <color name="light_bg_surface">#ffffff</color>
    <color name="light_bg_card">#ffffff</color>
    <color name="light_text_main">#111827</color>
    <color name="light_text_muted">#6b7280</color>
    <color name="accent_blue">#38bdf8</color>
    <color name="accent_gold">#fbbf24</color>
    <color name="accent_red">#ef4444</color>
    <color name="accent_green">#4caf50</color>
    <color name="accent_purple">#a78bfa</color>
    <color name="accent_orange">#fb923c</color>
    <color name="accent_pink">#f472b6</color>
    <color name="transparent">#00000000</color>
    <color name="black_overlay">#cc000000</color>
    <color name="white_alpha_10">#1affffff</color>
    <color name="white_alpha_20">#33ffffff</color>
    <color name="white_alpha_80">#ccffffff</color>
    <color name="shadow">#40000000</color>
</resources>
EOF_COLORS

echo "==> Committing and pushing to GitHub..."
git add .
git commit -m "Fix root project Gradle configuration and XML resources"
git push origin main
echo "✅ Done! Check GitHub Actions for successful build."
