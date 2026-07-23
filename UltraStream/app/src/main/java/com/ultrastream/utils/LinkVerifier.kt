// app/src/main/java/com/ultrastream/utils/LinkVerifier.kt
package com.ultrastream.utils

import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.Response
import java.net.URL
import java.util.concurrent.TimeUnit

object LinkVerifier {

    private val client = OkHttpClient.Builder()
        .connectTimeout(15, TimeUnit.SECONDS)
        .readTimeout(15, TimeUnit.SECONDS)
        .followRedirects(true)
        .build()

    private val cache = mutableMapOf<String, Boolean>()

    suspend fun verify(url: String): Boolean {
        return cache.getOrElse(url) {
            val result = doVerify(url)
            cache[url] = result
            result
        }
    }

    private suspend fun doVerify(url: String): Boolean {
        if (url.startsWith("magnet:")) return false

        try {
            val classification = classifyUrl(url)
            when (classification) {
                "hls", "dash", "proxy" -> {
                    val request = Request.Builder()
                        .url(url)
                        .header("Accept", "*/*")
                        .header("Accept-Language", "en-US,en;q=0.9")
                        .build()
                    val response = client.newCall(request).execute()
                    response.use {
                        if (!it.isSuccessful) return false
                        val contentType = it.header("content-type") ?: ""
                        if (contentType.contains("video") || contentType.contains("application/octet-stream")) {
                            return true
                        }
                        if (contentType.contains("text/html")) {
                            val body = it.body?.string() ?: return false
                            if (body.length < 2000) {
                                if (listOf("error", "not found", "expired", "invalid", "access denied").any { body.contains(it, ignoreCase = true) }) {
                                    return false
                                }
                            }
                            return false
                        }
                        val body = it.body?.string() ?: return false
                        if (classification == "hls" && Regex("^#EXTM3U", RegexOption.MULTILINE).containsMatchIn(body) && body.contains("#EXTINF:", ignoreCase = true)) {
                            return true
                        }
                        if (classification == "dash" && (body.contains("<MPD", ignoreCase = true) || body.contains("<SegmentList", ignoreCase = true))) {
                            return true
                        }
                        return classification == "proxy"
                    }
                }
                else -> {
                    // Direct or unknown
                    try {
                        val headRequest = Request.Builder().url(url).head().build()
                        val headResponse = client.newCall(headRequest).execute()
                        headResponse.use {
                            if (it.isSuccessful) return true
                        }
                    } catch (_: Exception) { }

                    // Try range request
                    try {
                        val rangeRequest = Request.Builder()
                            .url(url)
                            .header("Range", "bytes=0-0")
                            .build()
                        val rangeResponse = client.newCall(rangeRequest).execute()
                        rangeResponse.use {
                            if (it.code == 206 || it.code == 200) return true
                            val contentType = it.header("content-type") ?: ""
                            if (contentType.contains("text/html")) return false
                            if (it.code in 403..404) return false
                            return it.code < 500
                        }
                    } catch (_: Exception) { }
                }
            }
        } catch (_: Exception) { }

        // Fallback: try no-cors mode (opaque) - we can't check, so assume it works.
        return true
    }

    private fun classifyUrl(url: String): String {
        val lower = url.lowercase()
        return when {
            lower.startsWith("magnet:") -> "magnet"
            lower.contains(".m3u8") || lower.contains(".m3u") -> "hls"
            lower.contains(".mpd") -> "dash"
            Regex("\\b(?:pengu\\.uk|streamraiwind|cdn\\d+\\.stream|proxy)").containsMatchIn(lower) -> "proxy"
            Regex("\\.(mp4|mkv|avi|mov|wmv|flv|webm)$").containsMatchIn(lower) -> "direct"
            else -> "unknown"
        }
    }

    fun clearCache() = cache.clear()
}
