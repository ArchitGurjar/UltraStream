package com.ultrastream.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.io.Serializable

@Entity(tableName = "watch_progress")
data class WatchProgress(
    @PrimaryKey
    val id: String,
    val percent: Float = 0f,
    val lastUpdate: Long = System.currentTimeMillis()
) : Serializable
