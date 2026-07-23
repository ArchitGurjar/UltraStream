package com.ultrastream.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.io.Serializable

@Entity(tableName = "watched_episodes")
data class WatchedEpisode(
    @PrimaryKey
    val episodeKey: String,
    val isWatched: Boolean = true,
    val timestamp: Long = System.currentTimeMillis()
) : Serializable
