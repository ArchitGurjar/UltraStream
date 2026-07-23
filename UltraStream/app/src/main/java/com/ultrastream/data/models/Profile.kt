// app/src/main/java/com/ultrastream/data/models/Profile.kt
package com.ultrastream.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.io.Serializable

@Entity(tableName = "profiles")
data class Profile(
    @PrimaryKey
    val id: String,
    val name: String,
    val avatar: String = name.firstOrNull()?.uppercase() ?: "U"
) : Serializable
