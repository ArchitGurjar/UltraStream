// app/src/main/java/com/ultrastream/data/models/Addon.kt
package com.ultrastream.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey
import com.google.gson.annotations.SerializedName

@Entity(tableName = "addons")
data class Addon(
    @PrimaryKey
    val id: String,
    val url: String,
    val name: String,
    val enabled: Boolean = true,
    val required: Boolean = false,
    @SerializedName("catalogs")
    val catalogs: List<Catalog> = emptyList()
)

data class Catalog(
    val type: String,          // movie, series, anime, tv
    val id: String,
    val name: String,
    val extraSupported: List<String>? = null,
    val extra: List<Extra>? = null
)

data class Extra(
    val name: String,
    val isRequired: Boolean = false,
    val options: List<String>? = null
)
