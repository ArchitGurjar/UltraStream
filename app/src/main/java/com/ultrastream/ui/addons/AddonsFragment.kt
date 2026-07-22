// app/src/main/java/com/ultrastream/ui/addons/AddonsFragment.kt
package com.ultrastream.ui.addons

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import com.ultrastream.databinding.FragmentAddonsBinding
import kotlinx.coroutines.launch

class AddonsFragment : Fragment() {

    private var _binding: FragmentAddonsBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentAddonsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        setupDebrid()
        setupInstallAddon()
        loadInstalledAddons()
        loadRecommendedAddons()
        setupExportImport()
        setupFactoryReset()
    }

    private fun setupDebrid() {
        binding.saveDebridBtn.setOnClickListener {
            val key = binding.debridKeyInput.text.toString()
            // Save to repository
            // Update status
        }
    }

    private fun setupInstallAddon() {
        binding.installAddonBtn.setOnClickListener {
            val url = binding.addonUrlInput.text.toString()
            // Install addon via repository
        }
    }

    private fun loadInstalledAddons() {
        viewLifecycleOwner.lifecycleScope.launch {
            // Fetch addons and populate binding.installedAddonsContainer
        }
    }

    private fun loadRecommendedAddons() {
        // Populate binding.recommendedAddonsContainer
    }

    private fun setupExportImport() {
        binding.exportAddonsBtn.setOnClickListener {
            // Export addons to JSON
        }
        binding.importAddonsBtn.setOnClickListener {
            // Launch file picker
        }
    }

    private fun setupFactoryReset() {
        binding.factoryResetBtn.setOnClickListener {
            // Clear addons data
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
