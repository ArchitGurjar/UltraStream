package com.ultrastream.ui.library

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.ultrastream.UltraStreamApplication
import com.ultrastream.data.models.*
import com.ultrastream.utils.EpisodeMatcher
import com.ultrastream.utils.LinkVerifier
import com.ultrastream.utils.NetworkUtils
import com.ultrastream.utils.StreamParser
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.first

class LibraryViewModel : ViewModel() {

    private val repository = UltraStreamApplication.instance.repository

    private val _playlists = MutableLiveData<List<SmartPlaylist>>(emptyList())
    val playlists: LiveData<List<SmartPlaylist>> = _playlists

    private val _history = MutableLiveData<List<WatchHistory>>(emptyList())
    val history: LiveData<List<WatchHistory>> = _history

    private val _watchlist = MutableLiveData<List<MetaItem>>(emptyList())
    val watchlist: LiveData<List<MetaItem>> = _watchlist

    private val _library = MutableLiveData<List<MetaItem>>(emptyList())
    val library: LiveData<List<MetaItem>> = _library

    private val _progressMap = MutableLiveData<Map<String, WatchProgress>>(emptyMap())
    val progressMap: LiveData<Map<String, WatchProgress>> = _progressMap

    private var fetchJob: Job? = null

    init {
        loadAllData()
    }

    fun loadAllData() {
        viewModelScope.launch {
            repository.getPlaylists().first().let { _playlists.value = it }
            repository.getHistory().first().let { _history.value = it }
            repository.getWatchlist().let { _watchlist.value = it }
            repository.getLibrary().let { _library.value = it }
            repository.getProgress().first().let { progress ->
                _progressMap.value = progress.associate { it.id to it }
            }
        }
    }

    // ─── SMART PLAYLIST AUTO-FETCH ENGINE ───
    // Replicates the exact logic from makeSmartPlaylist() in app.js
    fun buildSmartPlaylist(
        meta: MetaItem,
        season: Int,
        startEpisode: Int,
        initialStream: Stream,
        initialAddonName: String
    ) {
        viewModelScope.launch {
            // Cancel previous fetch if any
            fetchJob?.cancel()
            fetchJob = launch {
                try {
                    val playlistId = "${meta.id}_s${season}_${initialAddonName}"
                    val allEpisodes = meta.videos?.filter { it.season == season && it.episode >= startEpisode }
                        ?.sortedBy { it.episode } ?: emptyList()

                    if (allEpisodes.isEmpty()) return@launch

                    // Create playlist skeleton
                    val initialEp = allEpisodes.first()
                    val initialStreamCopy = initialStream.copy(addonName = initialAddonName)
                    val initialEpisode = PlaylistEpisode(
                        epNum = initialEp.episode,
                        epName = initialEp.name ?: "Episode ${initialEp.episode}",
                        title = "${meta.name} - S${season}E${initialEp.episode}",
                        stream = initialStreamCopy
                    )

                    val playlist = SmartPlaylist(
                        id = playlistId,
                        metaId = meta.id,
                        metaName = meta.name,
                        poster = meta.poster,
                        season = season,
                        addon = initialAddonName,
                        total = allEpisodes.size,
                        fetched = 1,
                        status = "Fetching...",
                        episodes = listOf(initialEpisode)
                    )
                    repository.savePlaylist(playlist)
                    loadAllData() // refresh UI

                    // Process remaining episodes
                    val remainingEpisodes = allEpisodes.drop(1)
                    val enabledAddons = repository.getEnabledAddons()
                    val parsedInitial = StreamParser.parse(
                        (initialStream.title ?: "") + "\n" +
                        (initialStream.description ?: "") + "\n" +
                        (initialStream.name ?: "")
                    )
                    val targetSize = parsedInitial.sizeValueBytes
                    val targetHasHindi = parsedInitial.hasHindi
                    val targetQuals = parsedInitial.quals

                    var fetchedCount = 1

                    for (ep in remainingEpisodes) {
                        val fullId = "${meta.id}:${season}:${ep.episode}"
                        val allAvailableStreams = mutableListOf<Pair<Stream, String>>()

                        // Fetch from all addons in parallel
                        val fetchJobs = enabledAddons.map { addon ->
                            async {
                                try {
                                    val streams = NetworkUtils.fetchStreams(fullId, meta.type)
                                    streams.forEach { stream ->
                                        if (EpisodeMatcher.isValidEpisodeStream(stream, season, ep.episode)) {
                                            allAvailableStreams.add(stream to addon.name)
                                        }
                                    }
                                } catch (_: Exception) { }
                            }
                        }
                        fetchJobs.awaitAll()

                        // Apply filters
                        var candidates = allAvailableStreams
                        if (targetHasHindi) {
                            val hindiCandidates = candidates.filter {
                                StreamParser.parse(
                                    (it.first.title ?: "") + "\n" +
                                    (it.first.description ?: "") + "\n" +
                                    (it.first.name ?: "")
                                ).hasHindi
                            }
                            if (hindiCandidates.isNotEmpty()) candidates = hindiCandidates
                        }

                        if (targetQuals.isNotEmpty()) {
                            val qualCandidates = candidates.filter {
                                val parsed = StreamParser.parse(
                                    (it.first.title ?: "") + "\n" +
                                    (it.first.description ?: "") + "\n" +
                                    (it.first.name ?: "")
                                )
                                parsed.quals.any { q -> targetQuals.contains(q) }
                            }
                            if (qualCandidates.isNotEmpty()) candidates = qualCandidates
                        }

                        // Prioritize addon and size
                        val prioritized = mutableListOf<Pair<Stream, String>>()
                        // First, same addon with size within 2x
                        if (targetSize != null) {
                            candidates.filter { it.second == initialAddonName && it.first.url != null }
                                .filter {
                                    val size = StreamParser.parse(
                                        (it.first.title ?: "") + "\n" +
                                        (it.first.description ?: "") + "\n" +
                                        (it.first.name ?: "")
                                    ).sizeValueBytes
                                    size != null && size <= targetSize * 2
                                }
                                .forEach { prioritized.add(it) }
                            // then other addons with size within 3x
                            candidates.filter { it.second != initialAddonName && it.first.url != null }
                                .filter {
                                    val size = StreamParser.parse(
                                        (it.first.title ?: "") + "\n" +
                                        (it.first.description ?: "") + "\n" +
                                        (it.first.name ?: "")
                                    ).sizeValueBytes
                                    size != null && size <= targetSize * 3
                                }
                                .forEach { prioritized.add(it) }
                        } else {
                            candidates.filter { it.second == initialAddonName && it.first.url != null }
                                .forEach { prioritized.add(it) }
                            candidates.filter { it.second != initialAddonName && it.first.url != null }
                                .forEach { prioritized.add(it) }
                        }

                        // Verify links (limit to first 20)
                        var bestMatch: Pair<Stream, String>? = null
                        val toCheck = prioritized.take(20)
                        for (candidate in toCheck) {
                            val url = candidate.first.url ?: candidate.first.streamUrl ?: candidate.first.externalUrl
                            if (url != null && !url.startsWith("magnet:")) {
                                val isValid = LinkVerifier.verify(url)
                                if (isValid) {
                                    bestMatch = candidate
                                    break
                                }
                            }
                        }

                        // Prepare episode data
                        val epTitle = "${meta.name} - S${String.format("%02d", season)}E${String.format("%02d", ep.episode)}"
                        val newEpisode = PlaylistEpisode(
                            epNum = ep.episode,
                            epName = ep.name ?: "Episode ${ep.episode}",
                            title = epTitle,
                            stream = bestMatch?.first?.copy(addonName = bestMatch.second),
                            isMissing = bestMatch == null
                        )

                        // Update playlist
                        val updatedPlaylist = repository.getPlaylist(playlistId)
                        if (updatedPlaylist != null) {
                            val newEpisodes = updatedPlaylist.episodes + newEpisode
                            val updated = updatedPlaylist.copy(
                                episodes = newEpisodes,
                                fetched = newEpisodes.size,
                                status = if (newEpisodes.size == updatedPlaylist.total) "Ready to Play" else "Fetching..."
                            )
                            repository.updatePlaylist(updated)
                            _playlists.value = repository.getPlaylists().first()
                        }
                        fetchedCount++
                    }

                    // Final update
                    val finalPlaylist = repository.getPlaylist(playlistId)
                    if (finalPlaylist != null) {
                        val updated = finalPlaylist.copy(
                            status = if (finalPlaylist.fetched == finalPlaylist.total) "Ready to Play" else "Fetching..."
                        )
                        repository.updatePlaylist(updated)
                        _playlists.value = repository.getPlaylists().first()
                    }

                } catch (e: Exception) {
                    Log.e("LibraryViewModel", "Playlist fetch error", e)
                }
            }
        }
    }

    fun deletePlaylist(id: String) {
        viewModelScope.launch {
            repository.deletePlaylist(id)
            loadAllData()
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
            _watchlist.value = current
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
            _library.value = current
        }
    }

    fun isInWatchlist(metaId: String): Boolean {
        return _watchlist.value?.any { it.id == metaId } ?: false
    }

    fun isInLibrary(metaId: String): Boolean {
        return _library.value?.any { it.id == metaId } ?: false
    }
}
