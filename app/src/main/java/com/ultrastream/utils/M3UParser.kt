// app/src/main/java/com/ultrastream/utils/M3UParser.kt
package com.ultrastream.utils

import java.io.BufferedReader
import java.io.StringReader

object M3UParser {

    data class M3UEntry(
        val title: String,
        val url: String,
        val duration: Long = -1,
        val group: String? = null,
        val logo: String? = null
    )

    fun parse(content: String): List<M3UEntry> {
        val entries = mutableListOf<M3UEntry>()
        var currentTitle = ""
        var currentDuration: Long = -1
        var currentGroup: String? = null
        var currentLogo: String? = null

        BufferedReader(StringReader(content)).useLines { lines ->
            lines.forEach { line ->
                val trimmed = line.trim()
                when {
                    trimmed.startsWith("#EXTM3U") -> {
                        // Skip header
                    }
                    trimmed.startsWith("#EXTINF:") -> {
                        // Parse EXTINF
                        val durationMatch = Regex("#EXTINF:(-?\\d+)").find(trimmed)
                        currentDuration = durationMatch?.groupValues?.get(1)?.toLongOrNull() ?: -1

                        // Extract title and other attributes
                        val parts = trimmed.split(",")
                        if (parts.size > 1) {
                            currentTitle = parts.drop(1).joinToString(",").trim()
                        } else {
                            currentTitle = ""
                        }

                        // Extract tvg-logo
                        val logoMatch = Regex("tvg-logo=\"([^\"]*)\"").find(trimmed)
                        currentLogo = logoMatch?.groupValues?.get(1)

                        // Extract group-title
                        val groupMatch = Regex("group-title=\"([^\"]*)\"").find(trimmed)
                        currentGroup = groupMatch?.groupValues?.get(1)
                    }
                    trimmed.isNotEmpty() && !trimmed.startsWith("#") -> {
                        // This is the URL
                        if (currentTitle.isNotEmpty()) {
                            entries.add(
                                M3UEntry(
                                    title = currentTitle,
                                    url = trimmed,
                                    duration = currentDuration,
                                    group = currentGroup,
                                    logo = currentLogo
                                )
                            )
                        }
                        // Reset for next entry
                        currentTitle = ""
                        currentDuration = -1
                        currentGroup = null
                        currentLogo = null
                    }
                    // Skip other comment lines
                }
            }
        }

        return entries
    }

    fun generate(entries: List<M3UEntry>): String {
        val sb = StringBuilder()
        sb.appendLine("#EXTM3U")
        
        entries.forEach { entry ->
            sb.append("#EXTINF:${entry.duration}")
            if (entry.group != null) {
                sb.append(" group-title=\"${entry.group}\"")
            }
            if (entry.logo != null) {
                sb.append(" tvg-logo=\"${entry.logo}\"")
            }
            sb.appendLine(" ,${entry.title}")
            sb.appendLine(entry.url)
        }
        
        return sb.toString()
    }
}
