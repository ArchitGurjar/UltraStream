package com.ultrastream.utils

import com.ultrastream.data.models.Stream

object EpisodeMatcher {

    fun isValidEpisodeStream(stream: Stream, targetSeason: Int?, targetEpisode: Int?): Boolean {
        if (targetSeason == null || targetEpisode == null) return true

        val text = ((stream.title ?: "") + " " + (stream.name ?: "") + " " + (stream.description ?: "")).uppercase()

        val isPack = Regex("(SEASON \\d+ COMPLETE|S\\d+ COMPLETE|S\\d+ PACK|BATCH|\\bS\\d+\\b(?!.*E\\d+)| \\d{1,2}-\\d{1,2} |E\\d+-E\\d+)", RegexOption.IGNORE_CASE).containsMatchIn(text)

        var hasExplicitEpisode = false
        var episodeMatchFound = false

        val epRegex = Regex("(?:^|[^A-Z])(?:E|EP|EPISODE)[-_\\s]*(\\d{1,4})(?:[^A-Z]|$)", RegexOption.IGNORE_CASE)
        epRegex.findAll(text).forEach {
            hasExplicitEpisode = true
            if (it.groupValues[1].toIntOrNull() == targetEpisode) episodeMatchFound = true
        }

        val sxeRegex = Regex("S(\\d{1,2})[-_\\s]*E(\\d{1,4})", RegexOption.IGNORE_CASE)
        sxeRegex.findAll(text).forEach {
            hasExplicitEpisode = true
            val s = it.groupValues[1].toIntOrNull()
            val e = it.groupValues[2].toIntOrNull()
            if (s == targetSeason && e == targetEpisode) episodeMatchFound = true
        }

        val axbRegex = Regex("(?:^|[^A-Z0-9])(\\d{1,2})x(\\d{1,4})(?:[^A-Z0-9]|$)", RegexOption.IGNORE_CASE)
        axbRegex.findAll(text).forEach {
            val season = it.groupValues[1].toIntOrNull()
            if (season != null && season < 100) {
                hasExplicitEpisode = true
                val ep = it.groupValues[2].toIntOrNull()
                if (season == targetSeason && ep == targetEpisode) episodeMatchFound = true
            }
        }

        if (hasExplicitEpisode) return episodeMatchFound

        if (!isPack) {
            val isolatedNumRegex = Regex("(?:^|[\\s\\-_\\[\\]])(\\d{1,4})(?:[\\s\\-_\\[\\]]|$)")
            var foundAnyIso = false
            var isoMatchFound = false
            isolatedNumRegex.findAll(text).forEach {
                val num = it.groupValues[1].toIntOrNull()
                if (num != null && !listOf(720, 1080, 2160, 480, 264, 265, 10).contains(num) && !(num in 1900..2100)) {
                    foundAnyIso = true
                    if (num == targetEpisode) isoMatchFound = true
                }
            }
            if (foundAnyIso && !isoMatchFound) return false
        }

        return true
    }
}
