// app/src/main/java/com/ultrastream/data/database/dao/AddonDao.kt
package com.ultrastream.data.database

import androidx.room.*
import com.ultrastream.data.models.Addon
import kotlinx.coroutines.flow.Flow

@Dao
interface AddonDao {
    @Query("SELECT * FROM addons")
    fun getAll(): Flow<List<Addon>>

    @Query("SELECT * FROM addons WHERE enabled = 1")
    fun getEnabled(): Flow<List<Addon>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(addon: Addon)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(addons: List<Addon>)

    @Update
    suspend fun update(addon: Addon)

    @Delete
    suspend fun delete(addon: Addon)

    @Query("DELETE FROM addons WHERE id = :id AND required = 0")
    suspend fun deleteById(id: String)

    @Query("SELECT * FROM addons WHERE id = :id")
    suspend fun getById(id: String): Addon?
}
