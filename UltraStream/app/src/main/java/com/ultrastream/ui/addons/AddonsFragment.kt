// app/src/main/java/com/ultrastream/ui/addons/AddonsFragment.kt
package com.ultrastream.ui.addons

import android.content.Context
import android.net.Uri
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import com.google.gson.Gson
import com.ultrastream.UltraStreamApplication
import com.ultrastream.data.models.Addon
import com.ultrastream.databinding.FragmentAddonsBinding
import com.ultrastream.utils.NetworkUtils
import kotlinx.coroutines.launch

class AddonsFragment : Fragment() {

    private var _binding: FragmentAddonsBinding? = null
    private val binding get() = _binding!!
    private val gson = Gson()

    private val importLauncher = registerForActivityResult(ActivityResultContracts.GetContent()) { uri: Uri? ->
        uri?.let { parseAndSaveAddons(it) }
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentAddonsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        loadAddons()
        setupListeners()
    }

    private fun setupListeners() {
        binding.installAddonBtn.setOnClickListener {
            val url = binding.addonUrlInput.text.toString().trim()
            if (url.isNotEmpty()) installAddon(url)
        }

        binding.importAddonsBtn.setOnClickListener {
            importLauncher.launch("*/*")
        }

        binding.exportAddonsBtn.setOnClickListener {
            exportAddons()
        }

        binding.factoryResetBtn.setOnClickListener {
            lifecycleScope.launch {
                UltraStreamApplication.instance.repository.deleteAddon("all")
                loadAddons()
                Toast.makeText(requireContext(), "All addons cleared", Toast.LENGTH_SHORT).show()
            }
        }

        binding.saveDebridBtn.setOnClickListener {
            val key = binding.debridKeyInput.text.toString().trim()
            UltraStreamApplication.instance.repository.setDebridKey(key)
            binding.debridStatus.text = if (key.isNotEmpty()) "✅ Debrid key saved" else "No Debrid key set"
        }
    }

    private fun loadAddons() {
        lifecycleScope.launch {
            val addons = UltraStreamApplication.instance.repository.getAddons().first()
            binding.installedAddonsContainer.removeAllViews()
            for (addon in addons) {
                val card = layoutInflater.inflate(R.layout.installed_addon_card, binding.installedAddonsContainer, false)
                // Assume we have a custom layout; for simplicity, just add a TextView
                val tv = android.widget.TextView(requireContext())
                tv.text = "${addon.name} (${if (addon.enabled) "Enabled" else "Disabled"})"
                tv.setPadding(0, 16, 0, 16)
                tv.setTextColor(requireContext().getColor(android.R.color.white))
                binding.installedAddonsContainer.addView(tv)
            }
        }
    }

    private fun installAddon(url: String) {
        lifecycleScope.launch {
            val manifest = NetworkUtils.fetchAddonManifest(url)
            if (manifest != null) {
                val addon = Addon(
                    id = manifest.id,
                    url = url,
                    name = manifest.name,
                    catalogs = manifest.catalogs.map { 
                        com.ultrastream.data.models.Catalog(it.type, it.id, it.name) 
                    }
                )
                UltraStreamApplication.instance.repository.insertAddon(addon)
                Toast.makeText(requireContext(), "Addon installed: ${manifest.name}", Toast.LENGTH_SHORT).show()
                loadAddons()
            } else {
                Toast.makeText(requireContext(), "Failed to fetch manifest", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun parseAndSaveAddons(uri: Uri) {
        try {
            val inputStream = requireContext().contentResolver.openInputStream(uri)
            val jsonString = inputStream?.bufferedReader().use { it?.readText() }
            val type = object : com.google.gson.reflect.TypeToken<List<Addon>>() {}.type
            val addons: List<Addon> = gson.fromJson(jsonString, type)
            lifecycleScope.launch {
                UltraStreamApplication.instance.repository.insertAddons(addons)
                loadAddons()
                Toast.makeText(requireContext(), "Addons imported", Toast.LENGTH_SHORT).show()
            }
        } catch (e: Exception) {
            Toast.makeText(requireContext(), "Failed to import: ${e.message}", Toast.LENGTH_SHORT).show()
        }
    }

    private fun exportAddons() {
        lifecycleScope.launch {
            val addons = UltraStreamApplication.instance.repository.getAddons().first()
            val json = gson.toJson(addons)
            val intent = android.content.Intent(android.content.Intent.ACTION_SEND).apply {
                type = "application/json"
                putExtra(android.content.Intent.EXTRA_TEXT, json)
            }
            startActivity(android.content.Intent.createChooser(intent, "Export Addons"))
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
