// app/src/main/java/com/ultrastream/data/database/dao/WatchedEpisodeDao.kt
package com.ultrastream.data.database

import androidx.room.*
import com.ultrastream.data.models.WatchedEpisode
import kotlinx.coroutines.flow.Flow

@Dao
interface WatchedEpisodeDao {
    @Query("SELECT * FROM watched_episodes")
    fun getAll(): Flow<List<WatchedEpisode>>

    @Query("SELECT * FROM watched_episodes WHERE episodeKey = :key")
    suspend fun getByKey(key: String): WatchedEpisode?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(episode: WatchedEpisode)

    @Query("DELETE FROM watched_episodes WHERE episodeKey = :key")
    suspend fun deleteByKey(key: String)

    @Query("DELETE FROM watched_episodes")
    suspend fun clearAll()
}
