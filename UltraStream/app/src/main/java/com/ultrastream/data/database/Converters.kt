package com.ultrastream.data.database

import androidx.room.TypeConverter
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.ultrastream.data.models.*

class Converters {

    @TypeConverter
    fun fromCatalogList(value: List<Catalog>): String = Gson().toJson(value)

    @TypeConverter
    fun toCatalogList(value: String): List<Catalog> {
        val type = object : TypeToken<List<Catalog>>() {}.type
        return Gson().fromJson(value, type) ?: emptyList()
    }

    @TypeConverter
    fun fromVideoList(value: List<Video>): String = Gson().toJson(value)

    @TypeConverter
    fun toVideoList(value: String): List<Video> {
        val type = object : TypeToken<List<Video>>() {}.type
        return Gson().fromJson(value, type) ?: emptyList()
    }

    @TypeConverter
    fun fromPlaylistEpisodeList(value: List<PlaylistEpisode>): String = Gson().toJson(value)

    @TypeConverter
    fun toPlaylistEpisodeList(value: String): List<PlaylistEpisode> {
        val type = object : TypeToken<List<PlaylistEpisode>>() {}.type
        return Gson().fromJson(value, type) ?: emptyList()
    }

    @TypeConverter
    fun fromStringList(value: List<String>): String = Gson().toJson(value)

    @TypeConverter
    fun toStringList(value: String): List<String> {
        val type = object : TypeToken<List<String>>() {}.type
        return Gson().fromJson(value, type) ?: emptyList()
    }

    @TypeConverter
    fun fromStream(value: Stream?): String = Gson().toJson(value)

    @TypeConverter
    fun toStream(value: String): Stream? = Gson().fromJson(value, Stream::class.java)

    @TypeConverter
    fun fromSubtitleList(value: List<Subtitle>?): String = Gson().toJson(value)

    @TypeConverter
    fun toSubtitleList(value: String): List<Subtitle>? {
        val type = object : TypeToken<List<Subtitle>>() {}.type
        return Gson().fromJson(value, type)
    }
}
