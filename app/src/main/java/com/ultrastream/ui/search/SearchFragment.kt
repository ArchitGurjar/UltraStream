package com.ultrastream.ui.search

import android.content.Context
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
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.ultrastream.data.models.Addon
import com.ultrastream.databinding.FragmentSearchBinding
import com.ultrastream.ui.adapters.PosterAdapter
import com.ultrastream.ui.home.MetaItem
import com.ultrastream.ui.home.MetaResponse
import kotlinx.coroutines.*
import java.net.URL

class SearchFragment : Fragment() {

    private var _binding: FragmentSearchBinding? = null
    private val binding get() = _binding!!
    private val gson = Gson()
    private var searchJob: Job? = null
    private lateinit var adapter: PosterAdapter

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        _binding = FragmentSearchBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        adapter = PosterAdapter { meta ->
            // यहाँ बाद में DetailsActivity ओपन करने का कोड आएगा
            Toast.makeText(requireContext(), "Selected: ${meta.name}", Toast.LENGTH_SHORT).show()
        }
        binding.rvSearchResults.layoutManager = GridLayoutManager(requireContext(), 2)
        binding.rvSearchResults.adapter = adapter

        setupSearchInput()
    }

    private fun setupSearchInput() {
        binding.searchInput.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
            override fun afterTextChanged(s: Editable?) {
                val query = s?.toString()?.trim() ?: ""
                searchJob?.cancel() // पुरानी सर्च कैंसल करें
                if (query.length >= 2) {
                    searchJob = viewLifecycleOwner.lifecycleScope.launch {
                        delay(600) // 600ms Debounce (टाइप करने के बाद रुकने का समय)
                        performSearch(query)
                    }
                } else {
                    adapter.submitList(emptyList())
                }
            }
        })
    }

    private suspend fun performSearch(query: String) {
        val prefs = requireContext().getSharedPreferences("addons_prefs", Context.MODE_PRIVATE)
        val jsonString = prefs.getString("addons_json", null) ?: return

        val type = object : TypeToken<List<Addon>>() {}.type
        val addonsList: List<Addon> = try { gson.fromJson(jsonString, type) } catch (e: Exception) { emptyList() }

        val allResults = mutableListOf<MetaItem>()
        val deferredSearches = mutableListOf<Deferred<Unit>>()

        withContext(Dispatchers.IO) {
            for (addon in addonsList) {
                if (!addon.enabled) continue
                val baseUrl = addon.url.replace("/manifest.json", "")
                
                addon.catalogs.forEach { cat ->
                    // सर्च URL बनाना
                    val searchUrl = "$baseUrl/catalog/${cat.type}/${cat.id}/search=${query}.json"
                    
                    val deferred = async {
                        try {
                            val responseJson = URL(searchUrl).readText()
                            val metaResponse = gson.fromJson(responseJson, MetaResponse::class.java)
                            metaResponse.metas?.forEach { 
                                allResults.add(it) 
                            }
                        } catch (e: Exception) {
                            // इग्नोर करें अगर कोई ऐडऑन फेल हो जाए
                        }
                    }
                    deferredSearches.add(deferred)
                }
            }
            deferredSearches.awaitAll()
        }

        // डुप्लीकेट हटाएं और UI अपडेट करें
        val uniqueResults = allResults.distinctBy { it.id }
        
        withContext(Dispatchers.Main) {
            if (uniqueResults.isEmpty()) {
                Toast.makeText(requireContext(), "No results found", Toast.LENGTH_SHORT).show()
            }
            adapter.submitList(uniqueResults)
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        searchJob?.cancel()
        _binding = null
    }
}
