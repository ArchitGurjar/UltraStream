#!/data/data/com.termux/files/usr/bin/bash
set -e
cd /sdcard/ultrabuild/UltraStream || { echo "Project dir missing"; exit 1; }

FILE="app/src/main/java/com/ultrastream/utils/NetworkUtils.kt"

# 1. जाँच करें कि import मौजूद है या नहीं
if ! grep -q "import com.ultrastream.utils.AddonManifest" "$FILE"; then
    echo "🔧 AddonManifest import missing – ठीक कर रहे हैं..."
    # package लाइन के बाद import डालें
    sed -i '/^package/a import com.ultrastream.utils.AddonManifest' "$FILE"
    echo "✅ import जोड़ दिया गया।"
else
    echo "✅ import पहले से मौजूद है।"
fi

# 2. अब बिल्ड करें (bash gradlew से)
if [ -f "./gradlew" ]; then
    GRADLE_CMD="bash gradlew"
else
    GRADLE_CMD="gradle"
fi

echo "🔨 बिल्ड शुरू..."
$GRADLE_CMD clean
rm -rf app/build
$GRADLE_CMD assembleDebug

if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
    echo "✅✅✅ APK बन गया! ✅✅✅"
    echo "📁 app/build/outputs/apk/debug/app-debug.apk"
else
    echo "❌ बिल्ड फेल। ऊपर error log देखें।"
    exit 1
fi
