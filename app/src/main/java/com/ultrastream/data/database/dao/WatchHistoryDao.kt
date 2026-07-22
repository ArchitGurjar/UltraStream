// app/src/main/java/com/ultrastream/data/database/dao/WatchHistoryDao.kt
package com.ultrastream.data.database

import androidx.room.*
import com.ultrastream.data.models.WatchHistory
import kotlinx.coroutines.flow.Flow

@Dao
interface WatchHistoryDao {
    @Query("SELECT * FROM watch_history ORDER BY timestamp DESC")
    fun getAll(): Flow<List<WatchHistory>>

    @Query("SELECT * FROM watch_history WHERE id = :id")
    suspend fun getById(id: String): WatchHistory?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(history: WatchHistory)

    @Query("DELETE FROM watch_history WHERE id = :id")
    suspend fun deleteById(id: String)

    @Query("DELETE FROM watch_history")
    suspend fun clearAll()

    @Query("SELECT COUNT(*) FROM watch_history")
    suspend fun getCount(): Int
}
