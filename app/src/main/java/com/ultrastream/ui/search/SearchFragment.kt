package com.ultrastream.ui.search

import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.GridLayoutManager
import com.ultrastream.UltraStreamApplication
import com.ultrastream.data.models.MetaItem
import com.ultrastream.databinding.FragmentSearchBinding
import com.ultrastream.ui.adapters.PosterAdapter
import com.ultrastream.utils.NetworkUtils
import kotlinx.coroutines.*

class SearchFragment : Fragment() {

    private var _binding: FragmentSearchBinding? = null
    private val binding get() = _binding!!
    private var searchJob: Job? = null
    private lateinit var adapter: PosterAdapter

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentSearchBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        adapter = PosterAdapter { meta ->
            val intent = android.content.Intent(requireContext(), com.ultrastream.ui.details.DetailsActivity::class.java)
            intent.putExtra(com.ultrastream.ui.details.DetailsActivity.EXTRA_META_ID, meta.id)
            intent.putExtra(com.ultrastream.ui.details.DetailsActivity.EXTRA_META_TYPE, meta.type)
            startActivity(intent)
        }
        binding.rvSearchResults.layoutManager = GridLayoutManager(requireContext(), 2)
        binding.rvSearchResults.adapter = adapter

        setupSearchInput()
        setupChips()
    }

    private fun setupSearchInput() {
        binding.searchInput.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
            override fun afterTextChanged(s: Editable?) {
                val query = s?.toString()?.trim() ?: ""
                searchJob?.cancel()
                if (query.length >= 2) {
                    searchJob = viewLifecycleOwner.lifecycleScope.launch {
                        delay(600)
                        performSearch(query)
                    }
                } else {
                    adapter.submitList(emptyList())
                }
            }
        })
    }

    private fun setupChips() {
        val chips = binding.filterChipGroup
        chips.setOnCheckedChangeListener { _, _ ->
            val query = binding.searchInput.text.toString().trim()
            if (query.isNotEmpty()) {
                searchJob?.cancel()
                searchJob = viewLifecycleOwner.lifecycleScope.launch {
                    performSearch(query)
                }
            }
        }
        val sortChips = binding.sortChipGroup
        sortChips.setOnCheckedChangeListener { _, _ ->
            val query = binding.searchInput.text.toString().trim()
            if (query.isNotEmpty()) {
                searchJob?.cancel()
                searchJob = viewLifecycleOwner.lifecycleScope.launch {
                    performSearch(query)
                }
            }
        }
    }

    private suspend fun performSearch(query: String) {
        val filter = when (binding.filterChipGroup.checkedChipId) {
            com.ultrastream.R.id.chip_movie -> "movie"
            com.ultrastream.R.id.chip_series -> "series"
            com.ultrastream.R.id.chip_anime -> "anime"
            com.ultrastream.R.id.chip_tv -> "tv"
            else -> "all"
        }
        val sort = when (binding.sortChipGroup.checkedChipId) {
            com.ultrastream.R.id.sort_rating -> "rating"
            com.ultrastream.R.id.sort_year -> "year"
            else -> "popular"
        }

        val addons = UltraStreamApplication.instance.repository.getEnabledAddons()
        if (addons.isEmpty()) {
            withContext(Dispatchers.Main) {
                Toast.makeText(requireContext(), "No addons enabled", Toast.LENGTH_SHORT).show()
            }
            return
        }

        val allResults = mutableListOf<MetaItem>()
        val deferredSearches = mutableListOf<Deferred<Unit>>()

        withContext(Dispatchers.IO) {
            for (addon in addons) {
                for (catalog in addon.catalogs) {
                    if (filter != "all" && catalog.type != filter) continue
                    val baseUrl = addon.url.replace("/manifest.json", "")
                    val searchUrl = "$baseUrl/catalog/${catalog.type}/${catalog.id}/search=${query}.json"
                    val deferred = async<Unit> {
                        try {
                            val items = NetworkUtils.fetchCatalog(addon.url, catalog.type, catalog.id + "/search=" + query)
                            allResults.addAll(items)
                        } catch (_: Exception) {
                        }
                    }
                    deferredSearches.add(deferred)
                }
            }
            deferredSearches.awaitAll()
        }

        val unique = allResults.distinctBy { it.id }
        val sorted = when (sort) {
            "rating" -> unique.sortedByDescending { it.imdbRating ?: 0f }
            "year" -> unique.sortedByDescending { it.year ?: 0 }
            else -> unique
        }
        withContext(Dispatchers.Main) {
            adapter.submitList(sorted)
            if (sorted.isEmpty()) {
                Toast.makeText(requireContext(), "No results found", Toast.LENGTH_SHORT).show()
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        searchJob?.cancel()
        _binding = null
    }
}
