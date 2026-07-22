#!/data/data/com.termux/files/usr/bin/bash
set -e
cd /sdcard/ultrabuild/UltraStream || { echo "Project dir missing"; exit 1; }

# 1. Environment setup
export ANDROID_HOME=$HOME/android-sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/34.0.0
export JAVA_HOME=/data/data/com.termux/files/usr/lib/jvm/java-21-openjdk
export GRADLE_HOME=$HOME/gradle
export PATH=$HOME/gradle/bin:$JAVA_HOME/bin:$PATH

# 2. Remove aapt2 override
sed -i '/android.aapt2FromMavenOverride/d' gradle.properties

# 3. Remove old NetworkUtils.kt
rm -f app/src/main/java/com/ultrastream/utils/NetworkUtils.kt

# 4. Create new NetworkUtils.kt with AddonManifest inside
cat > app/src/main/java/com/ultrastream/utils/NetworkUtils.kt << 'EOF'
package com.ultrastream.utils

import android.net.Uri
import com.google.gson.Gson
import com.google.gson.JsonParser
import com.ultrastream.UltraStreamApplication
import com.ultrastream.data.models.MetaItem
import com.ultrastream.data.models.Stream
import kotlinx.coroutines.*
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.logging.HttpLoggingInterceptor
import java.util.concurrent.TimeUnit

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

# 5. Ensure build.gradle has required dependencies
if ! grep -q "implementation.*okhttp" app/build.gradle; then
    sed -i '/dependencies {/a\    implementation "com.squareup.okhttp3:okhttp:4.9.1"\n    implementation "com.squareup.okhttp3:logging-interceptor:4.9.1"\n    implementation "com.google.code.gson:gson:2.10.1"' app/build.gradle
fi

# 6. Clean and build
if [ -f "./gradlew" ]; then GRADLE_CMD="bash gradlew"; else GRADLE_CMD="gradle"; fi
echo "🧹 Cleaning..."
$GRADLE_CMD clean
rm -rf app/build
echo "🔨 Building APK..."
$GRADLE_CMD --refresh-dependencies assembleDebug

# 7. Check result
if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
    echo "✅✅✅ APK BUILT SUCCESSFULLY: app/build/outputs/apk/debug/app-debug.apk"
else
    echo "❌ Build failed. Check error logs above."
    echo "Run 'cat error_report.txt' to see errors."
fi
