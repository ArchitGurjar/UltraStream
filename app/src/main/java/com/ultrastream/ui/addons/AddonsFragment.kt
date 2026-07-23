package com.ultrastream.ui.addons

import android.content.Context
import android.net.Uri
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.fragment.app.Fragment
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.ultrastream.data.models.Addon
import com.ultrastream.databinding.FragmentAddonsBinding

class AddonsFragment : Fragment() {

    private var _binding: FragmentAddonsBinding? = null
    private val binding get() = _binding!!
    private val gson = Gson()

    private val importLauncher = registerForActivityResult(ActivityResultContracts.GetContent()) { uri: Uri? ->
        uri?.let { parseAndSaveAddons(it) }
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?
    ): View {
        _binding = FragmentAddonsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        // स्क्रीन खुलते ही सेव किए हुए ऐडऑन्स को लोड करें
        loadInstalledAddons()

        binding.importAddonsBtn.setOnClickListener {
            importLauncher.launch("*/*")
        }

        binding.installAddonBtn.setOnClickListener {
            val url = binding.addonUrlInput.text.toString()
            if (url.isNotEmpty()) {
                Toast.makeText(requireContext(), "Installing Addon...", Toast.LENGTH_SHORT).show()
                binding.addonUrlInput.text?.clear()
            }
        }

        binding.factoryResetBtn.setOnClickListener {
            val prefs = requireContext().getSharedPreferences("addons_prefs", Context.MODE_PRIVATE)
            prefs.edit().clear().apply()
            binding.installedAddonsContainer.removeAllViews()
            Toast.makeText(requireContext(), "All addons cleared permanently!", Toast.LENGTH_SHORT).show()
        }
    }

    private fun parseAndSaveAddons(uri: Uri) {
        try {
            val inputStream = requireContext().contentResolver.openInputStream(uri)
            val jsonString = inputStream?.bufferedReader().use { it?.readText() }

            // डेटा को फोन में हमेशा के लिए सेव करें
            val prefs = requireContext().getSharedPreferences("addons_prefs", Context.MODE_PRIVATE)
            prefs.edit().putString("addons_json", jsonString).apply()

            loadInstalledAddons()
            Toast.makeText(requireContext(), "Successfully imported & saved Addons!", Toast.LENGTH_LONG).show()

        } catch (e: Exception) {
            e.printStackTrace()
            Toast.makeText(requireContext(), "Failed to import JSON!", Toast.LENGTH_SHORT).show()
        }
    }

    private fun loadInstalledAddons() {
        try {
            val prefs = requireContext().getSharedPreferences("addons_prefs", Context.MODE_PRIVATE)
            val jsonString = prefs.getString("addons_json", null)

            if (jsonString != null) {
                val type = object : TypeToken<List<Addon>>() {}.type
                val addonsList: List<Addon> = gson.fromJson(jsonString, type)

                binding.installedAddonsContainer.removeAllViews()
                addonsList.forEach { addon ->
                    val tv = TextView(requireContext()).apply {
                        text = "✅ ${addon.name}\n${addon.url}"
                        textSize = 14f
                        setPadding(0, 16, 0, 24)
                        setTextColor(requireContext().getColor(android.R.color.white))
                    }
                    binding.installedAddonsContainer.addView(tv)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
