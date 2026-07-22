package com.ultrastream.ui.home

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import com.ultrastream.databinding.FragmentHomeBinding
import com.ultrastream.ui.adapters.ContinueWatchingAdapter
import com.ultrastream.utils.CatalogBuilder
import kotlinx.coroutines.launch

class HomeFragment : Fragment() {

    private var _binding: FragmentHomeBinding? = null
    private val binding get() = _binding!!

    private lateinit var continueWatchingAdapter: ContinueWatchingAdapter
    private val catalogBuilder = CatalogBuilder()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentHomeBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        continueWatchingAdapter = ContinueWatchingAdapter { /* navigate */ }
        binding.rvContinueWatching.apply {
            layoutManager = LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false)
            adapter = continueWatchingAdapter
        }

        loadContinueWatching()
        loadCatalogs()
    }

    private fun loadContinueWatching() {
        viewLifecycleOwner.lifecycleScope.launch {
            // Fetch history from repository and submit
        }
    }

    private fun loadCatalogs() {
        viewLifecycleOwner.lifecycleScope.launch {
            catalogBuilder.buildCatalogs(
                context = requireContext(),
                container = binding.catalogsContainer,
                onItemClick = { /* navigate */ }
            )
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
