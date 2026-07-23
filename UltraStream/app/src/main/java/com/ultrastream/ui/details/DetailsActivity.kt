// app/src/main/java/com/ultrastream/ui/details/DetailsActivity.kt
package com.ultrastream.ui.details

import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import com.bumptech.glide.Glide
import com.google.android.material.chip.Chip
import com.ultrastream.R
import com.ultrastream.UltraStreamApplication
import com.ultrastream.databinding.ActivityDetailsBinding
import com.ultrastream.data.models.MetaItem
import com.ultrastream.data.models.Video
import com.ultrastream.ui.adapters.EpisodeAdapter
import com.ultrastream.ui.sheets.SeasonSelectBottomSheet
import com.ultrastream.ui.sheets.StreamBottomSheet
import com.ultrastream.utils.NetworkUtils
import kotlinx.coroutines.launch

class DetailsActivity : AppCompatActivity() {

    private lateinit var binding: ActivityDetailsBinding
    private lateinit var meta: MetaItem
    private var metaId: String = ""
    private var metaType: String = ""

    private lateinit var episodeAdapter: EpisodeAdapter
    private var allEpisodes: List<Video> = emptyList()
    private var currentSeason: Int = 1

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityDetailsBinding.inflate(layoutInflater)
        setContentView(binding.root)

        metaId = intent.getStringExtra(EXTRA_META_ID) ?: ""
        metaType = intent.getStringExtra(EXTRA_META_TYPE) ?: "movie"

        loadMetadata()
        setupListeners()
    }

    private fun loadMetadata() {
        showLoading(true)
        lifecycleScope.launch {
            var cached = (application as UltraStreamApplication).repository.getCachedMeta(metaId)
            if (cached == null) {
                val fetched = NetworkUtils.fetchMeta(metaId, metaType)
                if (fetched != null) {
                    (application as UltraStreamApplication).repository.cacheMeta(fetched)
                    meta = fetched
                } else {
                    showLoading(false)
                    return@launch
                }
            } else {
                meta = cached
            }
            showLoading(false)
            populateUI()
        }
    }

    private fun populateUI() {
        Glide.with(this)
            .load(meta.poster ?: meta.background)
            .placeholder(R.drawable.placeholder_poster)
            .into(binding.heroImage)

        binding.tvNetwork.text = meta.type.uppercase()
        binding.tvTitle.text = meta.name
        binding.tvYear.text = meta.year?.toString() ?: ""
        binding.tvRuntime.text = meta.runtime ?: "N/A"
        binding.tvRating.text = "⭐ ${meta.imdbRating ?: "N/A"}"
        binding.tvGenre.text = meta.genre?.take(3)?.joinToString(", ") ?: ""

        binding.tvDescription.text = meta.description ?: "No description available."
        if (meta.description?.length ?: 0 > 200) {
            binding.tvReadMore.visibility = View.VISIBLE
            binding.tvReadMore.setOnClickListener {
                binding.tvDescription.maxLines = if (binding.tvDescription.maxLines == 4) Int.MAX_VALUE else 4
                binding.tvReadMore.text = if (binding.tvDescription.maxLines == Int.MAX_VALUE) "Read less" else "Read more"
            }
        }

        meta.cast?.take(8)?.forEach { actor ->
            val chip = Chip(this).apply {
                text = actor
                isClickable = true
                setOnClickListener { /* search actor */ }
            }
            binding.castChipGroup.addView(chip)
        }

        if (!meta.imdbId.isNullOrEmpty()) {
            binding.btnImdb.visibility = View.VISIBLE
            binding.btnImdb.setOnClickListener { /* open IMDb */ }
        }

        val isEpisodic = !meta.videos.isNullOrEmpty()
        if (isEpisodic) {
            binding.episodesContainer.visibility = View.VISIBLE
            binding.btnFindStreams.visibility = View.GONE
            setupEpisodes()
        } else {
            binding.episodesContainer.visibility = View.GONE
            binding.btnFindStreams.visibility = View.VISIBLE
            binding.btnFindStreams.setOnClickListener {
                showStreams(null)
            }
        }

        updateWatchlistIcon()
        updateLibraryIcon()
    }

    private fun setupEpisodes() {
        val videos = meta.videos ?: emptyList()
        allEpisodes = videos.filter { it.season > 0 && it.episode > 0 }
            .sortedWith(compareBy<Video> { it.season }.thenBy { it.episode })

        if (allEpisodes.isEmpty()) {
            binding.episodesContainer.visibility = View.GONE
            binding.btnFindStreams.visibility = View.VISIBLE
            return
        }

        currentSeason = allEpisodes.firstOrNull()?.season ?: 1

        episodeAdapter = EpisodeAdapter { episode ->
            showStreams(episode)
        }

        // Show season selector
        val seasonBtn = binding.sectionMore
        seasonBtn.visibility = View.VISIBLE
        seasonBtn.text = "Season $currentSeason ▼"
        seasonBtn.setOnClickListener {
            showSeasonSelector()
        }

        renderEpisodes()
    }

    private fun renderEpisodes() {
        val filtered = allEpisodes.filter { it.season == currentSeason }
        binding.rvEpisodes.layoutManager = LinearLayoutManager(this)
        binding.rvEpisodes.adapter = episodeAdapter
        episodeAdapter.submitList(filtered)
    }

    private fun showSeasonSelector() {
        val seasons = allEpisodes.map { it.season }.distinct().sorted()
        val bottomSheet = SeasonSelectBottomSheet(seasons, currentSeason) { selectedSeason ->
            currentSeason = selectedSeason
            binding.sectionMore.text = "Season $currentSeason ▼"
            renderEpisodes()
        }
        bottomSheet.show(supportFragmentManager, "season_selector")
    }

    private fun showStreams(episode: Video?) {
        val bottomSheet = StreamBottomSheet(metaId, metaType, episode)
        bottomSheet.show(supportFragmentManager, "stream_sheet")
    }

    private fun updateWatchlistIcon() {
        lifecycleScope.launch {
            val watchlist = (application as UltraStreamApplication).repository.getWatchlist()
            val inWatchlist = watchlist.any { it.id == metaId }
            binding.btnWatchlist.setImageResource(
                if (inWatchlist) R.drawable.ic_watchlist_filled else R.drawable.ic_watchlist
            )
            binding.btnWatchlist.setOnClickListener { toggleWatchlist() }
        }
    }

    private fun toggleWatchlist() {
        lifecycleScope.launch {
            val watchlist = (application as UltraStreamApplication).repository.getWatchlist().toMutableList()
            val idx = watchlist.indexOfFirst { it.id == metaId }
            if (idx != -1) {
                watchlist.removeAt(idx)
                android.widget.Toast.makeText(this@DetailsActivity, "Removed from watchlist", android.widget.Toast.LENGTH_SHORT).show()
            } else {
                watchlist.add(meta)
                android.widget.Toast.makeText(this@DetailsActivity, "Added to watchlist", android.widget.Toast.LENGTH_SHORT).show()
            }
            (application as UltraStreamApplication).repository.setWatchlist(watchlist)
            updateWatchlistIcon()
        }
    }

    private fun updateLibraryIcon() {
        lifecycleScope.launch {
            val library = (application as UltraStreamApplication).repository.getLibrary()
            val inLibrary = library.any { it.id == metaId }
            binding.btnLibrary.setImageResource(
                if (inLibrary) R.drawable.ic_bookmark_filled else R.drawable.ic_bookmark
            )
            binding.btnLibrary.setOnClickListener { toggleLibrary() }
        }
    }

    private fun toggleLibrary() {
        lifecycleScope.launch {
            val library = (application as UltraStreamApplication).repository.getLibrary().toMutableList()
            val idx = library.indexOfFirst { it.id == metaId }
            if (idx != -1) {
                library.removeAt(idx)
                android.widget.Toast.makeText(this@DetailsActivity, "Removed from library", android.widget.Toast.LENGTH_SHORT).show()
            } else {
                library.add(meta)
                android.widget.Toast.makeText(this@DetailsActivity, "Added to library", android.widget.Toast.LENGTH_SHORT).show()
            }
            (application as UltraStreamApplication).repository.setLibrary(library)
            updateLibraryIcon()
        }
    }

    private fun showLoading(show: Boolean) {
        binding.loadingOverlay.visibility = if (show) View.VISIBLE else View.GONE
    }

    private fun setupListeners() {
        binding.btnBack.setOnClickListener { finish() }
    }

    companion object {
        const val EXTRA_META_ID = "meta_id"
        const val EXTRA_META_TYPE = "meta_type"
    }
}
