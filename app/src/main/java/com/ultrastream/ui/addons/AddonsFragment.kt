package com.ultrastream.ui.addons

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

    // File Picker Launcher for JSON Import
    private val importLauncher = registerForActivityResult(ActivityResultContracts.GetContent()) { uri: Uri? ->
        uri?.let { parseAndLoadAddons(it) }
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?
    ): View {
        _binding = FragmentAddonsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        binding.importAddonsBtn.setOnClickListener {
            importLauncher.launch("*/*") // JSON फाइल सेलेक्ट करने के लिए
        }

        binding.installAddonBtn.setOnClickListener {
            val url = binding.addonUrlInput.text.toString()
            if (url.isNotEmpty()) {
                Toast.makeText(requireContext(), "Installing Addon...", Toast.LENGTH_SHORT).show()
                addAddonToView("Custom Addon", url)
                binding.addonUrlInput.text?.clear()
            }
        }

        binding.factoryResetBtn.setOnClickListener {
            binding.installedAddonsContainer.removeAllViews()
            Toast.makeText(requireContext(), "All addons cleared!", Toast.LENGTH_SHORT).show()
        }
    }

    private fun parseAndLoadAddons(uri: Uri) {
        try {
            val inputStream = requireContext().contentResolver.openInputStream(uri)
            val jsonString = inputStream?.bufferedReader().use { it?.readText() }
            
            // Gson से JSON को List<Addon> में बदलें
            val type = object : TypeToken<List<Addon>>() {}.type
            val addonsList: List<Addon> = gson.fromJson(jsonString, type)

            binding.installedAddonsContainer.removeAllViews()
            addonsList.forEach { addon ->
                addAddonToView(addon.name, addon.url)
            }
            
            Toast.makeText(requireContext(), "Successfully imported ${addonsList.size} Addons!", Toast.LENGTH_LONG).show()

        } catch (e: Exception) {
            e.printStackTrace()
            Toast.makeText(requireContext(), "Failed to import JSON!", Toast.LENGTH_SHORT).show()
        }
    }

    private fun addAddonToView(name: String, url: String) {
        val tv = TextView(requireContext()).apply {
            text = "✅ $name\n$url"
            textSize = 14f
            setPadding(0, 16, 0, 24)
            setTextColor(requireContext().getColor(android.R.color.white))
        }
        binding.installedAddonsContainer.addView(tv)
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
