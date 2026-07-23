package com.ultrastream.ui.home

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.ultrastream.UltraStreamApplication
import com.ultrastream.data.models.MetaItem
import com.ultrastream.utils.NetworkUtils
import kotlinx.coroutines.launch

class HomeViewModel : ViewModel() {

    private val _catalogs = MutableLiveData<List<MetaItem>>(emptyList())
    val catalogs: LiveData<List<MetaItem>> = _catalogs

    private val repository = UltraStreamApplication.instance.repository

    fun loadCatalogs() {
        viewModelScope.launch {
            val addons = repository.getEnabledAddons()
            if (addons.isEmpty()) {
                _catalogs.value = emptyList()
                return@launch
            }
            val allItems = mutableListOf<MetaItem>()
            for (addon in addons) {
                for (catalog in addon.catalogs) {
                    val items = NetworkUtils.fetchCatalog(addon.url, catalog.type, catalog.id)
                    allItems.addAll(items)
                }
            }
            val unique = allItems.distinctBy { it.id }
            _catalogs.value = unique
        }
    }

    fun getWatchlistCount(): LiveData<Int> {
        val count = MutableLiveData<Int>()
        viewModelScope.launch {
            val watchlist = repository.getWatchlist()
            count.value = watchlist.size
        }
        return count
    }
}
