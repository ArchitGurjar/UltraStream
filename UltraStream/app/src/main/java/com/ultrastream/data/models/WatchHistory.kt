package com.ultrastream.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.io.Serializable

@Entity(tableName = "watch_history")
data class WatchHistory(
    @PrimaryKey
    val id: String,
    val type: String,
    val name: String,
    val poster: String? = null,
    val timestamp: Long = System.currentTimeMillis()
) : Serializable
