package com.ultrastream.network

import android.net.Uri
import com.google.gson.Gson
import com.google.gson.JsonParser
import com.ultrastream.UltraStreamApplication
import com.ultrastream.data.models.*
import kotlinx.coroutines.*
import okhttp3.OkHttpClient
import okhttp3.Request
import java.util.concurrent.TimeUnit

object NetworkUtils {

    private val client: OkHttpClient by lazy {
        OkHttpClient.Builder()
            .connectTimeout(15, TimeUnit.SECONDS)
            .readTimeout(15, TimeUnit.SECONDS)
            .build()
    }

    private val gson = Gson()

    suspend fun smartFetchFast(url: String, timeoutMs: Long = 8000): String? {
        return withContext(Dispatchers.IO) {
            try {
                val response = client.newCall(Request.Builder().url(url).build()).execute()
                if (response.isSuccessful) response.body?.string() else null
            } catch (e: Exception) { null }
        }
    }

    suspend fun fetchMeta(metaId: String, metaType: String): MetaItem? {
        val url = "https://v3-cinemeta.strem.io/meta/$metaType/${Uri.encode(metaId)}.json"
        val json = smartFetchFast(url)
        return try {
            if (json != null) {
                val obj = JsonParser.parseString(json).asJsonObject
                if (obj.has("meta")) {
                    gson.fromJson(obj.getAsJsonObject("meta"), MetaItem::class.java)
                } else null
            } else null
        } catch (e: Exception) { null }
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
                        if (debridKey.isNotEmpty() && (url.contains("torrentio") || url.contains("orionoid"))) {
                            url += if (url.contains("?")) "&realdebrid=$debridKey" else "?realdebrid=$debridKey"
                        }
                        
                        val json = smartFetchFast(url, 15000)
                        if (json != null) {
                            val obj = JsonParser.parseString(json).asJsonObject
                            if (obj.has("streams")) {
                                val streamsArray = obj.getAsJsonArray("streams")
                                streamsArray.forEach { streamJson ->
                                    try {
                                        val stream = gson.fromJson(streamJson, Stream::class.java)
                                        allStreams.add(stream.copy(addonName = addon.name))
                                    } catch (e: Exception) {}
                                }
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
        val baseUrl = addonUrl.replace("/manifest.json", "")
        val url = "$baseUrl/catalog/$catalogType/$catalogId.json"
        val json = smartFetchFast(url)
        return try {
            if (json != null) {
                val obj = JsonParser.parseString(json).asJsonObject
                if (obj.has("metas")) {
                    val metasArray = obj.getAsJsonArray("metas")
                    val result = mutableListOf<MetaItem>()
                    metasArray.forEach { metaJson ->
                        result.add(gson.fromJson(metaJson, MetaItem::class.java))
                    }
                    result
                } else emptyList()
            } else emptyList()
        } catch (e: Exception) { emptyList() }
    }
}
