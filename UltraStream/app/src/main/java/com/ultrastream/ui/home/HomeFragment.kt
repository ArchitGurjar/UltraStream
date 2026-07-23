// app/src/main/java/com/ultrastream/ui/home/HomeFragment.kt
package com.ultrastream.ui.home

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.GridLayoutManager
import com.ultrastream.R
import com.ultrastream.UltraStreamApplication
import com.ultrastream.databinding.FragmentHomeBinding
import com.ultrastream.ui.adapters.PosterAdapter
import com.ultrastream.utils.NetworkUtils
import kotlinx.coroutines.launch

class HomeFragment : Fragment() {

    private var _binding: FragmentHomeBinding? = null
    private val binding get() = _binding!!
    private lateinit var adapter: PosterAdapter

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentHomeBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        adapter = PosterAdapter { meta ->
            // Open details
            val intent = android.content.Intent(requireContext(), com.ultrastream.ui.details.DetailsActivity::class.java)
            intent.putExtra(com.ultrastream.ui.details.DetailsActivity.EXTRA_META_ID, meta.id)
            intent.putExtra(com.ultrastream.ui.details.DetailsActivity.EXTRA_META_TYPE, meta.type)
            startActivity(intent)
        }
        binding.rvHome.layoutManager = GridLayoutManager(requireContext(), 3)
        binding.rvHome.adapter = adapter

        loadCatalogs()
    }

    private fun loadCatalogs() {
        lifecycleScope.launch {
            val addons = UltraStreamApplication.instance.repository.getEnabledAddons()
            if (addons.isEmpty()) {
                Toast.makeText(requireContext(), "No addons installed. Go to Addons tab.", Toast.LENGTH_LONG).show()
                return@launch
            }
            val allItems = mutableListOf<com.ultrastream.data.models.MetaItem>()
            for (addon in addons) {
                for (catalog in addon.catalogs) {
                    val items = NetworkUtils.fetchCatalog(addon.url, catalog.type, catalog.id)
                    allItems.addAll(items)
                }
            }
            // Remove duplicates by id
            val unique = allItems.distinctBy { it.id }
            adapter.submitList(unique)
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
