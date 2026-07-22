// app/src/main/java/com/ultrastream/UltraStreamApplication.kt
package com.ultrastream

import android.app.Application
import androidx.room.Room
import com.ultrastream.data.database.AppDatabase
import com.ultrastream.data.repository.AppRepository
import com.ultrastream.utils.PreferencesManager

class UltraStreamApplication : Application() {

    lateinit var database: AppDatabase
    lateinit var repository: AppRepository
    lateinit var prefs: PreferencesManager

    override fun onCreate() {
        super.onCreate()
        instance = this

        // Initialize Room
        database = Room.databaseBuilder(
            applicationContext,
            AppDatabase::class.java,
            "ultrastream.db"
        ).fallbackToDestructiveMigration().build()

        // Initialize Preferences
        prefs = PreferencesManager(this)

        // Initialize Repository
        repository = AppRepository(database, prefs)
    }

    companion object {
        lateinit var instance: UltraStreamApplication
            private set
    }
}
