#!/data/data/com.termux/files/usr/bin/bash
set -e
cd /sdcard/ultrabuild/UltraStream || { echo "Project dir missing"; exit 1; }
export ANDROID_HOME=$HOME/android-sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/34.0.0
export JAVA_HOME=/data/data/com.termux/files/usr/lib/jvm/java-21-openjdk
export GRADLE_HOME=$HOME/gradle
export PATH=$HOME/gradle/bin:$JAVA_HOME/bin:$PATH
echo "🔧 Removing aapt2 override..."
sed -i '/android.aapt2FromMavenOverride/d' gradle.properties
echo "✅ aapt2 override removed."
echo "📦 Installing/Checking build-tools 34.0.0..."
if [ ! -d "$ANDROID_HOME/build-tools/34.0.0" ]; then
    if [ ! -f "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]; then
        echo "SDK Manager not found, installing SDK..."
        mkdir -p $ANDROID_HOME
        cd $ANDROID_HOME
        wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
        unzip -q commandlinetools-linux-*.zip
        mkdir -p cmdline-tools/latest
        mv cmdline-tools/* cmdline-tools/latest/ 2>/dev/null || true
    fi
    echo "Installing build-tools 34.0.0..."
    yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_HOME "build-tools;34.0.0"
else
    echo "✅ build-tools 34.0.0 already installed."
fi
if [ -f "./gradlew" ]; then GRADLE_CMD="bash gradlew"; else GRADLE_CMD="gradle"; fi
echo "🧹 Cleaning Gradle caches..."
rm -rf ~/.gradle/caches
rm -rf ~/.gradle/wrapper/dists
$GRADLE_CMD clean
rm -rf app/build
echo "🔨 Building APK with fresh dependencies..."
nohup $GRADLE_CMD --refresh-dependencies assembleDebug > build_output.log 2>&1 &
echo "Build started. Monitor: tail -f build_output.log"
sleep 3
tail -f build_output.log &
echo "⏳ Waiting for build to finish..."
wait
echo "📝 Generating error report..."
REPORT="error_report.txt"
echo "===== BUILD ERRORS =====" > $REPORT
grep -i "error" build_output.log >> $REPORT 2>/dev/null || echo "No errors found." >> $REPORT
echo "" >> $REPORT
echo "===== UNRESOLVED REFERENCES =====" >> $REPORT
grep -i "unresolved" build_output.log >> $REPORT 2>/dev/null || echo "None." >> $REPORT
echo "" >> $REPORT
echo "===== OTHER ISSUES =====" >> $REPORT
grep -i "FAILURE" build_output.log >> $REPORT 2>/dev/null || echo "None." >> $REPORT
cat $REPORT
if grep -q "BUILD SUCCESSFUL" build_output.log; then
    echo "✅✅✅ BUILD SUCCESSFUL! APK: app/build/outputs/apk/debug/app-debug.apk"
else
    echo "❌❌❌ BUILD FAILED. Check error_report.txt for details."
fi
