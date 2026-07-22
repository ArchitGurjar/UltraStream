#!/data/data/com.termux/files/usr/bin/bash
set -e
cd /sdcard/ultrabuild/UltraStream || { echo "Project dir missing"; exit 1; }
export ANDROID_HOME=$HOME/android-sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools
export JAVA_HOME=/data/data/com.termux/files/usr/lib/jvm/java-21-openjdk
export GRADLE_HOME=$HOME/gradle
export PATH=$HOME/gradle/bin:$JAVA_HOME/bin:$PATH
echo "Cleaning Gradle cache..."
rm -rf ~/.gradle/caches
rm -rf ~/.gradle/wrapper/dists
if [ -f "./gradlew" ]; then GRADLE_CMD="bash gradlew"; else GRADLE_CMD="gradle"; fi
$GRADLE_CMD clean
rm -rf app/build
echo "Building APK with cache refresh..."
nohup $GRADLE_CMD --refresh-dependencies assembleDebug > cache_build.log 2>&1 &
echo "Build started. Monitor: tail -f cache_build.log"
sleep 3
tail -f cache_build.log
