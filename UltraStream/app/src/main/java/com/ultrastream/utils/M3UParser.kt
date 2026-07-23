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
                    trimmed.startsWith("#EXTM3U") -> { /* skip */ }
                    trimmed.startsWith("#EXTINF:") -> {
                        val durationMatch = Regex("#EXTINF:(-?\\d+)").find(trimmed)
                        currentDuration = durationMatch?.groupValues?.get(1)?.toLongOrNull() ?: -1
                        val parts = trimmed.split(",")
                        currentTitle = if (parts.size > 1) parts.drop(1).joinToString(",").trim() else ""
                        val logoMatch = Regex("tvg-logo=\"([^\"]*)\"").find(trimmed)
                        currentLogo = logoMatch?.groupValues?.get(1)
                        val groupMatch = Regex("group-title=\"([^\"]*)\"").find(trimmed)
                        currentGroup = groupMatch?.groupValues?.get(1)
                    }
                    trimmed.isNotEmpty() && !trimmed.startsWith("#") -> {
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
                        currentTitle = ""
                        currentDuration = -1
                        currentGroup = null
                        currentLogo = null
                    }
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
            entry.group?.let { sb.append(" group-title=\"$it\"") }
            entry.logo?.let { sb.append(" tvg-logo=\"$it\"") }
            sb.appendLine(" ,${entry.title}")
            sb.appendLine(entry.url)
        }
        return sb.toString()
    }
}
