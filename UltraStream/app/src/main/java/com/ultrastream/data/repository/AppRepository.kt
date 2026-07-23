package com.ultrastream.data.repository

import com.ultrastream.data.database.AppDatabase
import com.ultrastream.data.models.*
import com.ultrastream.utils.PreferencesManager
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first

class AppRepository(
    private val db: AppDatabase,
    private val prefs: PreferencesManager
) {

    // Addons
    fun getAddons(): Flow<List<Addon>> = db.addonDao().getAll()
    suspend fun getEnabledAddons(): List<Addon> = db.addonDao().getEnabled().first()
    suspend fun insertAddon(addon: Addon) = db.addonDao().insert(addon)
    suspend fun insertAddons(addons: List<Addon>) = db.addonDao().insertAll(addons)
    suspend fun updateAddon(addon: Addon) = db.addonDao().update(addon)
    suspend fun deleteAddon(id: String) = db.addonDao().deleteById(id)
    suspend fun getAddonById(id: String): Addon? = db.addonDao().getById(id)

    // Meta
    suspend fun getCachedMeta(id: String): MetaItem? = db.metaDao().getById(id)
    suspend fun cacheMeta(meta: MetaItem) = db.metaDao().insert(meta)

    // Playlists
    fun getPlaylists(): Flow<List<SmartPlaylist>> = db.playlistDao().getAll()
    suspend fun getPlaylist(id: String): SmartPlaylist? = db.playlistDao().getById(id)
    suspend fun savePlaylist(playlist: SmartPlaylist) = db.playlistDao().insert(playlist)
    suspend fun updatePlaylist(playlist: SmartPlaylist) = db.playlistDao().update(playlist)
    suspend fun deletePlaylist(id: String) = db.playlistDao().deleteById(id)

    // Profiles
    fun getProfiles(): Flow<List<Profile>> = db.profileDao().getAll()
    suspend fun getProfile(id: String): Profile? = db.profileDao().getById(id)
    suspend fun saveProfile(profile: Profile) = db.profileDao().insert(profile)
    suspend fun saveProfiles(profiles: List<Profile>) = db.profileDao().insertAll(profiles)
    suspend fun deleteProfile(id: String) = db.profileDao().deleteById(id)

    // History
    fun getHistory(): Flow<List<WatchHistory>> = db.watchHistoryDao().getAll()
    suspend fun addHistory(history: WatchHistory) = db.watchHistoryDao().insert(history)
    suspend fun clearHistory() = db.watchHistoryDao().clearAll()
    suspend fun getHistoryCount(): Int = db.watchHistoryDao().getCount()

    // Progress
    fun getProgress(): Flow<List<WatchProgress>> = db.watchProgressDao().getAll()
    suspend fun getProgressById(id: String): WatchProgress? = db.watchProgressDao().getById(id)
    suspend fun saveProgress(progress: WatchProgress) = db.watchProgressDao().insert(progress)
    suspend fun clearProgress() = db.watchProgressDao().clearAll()

    // Watched Episodes
    fun getWatchedEpisodes(): Flow<List<WatchedEpisode>> = db.watchedEpisodeDao().getAll()
    suspend fun getWatchedEpisode(key: String): WatchedEpisode? = db.watchedEpisodeDao().getByKey(key)
    suspend fun markEpisodeWatched(key: String) = db.watchedEpisodeDao().insert(WatchedEpisode(key))
    suspend fun unmarkEpisodeWatched(key: String) = db.watchedEpisodeDao().deleteByKey(key)

    // Preferences helpers
    fun getTheme(): String = prefs.getTheme()
    fun setTheme(theme: String) = prefs.setTheme(theme)
    fun getHindiPriority(): Boolean = prefs.getHindiPriority()
    fun setHindiPriority(enabled: Boolean) = prefs.setHindiPriority(enabled)
    fun getAutoPlayNext(): Boolean = prefs.getAutoPlayNext()
    fun setAutoPlayNext(enabled: Boolean) = prefs.setAutoPlayNext(enabled)
    fun getParentalControl(): Boolean = prefs.getParentalControl()
    fun setParentalControl(enabled: Boolean) = prefs.setParentalControl(enabled)
    fun getDebridKey(): String = prefs.getDebridKey()
    fun setDebridKey(key: String) = prefs.setDebridKey(key)
    fun getCurrentProfile(): String = prefs.getCurrentProfile()
    fun setCurrentProfile(id: String) = prefs.setCurrentProfile(id)

    // Library and Watchlist (stored as JSON in prefs)
    suspend fun getLibrary(): List<MetaItem> {
        val json = prefs.getLibraryJson()
        return if (json.isNotEmpty()) {
            try {
                val type = object : com.google.gson.reflect.TypeToken<List<MetaItem>>() {}.type
                com.google.gson.Gson().fromJson(json, type) ?: emptyList()
            } catch (_: Exception) { emptyList() }
        } else emptyList()
    }

    suspend fun setLibrary(items: List<MetaItem>) {
        val json = com.google.gson.Gson().toJson(items)
        prefs.setLibraryJson(json)
    }

    suspend fun getWatchlist(): List<MetaItem> {
        val json = prefs.getWatchlistJson()
        return if (json.isNotEmpty()) {
            try {
                val type = object : com.google.gson.reflect.TypeToken<List<MetaItem>>() {}.type
                com.google.gson.Gson().fromJson(json, type) ?: emptyList()
            } catch (_: Exception) { emptyList() }
        } else emptyList()
    }

    suspend fun setWatchlist(items: List<MetaItem>) {
        val json = com.google.gson.Gson().toJson(items)
        prefs.setWatchlistJson(json)
    }

    suspend fun clearAllData() {
        db.watchHistoryDao().clearAll()
        db.watchProgressDao().clearAll()
        db.watchedEpisodeDao().clearAll()
        prefs.clearAll()
    }
}
