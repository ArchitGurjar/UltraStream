#!/data/data/com.termux/files/usr/bin/bash
set -e
cd /sdcard/ultrabuild/UltraStream || { echo "Project dir missing"; exit 1; }
export ANDROID_HOME=$HOME/android-sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/34.0.0
export JAVA_HOME=/data/data/com.termux/files/usr/lib/jvm/java-21-openjdk
export GRADLE_HOME=$HOME/gradle
export PATH=$HOME/gradle/bin:$JAVA_HOME/bin:$PATH
if [ ! -d "$ANDROID_HOME" ]; then
    echo "Android SDK not found. Installing..."
    mkdir -p $ANDROID_HOME
    cd $ANDROID_HOME
    wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
    unzip commandlinetools-linux-*.zip
    mv cmdline-tools latest
    mkdir -p latest
    mv cmdline-tools/* latest/ 2>/dev/null || true
    cd latest/bin
    yes | ./sdkmanager --sdk_root=$ANDROID_HOME "build-tools;34.0.0" "platform-tools" "platforms;android-34"
fi
if [ ! -d "$ANDROID_HOME/build-tools/34.0.0" ]; then
    echo "Build-tools missing, installing..."
    $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_HOME "build-tools;34.0.0"
fi
if [ -f "./gradle.properties" ]; then
    sed -i '/android.aapt2FromMavenOverride/d' gradle.properties
fi
if [ -f "./gradlew" ]; then GRADLE_CMD="bash gradlew"; else GRADLE_CMD="gradle"; fi
rm -rf ~/.gradle/caches
$GRADLE_CMD clean
rm -rf app/build
echo "Building APK..."
nohup $GRADLE_CMD assembleDebug > sdk_build.log 2>&1 &
echo "Build started. Monitor: tail -f sdk_build.log"
sleep 3
tail -f sdk_build.log
