package com.ultrastream.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey
import com.google.gson.annotations.SerializedName
import java.io.Serializable

@Entity(tableName = "meta_cache")
data class MetaItem(
    @PrimaryKey
    val id: String,
    val type: String,
    val name: String,
    val poster: String? = null,
    val background: String? = null,
    val description: String? = null,
    val year: Int? = null,
    val runtime: String? = null,
    val imdbRating: Float? = null,
    val imdbId: String? = null,
    val genre: List<String>? = null,
    val releaseInfo: String? = null,
    val released: String? = null,
    val cast: List<String>? = null,
    val videos: List<Video>? = null,
    val cachedAt: Long = System.currentTimeMillis()
) : Serializable

data class Video(
    val season: Int,
    val episode: Int,
    val name: String? = null,
    val title: String? = null,
    val description: String? = null,
    val thumbnail: String? = null,
    val url: String? = null
)
