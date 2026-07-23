// app/src/main/java/com/ultrastream/data/database/dao/SmartPlaylistDao.kt
package com.ultrastream.data.database

import androidx.room.*
import com.ultrastream.data.models.SmartPlaylist
import kotlinx.coroutines.flow.Flow

@Dao
interface SmartPlaylistDao {
    @Query("SELECT * FROM smart_playlists")
    fun getAll(): Flow<List<SmartPlaylist>>

    @Query("SELECT * FROM smart_playlists WHERE id = :id")
    suspend fun getById(id: String): SmartPlaylist?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(playlist: SmartPlaylist)

    @Update
    suspend fun update(playlist: SmartPlaylist)

    @Delete
    suspend fun delete(playlist: SmartPlaylist)

    @Query("DELETE FROM smart_playlists WHERE id = :id")
    suspend fun deleteById(id: String)
}
