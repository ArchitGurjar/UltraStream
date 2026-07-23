package com.ultrastream.ui.home

import android.content.Context
import android.os.Bundle
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
import com.ultrastream.databinding.FragmentHomeBinding
import com.ultrastream.ui.adapters.SimpleMovieAdapter
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.net.URL

// Stremio के JSON रेस्पोंस को रीड करने के लिए Data Classes
data class MetaResponse(val metas: List<MetaItem>?)
data class MetaItem(val id: String, val name: String, val poster: String?, val type: String)

class HomeFragment : Fragment() {

    private var _binding: FragmentHomeBinding? = null
    private val binding get() = _binding!!
    private val gson = Gson()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        _binding = FragmentHomeBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        
        // 3 कॉलम वाला ग्रिड (Netflix स्टाइल)
        binding.rvHome.layoutManager = GridLayoutManager(requireContext(), 3)
        loadMoviesFromAddons()
    }

    private fun loadMoviesFromAddons() {
        val prefs = requireContext().getSharedPreferences("addons_prefs", Context.MODE_PRIVATE)
        val jsonString = prefs.getString("addons_json", null)

        if (jsonString.isNullOrEmpty()) {
            Toast.makeText(requireContext(), "No Addons Installed. Go to Addons Tab.", Toast.LENGTH_LONG).show()
            return
        }

        val type = object : TypeToken<List<Addon>>() {}.type
        val addonsList: List<Addon> = try { gson.fromJson(jsonString, type) } catch (e: Exception) { emptyList() }

        // ऐसा पहला ऐडऑन ढूंढें जिसके पास catalogs (मूवी लिस्ट) हों
        val validAddon = addonsList.firstOrNull { it.catalogs.isNotEmpty() }
        
        if (validAddon == null) {
            Toast.makeText(requireContext(), "Installed addons don't have catalogs.", Toast.LENGTH_SHORT).show()
            return
        }

        // Stremio कैटलॉग का URL बनाना
        val firstCatalog = validAddon.catalogs.first()
        val baseUrl = validAddon.url.replace("manifest.json", "")
        val fetchUrl = "${baseUrl}catalog/${firstCatalog.type}/${firstCatalog.id}.json"

        Toast.makeText(requireContext(), "Loading movies from: ${validAddon.name}...", Toast.LENGTH_SHORT).show()

        // बैकग्राउंड थ्रेड में इंटरनेट से डेटा मंगाना
        viewLifecycleOwner.lifecycleScope.launch(Dispatchers.IO) {
            try {
                val responseJson = URL(fetchUrl).readText()
                val metaResponse = gson.fromJson(responseJson, MetaResponse::class.java)

                // मेन थ्रेड पर UI अपडेट करना
                withContext(Dispatchers.Main) {
                    if (metaResponse.metas != null) {
                        binding.rvHome.adapter = SimpleMovieAdapter(metaResponse.metas)
                    } else {
                        Toast.makeText(requireContext(), "No movies found in this addon.", Toast.LENGTH_SHORT).show()
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
                withContext(Dispatchers.Main) {
                    Toast.makeText(requireContext(), "Network Error! Failed to fetch movies.", Toast.LENGTH_SHORT).show()
                }
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
