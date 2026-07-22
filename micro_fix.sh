#!/data/data/com.termux/files/usr/bin/bash
set -e
cd /sdcard/ultrabuild/UltraStream || { echo "Project dir missing"; exit 1; }
FILE="app/src/main/java/com/ultrastream/utils/NetworkUtils.kt"
if [ ! -f "$FILE" ]; then
    echo "NetworkUtils.kt missing, creating..."
    cat > "$FILE" << 'EOF'
package com.ultrastream.utils
import android.net.Uri
import com.google.gson.Gson
import com.google.gson.JsonParser
import com.ultrastream.UltraStreamApplication
import com.ultrastream.data.models.MetaItem
import com.ultrastream.data.models.Stream
import com.ultrastream.utils.AddonManifest
import kotlinx.coroutines.*
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.logging.HttpLoggingInterceptor
import java.util.concurrent.TimeUnit
object NetworkUtils {
    private val client: OkHttpClient by lazy {
        val logging = HttpLoggingInterceptor().apply { level = HttpLoggingInterceptor.Level.BASIC }
        OkHttpClient.Builder().addInterceptor(logging).connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS).writeTimeout(30, TimeUnit.SECONDS).build()
    }
    private val gson = Gson()
    suspend fun fetchMeta(metaId: String, metaType: String): MetaItem? = withContext(Dispatchers.IO) {
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
    suspend fun fetchStreams(metaId: String, metaType: String): List<Stream> = withContext(Dispatchers.IO) {
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
                            allStreams.add(stream.copy(addonName = addon.name))
                        }
                    }
                } catch (e: Exception) { }
            }
        }
        jobs.awaitAll()
        allStreams
    }
    suspend fun fetchCatalog(addonUrl: String, catalogType: String, catalogId: String): List<MetaItem> = withContext(Dispatchers.IO) {
        try {
            val baseUrl = addonUrl.replace("/manifest.json", "")
            val url = "$baseUrl/catalog/$catalogType/$catalogId.json"
            val response = client.newCall(Request.Builder().url(url).build()).execute()
            if (response.isSuccessful) {
                val json = response.body?.string()
                val jsonObject = JsonParser.parseString(json).asJsonObject
                val metasArray = jsonObject.getAsJsonArray("metas")
                val result = mutableListOf<MetaItem>()
                metasArray?.forEach { metaJson -> result.add(gson.fromJson(metaJson, MetaItem::class.java)) }
                return@withContext result
            }
            emptyList()
        } catch (e: Exception) { emptyList() }
    }
    suspend fun fetchAddonManifest(url: String): AddonManifest? = withContext(Dispatchers.IO) {
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
EOF
    echo "Created NetworkUtils.kt"
else
    echo "NetworkUtils.kt exists, checking for import..."
    if ! grep -q "import com.ultrastream.utils.AddonManifest" "$FILE"; then
        sed -i '/^package/a import com.ultrastream.utils.AddonManifest' "$FILE"
        echo "Added import line"
    else
        echo "Import already present"
    fi
fi
if ! grep -q "implementation.*okhttp" app/build.gradle; then
    sed -i '/dependencies {/a\    implementation "com.squareup.okhttp3:okhttp:4.9.1"\n    implementation "com.squareup.okhttp3:logging-interceptor:4.9.1"\n    implementation "com.google.code.gson:gson:2.10.1"' app/build.gradle
fi
if [ -f "./gradlew" ]; then GRADLE_CMD="bash gradlew"; else GRADLE_CMD="gradle"; fi
$GRADLE_CMD clean
rm -rf app/build
echo "Building APK in background with nohup..."
nohup $GRADLE_CMD assembleDebug > micro_build.log 2>&1 &
echo "Build started. Monitor with: tail -f micro_build.log"
sleep 3
tail -f micro_build.log
