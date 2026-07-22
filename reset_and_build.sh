#!/data/data/com.termux/files/usr/bin/bash
set -e
cd /storage/emulated/0/ultrabuild/UltraStream || { echo "Project dir missing"; exit 1; }

# Environment setup
export ANDROID_HOME=$HOME/android-sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/34.0.0
export JAVA_HOME=/data/data/com.termux/files/usr/lib/jvm/java-21-openjdk
export GRADLE_HOME=$HOME/gradle
export PATH=$HOME/gradle/bin:$JAVA_HOME/bin:$PATH

echo "🔧 1. Removing aapt2 override from all files..."
sed -i '/android.aapt2FromMavenOverride/d' gradle.properties
sed -i '/android.aapt2FromMavenOverride/d' app/build.gradle

echo "🔧 2. Setting buildToolsVersion in app/build.gradle..."
if ! grep -q 'buildToolsVersion' app/build.gradle; then
    sed -i '/android {/a\    buildToolsVersion "34.0.0"' app/build.gradle
else
    sed -i 's/buildToolsVersion .*/buildToolsVersion "34.0.0"/' app/build.gradle
fi

echo "🔧 3. Updating AGP version to 8.2.0 in project build.gradle..."
sed -i 's/classpath "com.android.tools.build:gradle:.*/classpath "com.android.tools.build:gradle:8.2.0"/' build.gradle

echo "📦 4. Reinstalling build-tools 34.0.0..."
if [ ! -d "$ANDROID_HOME/build-tools/34.0.0" ] || [ ! -f "$ANDROID_HOME/build-tools/34.0.0/aapt2" ]; then
    echo "Installing build-tools 34.0.0..."
    yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_HOME "build-tools;34.0.0"
else
    echo "✅ build-tools 34.0.0 already installed."
fi

echo "🧹 5. Cleaning all caches..."
rm -rf ~/.gradle/caches
rm -rf ~/.gradle/wrapper/dists
rm -rf app/build

if [ -f "./gradlew" ]; then GRADLE_CMD="bash gradlew"; else GRADLE_CMD="gradle"; fi

echo "🔨 6. Building APK (this will take a few minutes)..."
$GRADLE_CMD clean
$GRADLE_CMD --refresh-dependencies assembleDebug

if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
    echo "✅✅✅ APK BUILT SUCCESSFULLY!"
    echo "📁 Location: app/build/outputs/apk/debug/app-debug.apk"
else
    echo "❌ Build failed. Please run: cat build.log | grep -i error"
    exit 1
fi
