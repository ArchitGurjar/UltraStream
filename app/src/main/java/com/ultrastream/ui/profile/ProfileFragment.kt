// app/src/main/java/com/ultrastream/ui/profile/ProfileFragment.kt
package com.ultrastream.ui.profile

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import com.ultrastream.databinding.FragmentProfileBinding
import kotlinx.coroutines.launch

class ProfileFragment : Fragment() {

    private var _binding: FragmentProfileBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentProfileBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        loadProfile()
        setupThemeSwitch()
        setupHindiSwitch()
        setupAutoplaySwitch()
        setupParentalSwitch()
        setupExportImport()
        setupFactoryReset()
    }

    private fun loadProfile() {
        // Load current profile from preferences
        // Update avatar, name, watchlist count
    }

    private fun setupThemeSwitch() {
        binding.switchTheme.setOnCheckedChangeListener { _, isChecked ->
            // Save theme preference and apply
        }
    }

    private fun setupHindiSwitch() {
        binding.switchHindi.setOnCheckedChangeListener { _, isChecked ->
            // Save hindi priority
        }
    }

    private fun setupAutoplaySwitch() {
        binding.switchAutoplay.setOnCheckedChangeListener { _, isChecked ->
            // Save autoplay
        }
    }

    private fun setupParentalSwitch() {
        binding.switchParental.setOnCheckedChangeListener { _, isChecked ->
            // Save parental control
        }
    }

    private fun setupExportImport() {
        binding.exportDataBtn.setOnClickListener {
            // Export all data
        }
        binding.importDataBtn.setOnClickListener {
            // Import data from JSON
        }
    }

    private fun setupFactoryReset() {
        binding.factoryResetBtn.setOnClickListener {
            // Show confirmation and clear all data
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
