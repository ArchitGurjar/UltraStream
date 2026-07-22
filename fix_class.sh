#!/data/data/com.termux/files/usr/bin/bash
set -e
cd /sdcard/ultrabuild/UltraStream || { echo "Project dir missing"; exit 1; }
FILE="app/src/main/java/com/ultrastream/utils/NetworkUtils.kt"
if ! grep -q "data class AddonManifest" "$FILE"; then
    echo "Adding AddonManifest class to NetworkUtils.kt..."
    awk -v class="
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
" '
    /^object NetworkUtils/ { print class; print "" }
    { print }
    ' "$FILE" > tmp && mv tmp "$FILE"
fi
if ! grep -q "implementation.*okhttp" app/build.gradle; then
    sed -i '/dependencies {/a\    implementation "com.squareup.okhttp3:okhttp:4.9.1"\n    implementation "com.squareup.okhttp3:logging-interceptor:4.9.1"\n    implementation "com.google.code.gson:gson:2.10.1"' app/build.gradle
fi
if [ -f "./gradlew" ]; then GRADLE_CMD="bash gradlew"; else GRADLE_CMD="gradle"; fi
$GRADLE_CMD clean
rm -rf app/build
echo "Building APK in background..."
nohup $GRADLE_CMD assembleDebug > class_build.log 2>&1 &
echo "Build started. Monitor: tail -f class_build.log"
sleep 3
tail -f class_build.log
