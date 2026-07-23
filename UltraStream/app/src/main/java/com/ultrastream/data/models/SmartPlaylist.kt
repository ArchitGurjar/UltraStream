package com.ultrastream.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.io.Serializable

@Entity(tableName = "smart_playlists")
data class SmartPlaylist(
    @PrimaryKey
    val id: String,
    val metaId: String,
    val metaName: String,
    val poster: String? = null,
    val season: Int,
    val addon: String,
    val total: Int,
    val fetched: Int = 0,
    val status: String = "Fetching...",
    val episodes: List<PlaylistEpisode> = emptyList()
) : Serializable

data class PlaylistEpisode(
    val epNum: Int,
    val epName: String,
    val title: String,
    val stream: Stream? = null,
    val isMissing: Boolean = false
)
