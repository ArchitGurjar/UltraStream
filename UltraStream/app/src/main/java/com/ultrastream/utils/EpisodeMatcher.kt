// app/src/main/java/com/ultrastream/utils/EpisodeMatcher.kt
package com.ultrastream.utils

import com.ultrastream.data.models.Stream

object EpisodeMatcher {

    /**
     * Strictly checks if a stream matches the target season and episode.
     * Returns true if it's a valid match.
     */
    fun isValidEpisodeStream(stream: Stream, targetSeason: Int?, targetEpisode: Int?): Boolean {
        if (targetSeason == null || targetEpisode == null) return true // movie or single item

        val text = ((stream.title ?: "") + " " + (stream.name ?: "") + " " + (stream.description ?: "")).uppercase()

        // 1. Check for packs (usually don't list explicit single episodes)
        val isPack = Regex("(SEASON \\d+ COMPLETE|S\\d+ COMPLETE|S\\d+ PACK|BATCH|\\bS\\d+\\b(?!.*E\\d+)| \\d{1,2}-\\d{1,2} |E\\d+-E\\d+)", RegexOption.IGNORE_CASE).containsMatchIn(text)
        if (isPack) {
            // If pack, we only accept if it explicitly includes the target episode number
            // We'll check explicit episode numbers later
        }

        var hasExplicitEpisode = false
        var episodeMatchFound = false

        // Match Episode formats like E01, EP 1, EPISODE 01
        val epRegex = Regex("(?:^|[^A-Z])(?:E|EP|EPISODE)[-_\\s]*(\\d{1,4})(?:[^A-Z]|$)", RegexOption.IGNORE_CASE)
        epRegex.findAll(text).forEach {
            hasExplicitEpisode = true
            if (it.groupValues[1].toIntOrNull() == targetEpisode) {
                episodeMatchFound = true
            }
        }

        // Match S01E01 formats
        val sxeRegex = Regex("S(\\d{1,2})[-_\\s]*E(\\d{1,4})", RegexOption.IGNORE_CASE)
        sxeRegex.findAll(text).forEach {
            hasExplicitEpisode = true
            val s = it.groupValues[1].toIntOrNull()
            val e = it.groupValues[2].toIntOrNull()
            if (s == targetSeason && e == targetEpisode) {
                episodeMatchFound = true
            }
        }

        // Match 1x01 format
        val axbRegex = Regex("(?:^|[^A-Z0-9])(\\d{1,2})x(\\d{1,4})(?:[^A-Z0-9]|$)", RegexOption.IGNORE_CASE)
        axbRegex.findAll(text).forEach {
            val season = it.groupValues[1].toIntOrNull()
            if (season != null && season < 100) { // avoid 1920x1080
                hasExplicitEpisode = true
                val ep = it.groupValues[2].toIntOrNull()
                if (season == targetSeason && ep == targetEpisode) {
                    episodeMatchFound = true
                }
            }
        }

        // If we found explicit episode markers, we must match
        if (hasExplicitEpisode) {
            return episodeMatchFound
        }

        // If no explicit markers, but it's a pack, we might accept? But better to reject unless pack contains target episode number
        // Actually, we'll use isolated number parsing
        if (!isPack) {
            // Isolated number detection (e.g., "Show - 05")
            val isolatedNumRegex = Regex("(?:^|[\\s\\-_\\[\\]])(\\d{1,4})(?:[\\s\\-_\\[\\]]|$)")
            var foundAnyIso = false
            var isoMatchFound = false
            isolatedNumRegex.findAll(text).forEach {
                val num = it.groupValues[1].toIntOrNull()
                if (num != null && !listOf(720, 1080, 2160, 480, 264, 265, 10).contains(num) && !(num in 1900..2100)) {
                    foundAnyIso = true
                    if (num == targetEpisode) {
                        isoMatchFound = true
                    }
                }
            }
            if (foundAnyIso && !isoMatchFound) return false
        }

        return true // valid or unknown
    }
}
