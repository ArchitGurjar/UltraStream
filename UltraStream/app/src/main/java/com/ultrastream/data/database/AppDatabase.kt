package com.ultrastream.data.database

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import com.ultrastream.data.models.*

@Database(
    entities = [
        Addon::class,
        MetaItem::class,
        SmartPlaylist::class,
        Profile::class,
        WatchHistory::class,
        WatchProgress::class,
        WatchedEpisode::class
    ],
    version = 1,
    exportSchema = false
)
@TypeConverters(Converters::class)
abstract class AppDatabase : RoomDatabase() {
    abstract fun addonDao(): AddonDao
    abstract fun metaDao(): MetaDao
    abstract fun playlistDao(): SmartPlaylistDao
    abstract fun profileDao(): ProfileDao
    abstract fun watchHistoryDao(): WatchHistoryDao
    abstract fun watchProgressDao(): WatchProgressDao
    abstract fun watchedEpisodeDao(): WatchedEpisodeDao
}
