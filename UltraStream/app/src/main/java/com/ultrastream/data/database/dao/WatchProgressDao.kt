package com.ultrastream.data.database

import androidx.room.*
import com.ultrastream.data.models.WatchProgress
import kotlinx.coroutines.flow.Flow

@Dao
interface WatchProgressDao {
    @Query("SELECT * FROM watch_progress")
    fun getAll(): Flow<List<WatchProgress>>

    @Query("SELECT * FROM watch_progress WHERE id = :id")
    suspend fun getById(id: String): WatchProgress?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(progress: WatchProgress)

    @Update
    suspend fun update(progress: WatchProgress)

    @Query("DELETE FROM watch_progress WHERE id = :id")
    suspend fun deleteById(id: String)

    @Query("DELETE FROM watch_progress")
    suspend fun clearAll()
}
