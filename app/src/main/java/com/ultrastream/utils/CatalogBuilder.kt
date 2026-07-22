package com.ultrastream.utils

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.LinearLayout
import android.widget.TextView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.ultrastream.R
import com.ultrastream.UltraStreamApplication
import com.ultrastream.data.models.MetaItem
import com.ultrastream.ui.adapters.PosterAdapter
import kotlinx.coroutines.*

class CatalogBuilder {

    private val coroutineScope = CoroutineScope(Dispatchers.Main + Job())

    fun buildCatalogs(
        context: Context,
        container: LinearLayout,
        onItemClick: (MetaItem) -> Unit
    ) {
        container.removeAllViews()

        coroutineScope.launch {
            val addons = (context.applicationContext as UltraStreamApplication).repository.getEnabledAddons()
            addons.forEach { addon ->
                addon.catalogs.forEach { catalog ->
                    val sectionView = createCatalogSection(
                        context,
                        addon.name,
                        addon.url,
                        catalog,
                        onItemClick
                    )
                    container.addView(sectionView)
                }
            }
        }
    }

    private fun createCatalogSection(
        context: Context,
        addonName: String,
        addonUrl: String,
        catalog: com.ultrastream.data.models.Catalog,
        onItemClick: (MetaItem) -> Unit
    ): View {
        val inflater = LayoutInflater.from(context)
        val rootView = inflater.inflate(R.layout.layout_catalog_row, null)

        val tvTitle = rootView.findViewById<TextView>(R.id.tv_section_title)
        tvTitle.text = "${catalog.name} · $addonName"

        val recyclerView = rootView.findViewById<RecyclerView>(R.id.rv_catalog)
        val layoutManager = LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false)
        recyclerView.layoutManager = layoutManager

        val adapter = PosterAdapter(onItemClick)
        recyclerView.adapter = adapter

        coroutineScope.launch {
            val items = NetworkUtils.fetchCatalog(
                addonUrl,
                catalog.type,
                catalog.id
            )
            adapter.submitList(items)
        }

        return rootView
    }
}
