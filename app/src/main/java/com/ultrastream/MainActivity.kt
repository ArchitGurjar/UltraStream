package com.ultrastream

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import androidx.navigation.NavController
import androidx.navigation.fragment.NavHostFragment
import androidx.navigation.ui.setupWithNavController
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.ultrastream.databinding.ActivityMainBinding
import com.ultrastream.data.models.Addon
import com.ultrastream.data.models.Catalog
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private lateinit var navController: NavController

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        val navHostFragment = supportFragmentManager
            .findFragmentById(R.id.nav_host_fragment) as NavHostFragment
        navController = navHostFragment.navController

        val bottomNav = findViewById<BottomNavigationView>(R.id.bottom_nav)
        bottomNav.setupWithNavController(navController)

        // CRITICAL FIX: Inject Default Addons (Cinemeta & Torrentio) if DB is empty
        lifecycleScope.launch {
            val repo = UltraStreamApplication.instance.repository
            val currentAddons = repo.getAddons().first()
            if (currentAddons.isEmpty()) {
                val defaultAddon = Addon(
                    id = "com.stremio.cinemeta",
                    url = "https://v3-cinemeta.strem.io/manifest.json",
                    name = "Cinemeta",
                    enabled = true,
                    required = true,
                    catalogs = listOf(
                        Catalog("movie", "top", "Top Movies"),
                        Catalog("series", "top", "Top Series")
                    )
                )
                val torrentio = Addon(
                    id = "torrentio",
                    url = "https://torrentio.strem.fun/manifest.json",
                    name = "Torrentio",
                    enabled = true,
                    required = false
                )
                repo.insertAddons(listOf(defaultAddon, torrentio))
            }
        }
    }

    override fun onBackPressed() {
        if (!navController.popBackStack()) {
            super.onBackPressed()
        }
    }
}
