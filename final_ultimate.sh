#!/data/data/com.termux/files/usr/bin/bash
set -e
echo "Moving project to internal storage..."
mkdir -p ~/UltraStream
cp -r /sdcard/ultrabuild/UltraStream/* ~/UltraStream/
cd ~/UltraStream
rm -rf app/build .gradle gradle/wrapper/dists
export JAVA_HOME=/data/data/com.termux/files/usr/lib/jvm/java-21-openjdk
export PATH=$JAVA_HOME/bin:$PATH
if [ -f "./gradlew" ]; then chmod +x gradlew; GRADLE_CMD="./gradlew"; else GRADLE_CMD="gradle"; fi
echo "Cleaning and building..."
$GRADLE_CMD clean
$GRADLE_CMD assembleDebug
if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
    echo "✅ APK built at: ~/UltraStream/app/build/outputs/apk/debug/app-debug.apk"
else
    echo "❌ Build failed. Check logs above."
fi
