// app/src/main/java/com/ultrastream/ui/search/SearchFragment.kt
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
        // Filter chips
        val chips = binding.filterChipGroup
        chips.setOnCheckedChangeListener { _, _ ->
            val query = binding.searchInput.text.toString().trim()
            if (query.isNotEmpty()) performSearch(query)
        }
        // Sort chips
        val sortChips = binding.sortChipGroup
        sortChips.setOnCheckedChangeListener { _, _ ->
            val query = binding.searchInput.text.toString().trim()
            if (query.isNotEmpty()) performSearch(query)
        }
    }

    private suspend fun performSearch(query: String) {
        val filter = when (binding.filterChipGroup.checkedChipId) {
            R.id.chip_movie -> "movie"
            R.id.chip_series -> "series"
            R.id.chip_anime -> "anime"
            R.id.chip_tv -> "tv"
            else -> "all"
        }
        val sort = when (binding.sortChipGroup.checkedChipId) {
            R.id.sort_rating -> "rating"
            R.id.sort_year -> "year"
            else -> "popular"
        }

        val addons = UltraStreamApplication.instance.repository.getEnabledAddons()
        if (addons.isEmpty()) {
            withContext(Dispatchers.Main) {
                Toast.makeText(requireContext(), "No addons enabled", Toast.LENGTH_SHORT).show()
            }
            return
        }

        val allResults = mutableListOf<com.ultrastream.data.models.MetaItem>()
        val jobs = addons.map { addon ->
            async {
                for (catalog in addon.catalogs) {
                    if (filter != "all" && catalog.type != filter) continue
                    val url = addon.url.replace("/manifest.json", "")
                    val searchUrl = "$url/catalog/${catalog.type}/${catalog.id}/search=${query}.json"
                    try {
                        val items = NetworkUtils.fetchCatalog(addon.url, catalog.type, catalog.id + "/search=" + query)
                        allResults.addAll(items)
                    } catch (_: Exception) { }
                }
            }
        }
        jobs.awaitAll()

        val unique = allResults.distinctBy { it.id }
        // Sort if needed
        when (sort) {
            "rating" -> unique.sortedByDescending { it.imdbRating ?: 0f }
            "year" -> unique.sortedByDescending { it.year ?: 0 }
            else -> unique
        }
        withContext(Dispatchers.Main) {
            adapter.submitList(unique)
            if (unique.isEmpty()) {
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
