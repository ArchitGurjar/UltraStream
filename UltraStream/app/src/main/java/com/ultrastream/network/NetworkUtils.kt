package com.ultrastream.network

import android.net.Uri
import com.google.gson.Gson
import com.google.gson.JsonParser
import com.ultrastream.UltraStreamApplication
import com.ultrastream.data.models.*
import kotlinx.coroutines.*
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.logging.HttpLoggingInterceptor
import java.util.concurrent.TimeUnit

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

    suspend fun smartFetchFast(url: String, timeoutMs: Long = 8000): String? {
        return withContext(Dispatchers.IO) {
            val controller = CancellationException()
            val timeoutJob = async { delay(timeoutMs); throw TimeoutException("Timeout") }
            val fetchJob = async {
                try {
                    val response = client.newCall(Request.Builder().url(url).build()).execute()
                    if (response.isSuccessful) response.body?.string() else null
                } catch (e: Exception) { null }
            }
            try {
                val result = fetchJob.await()
                timeoutJob.cancel()
                result
            } catch (e: TimeoutException) {
                fetchJob.cancel()
                // Fallback to proxy
                fallbackFetch(url)
            } catch (e: Exception) { null }
        }
    }

    private suspend fun fallbackFetch(url: String): String? {
        val proxies = listOf(
            "https://api.allorigins.win/raw?url=${Uri.encode(url)}",
            "https://corsproxy.io/?${Uri.encode(url)}",
            "https://api.codetabs.com/v1/proxy?quest=${Uri.encode(url)}"
        )
        for (proxy in proxies) {
            try {
                val response = client.newCall(Request.Builder().url(proxy).build()).execute()
                if (response.isSuccessful) return response.body?.string()
            } catch (_: Exception) { continue }
        }
        return null
    }

    suspend fun fetchMeta(metaId: String, metaType: String): MetaItem? {
        val url = "https://v3-cinemeta.strem.io/meta/$metaType/$metaId.json"
        val json = smartFetchFast(url)
        return json?.let {
            try {
                val obj = JsonParser.parseString(it).asJsonObject
                val metaJson = obj.getAsJsonObject("meta")
                gson.fromJson(metaJson, MetaItem::class.java)
            } catch (_: Exception) { null }
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
                        val json = smartFetchFast(url)
                        json?.let {
                            val obj = JsonParser.parseString(it).asJsonObject
                            val streamsArray = obj.getAsJsonArray("streams")
                            streamsArray?.forEach { streamJson ->
                                val stream = gson.fromJson(streamJson, Stream::class.java)
                                allStreams.add(stream.copy(addonName = addon.name))
                            }
                        }
                    } catch (_: Exception) { }
                }
            }
            jobs.awaitAll()
            allStreams
        }
    }

    suspend fun fetchCatalog(addonUrl: String, catalogType: String, catalogId: String): List<MetaItem> {
        val baseUrl = addonUrl.replace("/manifest.json", "")
        val url = "$baseUrl/catalog/$catalogType/$catalogId.json"
        val json = smartFetchFast(url)
        return json?.let {
            try {
                val obj = JsonParser.parseString(it).asJsonObject
                val metasArray = obj.getAsJsonArray("metas")
                val result = mutableListOf<MetaItem>()
                metasArray?.forEach { metaJson ->
                    val meta = gson.fromJson(metaJson, MetaItem::class.java)
                    result.add(meta)
                }
                result
            } catch (_: Exception) { emptyList() }
        } ?: emptyList()
    }

    suspend fun fetchAddonManifest(url: String): AddonManifest? {
        val json = smartFetchFast(url)
        return json?.let {
            try { gson.fromJson(it, AddonManifest::class.java) } catch (_: Exception) { null }
        }
    }
}
