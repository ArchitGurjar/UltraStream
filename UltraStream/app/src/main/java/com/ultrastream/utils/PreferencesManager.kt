package com.ultrastream.utils

import android.content.Context
import android.content.SharedPreferences

class PreferencesManager(context: Context) {

    private val prefs: SharedPreferences = context.getSharedPreferences("ultrastream_prefs", Context.MODE_PRIVATE)

    companion object {
        private const val KEY_THEME = "theme"
        private const val KEY_HINDI_PRIORITY = "hindi_priority"
        private const val KEY_AUTOPLAY_NEXT = "autoplay_next"
        private const val KEY_PARENTAL_CONTROL = "parental_control"
        private const val KEY_DEBRID_KEY = "debrid_key"
        private const val KEY_CURRENT_PROFILE = "current_profile"
        private const val KEY_LIBRARY_JSON = "library_json"
        private const val KEY_WATCHLIST_JSON = "watchlist_json"
    }

    fun getTheme(): String = prefs.getString(KEY_THEME, "dark") ?: "dark"
    fun setTheme(theme: String) = prefs.edit().putString(KEY_THEME, theme).apply()

    fun getHindiPriority(): Boolean = prefs.getBoolean(KEY_HINDI_PRIORITY, true)
    fun setHindiPriority(enabled: Boolean) = prefs.edit().putBoolean(KEY_HINDI_PRIORITY, enabled).apply()

    fun getAutoPlayNext(): Boolean = prefs.getBoolean(KEY_AUTOPLAY_NEXT, false)
    fun setAutoPlayNext(enabled: Boolean) = prefs.edit().putBoolean(KEY_AUTOPLAY_NEXT, enabled).apply()

    fun getParentalControl(): Boolean = prefs.getBoolean(KEY_PARENTAL_CONTROL, false)
    fun setParentalControl(enabled: Boolean) = prefs.edit().putBoolean(KEY_PARENTAL_CONTROL, enabled).apply()

    fun getDebridKey(): String = prefs.getString(KEY_DEBRID_KEY, "") ?: ""
    fun setDebridKey(key: String) = prefs.edit().putString(KEY_DEBRID_KEY, key).apply()

    fun getCurrentProfile(): String = prefs.getString(KEY_CURRENT_PROFILE, "default") ?: "default"
    fun setCurrentProfile(id: String) = prefs.edit().putString(KEY_CURRENT_PROFILE, id).apply()

    fun getLibraryJson(): String = prefs.getString(KEY_LIBRARY_JSON, "") ?: ""
    fun setLibraryJson(json: String) = prefs.edit().putString(KEY_LIBRARY_JSON, json).apply()

    fun getWatchlistJson(): String = prefs.getString(KEY_WATCHLIST_JSON, "") ?: ""
    fun setWatchlistJson(json: String) = prefs.edit().putString(KEY_WATCHLIST_JSON, json).apply()

    fun clearAll() = prefs.edit().clear().apply()
}
