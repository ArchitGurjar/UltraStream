package com.ultrastream.ui.details

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.ultrastream.UltraStreamApplication
import com.ultrastream.data.models.MetaItem
import com.ultrastream.data.models.Video
import com.ultrastream.utils.NetworkUtils
import kotlinx.coroutines.launch

class DetailsViewModel : ViewModel() {

    private val repository = UltraStreamApplication.instance.repository

    private val _meta = MutableLiveData<MetaItem?>()
    val meta: LiveData<MetaItem?> = _meta

    private val _isInWatchlist = MutableLiveData(false)
    val isInWatchlist: LiveData<Boolean> = _isInWatchlist

    private val _isInLibrary = MutableLiveData(false)
    val isInLibrary: LiveData<Boolean> = _isInLibrary

    private val _episodeProgress = MutableLiveData<Map<String, Float>>(emptyMap())
    val episodeProgress: LiveData<Map<String, Float>> = _episodeProgress

    fun loadMeta(metaId: String, metaType: String) {
        viewModelScope.launch {
            var cached = repository.getCachedMeta(metaId)
            if (cached == null) {
                val fetched = NetworkUtils.fetchMeta(metaId, metaType)
                if (fetched != null) {
                    repository.cacheMeta(fetched)
                    cached = fetched
                }
            }
            _meta.value = cached
            if (cached != null) {
                updateWatchlistStatus(cached.id)
                updateLibraryStatus(cached.id)
                loadEpisodeProgress(cached)
            }
        }
    }

    private fun updateWatchlistStatus(metaId: String) {
        viewModelScope.launch {
            val watchlist = repository.getWatchlist()
            _isInWatchlist.value = watchlist.any { it.id == metaId }
        }
    }

    private fun updateLibraryStatus(metaId: String) {
        viewModelScope.launch {
            val library = repository.getLibrary()
            _isInLibrary.value = library.any { it.id == metaId }
        }
    }

    private fun loadEpisodeProgress(meta: MetaItem) {
        viewModelScope.launch {
            val progressList = repository.getProgress().first()
            val map = mutableMapOf<String, Float>()
            meta.videos?.forEach { video ->
                val key = "${meta.id}_s${video.season}_e${video.episode}"
                val p = progressList.find { it.id == key }
                if (p != null && p.percent > 0) {
                    map[key] = p.percent
                }
            }
            _episodeProgress.value = map
        }
    }

    fun toggleWatchlist(meta: MetaItem) {
        viewModelScope.launch {
            val current = repository.getWatchlist().toMutableList()
            val idx = current.indexOfFirst { it.id == meta.id }
            if (idx != -1) {
                current.removeAt(idx)
            } else {
                current.add(meta)
            }
            repository.setWatchlist(current)
            _isInWatchlist.value = current.any { it.id == meta.id }
        }
    }

    fun toggleLibrary(meta: MetaItem) {
        viewModelScope.launch {
            val current = repository.getLibrary().toMutableList()
            val idx = current.indexOfFirst { it.id == meta.id }
            if (idx != -1) {
                current.removeAt(idx)
            } else {
                current.add(meta)
            }
            repository.setLibrary(current)
            _isInLibrary.value = current.any { it.id == meta.id }
        }
    }

    fun markEpisodeWatched(metaId: String, season: Int, episode: Int) {
        viewModelScope.launch {
            val key = "${metaId}_s${season}_e${episode}"
            repository.markEpisodeWatched(key)
            // Update progress to 100%
            val progress = repository.getProgressById(key)
            if (progress != null) {
                repository.saveProgress(progress.copy(percent = 100f))
            } else {
                repository.saveProgress(com.ultrastream.data.models.WatchProgress(key, 100f))
            }
            // Refresh progress
            val meta = _meta.value
            if (meta != null) {
                loadEpisodeProgress(meta)
            }
        }
    }
}
