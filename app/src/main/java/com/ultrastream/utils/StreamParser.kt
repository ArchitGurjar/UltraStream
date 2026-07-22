// app/src/main/java/com/ultrastream/utils/StreamParser.kt
package com.ultrastream.utils

import java.util.regex.Pattern

object StreamParser {

    data class ParsedStreamInfo(
        val size: String? = null,
        val sizeValueBytes: Double? = null,
        val seeds: String? = null,
        val langs: List<String> = emptyList(),
        val quals: List<String> = emptyList(),
        val isLive: Boolean = false,
        val hasHindi: Boolean = false,
        val cleanText: String = "",
        val parsedYear: String? = null,
        val parsedSeason: Int? = null,
        val parsedEpisode: Int? = null
    )

    fun parse(rawText: String): ParsedStreamInfo {
        val text = rawText.lowercase()

        // Size
        val sizePattern = Pattern.compile("\\b(\\d+(?:\\.\\d+)?)\\s*(gb|mb)\\b", Pattern.CASE_INSENSITIVE)
        val sizeMatcher = sizePattern.matcher(text)
        var size: String? = null
        var sizeValueBytes: Double? = null
        if (sizeMatcher.find()) {
            size = sizeMatcher.group(0).uppercase()
            val value = sizeMatcher.group(1).toDoubleOrNull()
            val unit = sizeMatcher.group(2).lowercase()
            if (value != null) {
                sizeValueBytes = if (unit == "gb") {
                    value * 1024 * 1024 * 1024
                } else {
                    value * 1024 * 1024
                }
            }
        }

        // Seeds
        val seedPattern = Pattern.compile("(?:seeders|seeds|s)[:\\s]*(\\d+)", Pattern.CASE_INSENSITIVE)
        val seedMatcher = seedPattern.matcher(text)
        var seeds: String? = null
        if (seedMatcher.find()) {
            seeds = seedMatcher.group(1)
        }

        // Languages
        val langPattern = Pattern.compile(
            "\\b(hindi|english|tamil|telugu|malayalam|bengali|dual audio|multi audio|हिंदी|हिन्दी)\\b",
            Pattern.CASE_INSENSITIVE
        )
        val langMatcher = langPattern.matcher(text)
        val langs = mutableListOf<String>()
        while (langMatcher.find()) {
            val lang = langMatcher.group(1).replaceFirstChar { it.uppercase() }
            if (!langs.contains(lang)) {
                langs.add(lang)
            }
        }

        // Qualities
        val qualPattern = Pattern.compile(
            "\\b(4k|2160p|1080p|720p|480p|hdr|dv|cam|hdts|hdtc)\\b",
            Pattern.CASE_INSENSITIVE
        )
        val qualMatcher = qualPattern.matcher(text)
        val quals = mutableListOf<String>()
        while (qualMatcher.find()) {
            val qual = qualMatcher.group(1).uppercase()
            if (!quals.contains(qual)) {
                quals.add(qual)
            }
        }

        // Hindi check
        val hasHindi = langs.any { it.contains("hindi", ignoreCase = true) }

        // Live check
        val isLive = text.contains("live") || text.contains("iptv") || text.contains("stream")

        // Year
        val yearPattern = Pattern.compile("\\b(19\\d{2}|20[0-2]\\d)\\b")
        val yearMatcher = yearPattern.matcher(text)
        var parsedYear: String? = null
        if (yearMatcher.find()) {
            parsedYear = yearMatcher.group(1)
        }

        // Season and Episode
        var parsedSeason: Int? = null
        var parsedEpisode: Int? = null

        // Pattern: S01E05
        val sxePattern = Pattern.compile("s(\\d{1,2})[-_\\s]*e(\\d{1,4})", Pattern.CASE_INSENSITIVE)
        val sxeMatcher = sxePattern.matcher(text)
        if (sxeMatcher.find()) {
            parsedSeason = sxeMatcher.group(1).toIntOrNull()
            parsedEpisode = sxeMatcher.group(2).toIntOrNull()
        } else {
            // Pattern: 1x05 (but not 1920x1080)
            val axbPattern = Pattern.compile("(?:^|[^a-z0-9])(\\d{1,2})x(\\d{1,4})(?:[^a-z0-9]|$)", Pattern.CASE_INSENSITIVE)
            val axbMatcher = axbPattern.matcher(text)
            if (axbMatcher.find()) {
                val season = axbMatcher.group(1).toIntOrNull()
                if (season != null && season < 100) {
                    parsedSeason = season
                    parsedEpisode = axbMatcher.group(2).toIntOrNull()
                }
            }
        }

        // Clean text
        var cleanText = rawText
        cleanText = cleanText.replace(Regex("\\b(\\d+(?:\\.\\d+)?\\s*(?:gb|mb))\\b", RegexOption.IGNORE_CASE), "")
        cleanText = cleanText.replace(Regex("(?:seeders|seeds|s)[:\\s]*(\\d+)", RegexOption.IGNORE_CASE), "")
        cleanText = cleanText.replace(
            Regex("\\b(hindi|english|tamil|telugu|malayalam|bengali|dual audio|multi audio|हिंदी|हिन्दी)\\b", RegexOption.IGNORE_CASE),
            ""
        )
        cleanText = cleanText.replace(
            Regex("\\b(4k|2160p|1080p|720p|480p|hdr|dv|cam|hdts|hdtc)\\b", RegexOption.IGNORE_CASE),
            ""
        )
        cleanText = cleanText.replace(Regex("[\\u{1F300}-\\u{1F9FF}]"), "")
        cleanText = cleanText.replace(Regex("[\\u{2600}-\\u{26FF}]"), "")
        cleanText = cleanText.trim()
        if (cleanText.isEmpty()) {
            cleanText = "Direct Video Stream"
        }

        return ParsedStreamInfo(
            size = size,
            sizeValueBytes = sizeValueBytes,
            seeds = seeds,
            langs = langs,
            quals = quals,
            isLive = isLive,
            hasHindi = hasHindi,
            cleanText = cleanText,
            parsedYear = parsedYear,
            parsedSeason = parsedSeason,
            parsedEpisode = parsedEpisode
        )
    }
}
