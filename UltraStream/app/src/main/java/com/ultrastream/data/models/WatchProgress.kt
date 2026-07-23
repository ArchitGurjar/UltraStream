// app/src/main/java/com/ultrastream/data/models/WatchProgress.kt
package com.ultrastream.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.io.Serializable

@Entity(tableName = "watch_progress")
data class WatchProgress(
    @PrimaryKey
    val id: String,           // can be video id or episode key
    val percent: Float = 0f,
    val lastUpdate: Long = System.currentTimeMillis()
) : Serializable
