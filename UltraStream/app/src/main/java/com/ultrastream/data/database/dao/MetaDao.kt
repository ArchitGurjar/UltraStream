package com.ultrastream.data.database

import androidx.room.*
import com.ultrastream.data.models.MetaItem

@Dao
interface MetaDao {
    @Query("SELECT * FROM meta_cache WHERE id = :id")
    suspend fun getById(id: String): MetaItem?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(meta: MetaItem)

    @Query("DELETE FROM meta_cache WHERE cachedAt < :cutoff")
    suspend fun deleteOld(cutoff: Long)
}
