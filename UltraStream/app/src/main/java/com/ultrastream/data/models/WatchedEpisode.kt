// app/src/main/java/com/ultrastream/data/models/WatchedEpisode.kt
package com.ultrastream.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.io.Serializable

@Entity(tableName = "watched_episodes")
data class WatchedEpisode(
    @PrimaryKey
    val episodeKey: String,   // format: "metaId_sSeason_eEpisode"
    val isWatched: Boolean = true,
    val timestamp: Long = System.currentTimeMillis()
) : Serializable
