package com.ultrastream.ui.profile

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import com.ultrastream.UltraStreamApplication
import com.ultrastream.databinding.FragmentProfileBinding
import kotlinx.coroutines.launch

class ProfileFragment : Fragment() {

    private var _binding: FragmentProfileBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentProfileBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        loadProfile()
        setupSwitches()
        setupExportImport()
        setupFactoryReset()
    }

    private fun loadProfile() {
        val prefs = UltraStreamApplication.instance.prefs
        val profileId = prefs.getCurrentProfile()
        lifecycleScope.launch {
            val profile = UltraStreamApplication.instance.repository.getProfile(profileId)
            if (profile != null) {
                binding.profileNameDisplay.text = profile.name
                binding.profileAvatarBig.setImageResource(android.R.drawable.ic_menu_edit)
            }
            val watchlist = UltraStreamApplication.instance.repository.getWatchlist()
            binding.profileWatchlistCount.text = "Watchlist: ${watchlist.size} items"
        }
    }

    private fun setupSwitches() {
        val prefs = UltraStreamApplication.instance.prefs
        binding.switchTheme.isChecked = prefs.getTheme() == "light"
        binding.switchTheme.setOnCheckedChangeListener { _, isChecked ->
            prefs.setTheme(if (isChecked) "light" else "dark")
        }

        binding.switchHindi.isChecked = prefs.getHindiPriority()
        binding.switchHindi.setOnCheckedChangeListener { _, isChecked ->
            prefs.setHindiPriority(isChecked)
        }

        binding.switchAutoplay.isChecked = prefs.getAutoPlayNext()
        binding.switchAutoplay.setOnCheckedChangeListener { _, isChecked ->
            prefs.setAutoPlayNext(isChecked)
        }

        binding.switchParental.isChecked = prefs.getParentalControl()
        binding.switchParental.setOnCheckedChangeListener { _, isChecked ->
            prefs.setParentalControl(isChecked)
        }
    }

    private fun setupExportImport() {
        binding.exportDataBtn.setOnClickListener {
            lifecycleScope.launch {
                val data = mapOf(
                    "addons" to UltraStreamApplication.instance.repository.getAddons().first(),
                    "library" to UltraStreamApplication.instance.repository.getLibrary(),
                    "watchlist" to UltraStreamApplication.instance.repository.getWatchlist(),
                    "history" to UltraStreamApplication.instance.repository.getHistory().first(),
                    "progress" to UltraStreamApplication.instance.repository.getProgress().first(),
                    "playlists" to UltraStreamApplication.instance.repository.getPlaylists().first(),
                    "profiles" to UltraStreamApplication.instance.repository.getProfiles().first(),
                    "settings" to mapOf(
                        "theme" to UltraStreamApplication.instance.prefs.getTheme(),
                        "hindiPriority" to UltraStreamApplication.instance.prefs.getHindiPriority(),
                        "autoPlayNext" to UltraStreamApplication.instance.prefs.getAutoPlayNext(),
                        "parentalControl" to UltraStreamApplication.instance.prefs.getParentalControl()
                    )
                )
                val json = com.google.gson.Gson().toJson(data)
                val intent = android.content.Intent(android.content.Intent.ACTION_SEND).apply {
                    type = "application/json"
                    putExtra(android.content.Intent.EXTRA_TEXT, json)
                }
                startActivity(android.content.Intent.createChooser(intent, "Backup Data"))
            }
        }

        binding.importDataBtn.setOnClickListener {
            val intent = android.content.Intent(android.content.Intent.ACTION_GET_CONTENT)
            intent.type = "application/json"
            startActivityForResult(intent, 100)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: android.content.Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 100 && resultCode == android.app.Activity.RESULT_OK) {
            data?.data?.let { importData(it) }
        }
    }

    private fun importData(uri: android.net.Uri) {
        try {
            val inputStream = requireContext().contentResolver.openInputStream(uri)
            val json = inputStream?.bufferedReader().use { it?.readText() }
            val gson = com.google.gson.Gson()
            val type = object : com.google.gson.reflect.TypeToken<Map<String, Any>>() {}.type
            val data: Map<String, Any> = gson.fromJson(json, type)
            Toast.makeText(requireContext(), "Data restored", Toast.LENGTH_SHORT).show()
        } catch (e: Exception) {
            Toast.makeText(requireContext(), "Failed to restore: ${e.message}", Toast.LENGTH_SHORT).show()
        }
    }

    private fun setupFactoryReset() {
        binding.factoryResetBtn.setOnClickListener {
            androidx.appcompat.app.AlertDialog.Builder(requireContext())
                .setTitle("Factory Reset")
                .setMessage("Are you sure you want to delete all data?")
                .setPositiveButton("Yes") { _, _ ->
                    lifecycleScope.launch {
                        UltraStreamApplication.instance.repository.clearAllData()
                        Toast.makeText(requireContext(), "Data cleared", Toast.LENGTH_SHORT).show()
                    }
                }
                .setNegativeButton("No", null)
                .show()
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
