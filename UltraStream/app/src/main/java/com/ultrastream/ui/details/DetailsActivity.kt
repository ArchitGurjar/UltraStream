package com.ultrastream.ui.details

import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import com.bumptech.glide.Glide
import com.google.android.material.chip.Chip
import com.ultrastream.R
import com.ultrastream.databinding.ActivityDetailsBinding
import com.ultrastream.data.models.Video
import com.ultrastream.ui.adapters.EpisodeAdapter
import com.ultrastream.ui.sheets.SeasonSelectBottomSheet
import com.ultrastream.ui.sheets.StreamBottomSheet
import kotlinx.coroutines.launch

class DetailsActivity : AppCompatActivity() {

    private lateinit var binding: ActivityDetailsBinding
    private val viewModel: DetailsViewModel by viewModels()

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

        setupObservers()
        setupListeners()
        viewModel.loadMeta(metaId, metaType)
    }

    private fun setupObservers() {
        viewModel.meta.observe(this) { meta ->
            if (meta != null) {
                populateUI(meta)
            } else {
                showLoading(false)
                Toast.makeText(this, "Metadata not found", Toast.LENGTH_SHORT).show()
            }
        }

        viewModel.isInWatchlist.observe(this) { inWatchlist ->
            binding.btnWatchlist.setImageResource(
                if (inWatchlist) R.drawable.ic_watchlist_filled else R.drawable.ic_watchlist
            )
        }

        viewModel.isInLibrary.observe(this) { inLibrary ->
            binding.btnLibrary.setImageResource(
                if (inLibrary) R.drawable.ic_bookmark_filled else R.drawable.ic_bookmark
            )
        }

        viewModel.episodeProgress.observe(this) { progressMap ->
            episodeAdapter.updateProgress(progressMap)
        }
    }

    private fun populateUI(meta: com.ultrastream.data.models.MetaItem) {
        showLoading(false)

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

        binding.castChipGroup.removeAllViews()
        meta.cast?.take(8)?.forEach { actor ->
            val chip = Chip(this).apply {
                text = actor
                isClickable = true
                setOnClickListener {
                    // Search for actor - not implemented
                }
            }
            binding.castChipGroup.addView(chip)
        }

        if (!meta.imdbId.isNullOrEmpty()) {
            binding.btnImdb.visibility = View.VISIBLE
            binding.btnImdb.setOnClickListener {
                val url = "https://www.imdb.com/title/${meta.imdbId}"
                startActivity(android.content.Intent(android.content.Intent.ACTION_VIEW, android.net.Uri.parse(url)))
            }
        }

        val isEpisodic = !meta.videos.isNullOrEmpty()
        if (isEpisodic) {
            binding.episodesContainer.visibility = View.VISIBLE
            binding.btnFindStreams.visibility = View.GONE
            setupEpisodes(meta)
        } else {
            binding.episodesContainer.visibility = View.GONE
            binding.btnFindStreams.visibility = View.VISIBLE
            binding.btnFindStreams.setOnClickListener {
                showStreams(null, meta)
            }
        }

        // Watchlist/Library toggle listeners
        binding.btnWatchlist.setOnClickListener {
            viewModel.toggleWatchlist(meta)
        }
        binding.btnLibrary.setOnClickListener {
            viewModel.toggleLibrary(meta)
        }
    }

    private fun setupEpisodes(meta: com.ultrastream.data.models.MetaItem) {
        val videos = meta.videos ?: emptyList()
        allEpisodes = videos.filter { it.season > 0 && it.episode > 0 }
            .sortedWith(compareBy<Video> { it.season }.thenBy { it.episode })

        if (allEpisodes.isEmpty()) {
            binding.episodesContainer.visibility = View.GONE
            binding.btnFindStreams.visibility = View.VISIBLE
            return
        }

        currentSeason = allEpisodes.firstOrNull()?.season ?: 1

        episodeAdapter = EpisodeAdapter(
            onItemClick = { episode ->
                showStreams(episode, meta)
            },
            onMarkWatched = { episode ->
                viewModel.markEpisodeWatched(meta.id, episode.season, episode.episode)
            }
        )
        binding.rvEpisodes.layoutManager = LinearLayoutManager(this)
        binding.rvEpisodes.adapter = episodeAdapter

        // Season selector
        val seasonBtn = binding.sectionMore
        seasonBtn.visibility = View.VISIBLE
        seasonBtn.text = "Season $currentSeason ▼"
        seasonBtn.setOnClickListener {
            showSeasonSelector(meta)
        }

        renderEpisodes()
    }

    private fun renderEpisodes() {
        val filtered = allEpisodes.filter { it.season == currentSeason }
        val progressMap = viewModel.episodeProgress.value ?: emptyMap()
        episodeAdapter.submitList(filtered, progressMap)
    }

    private fun showSeasonSelector(meta: com.ultrastream.data.models.MetaItem) {
        val seasons = allEpisodes.map { it.season }.distinct().sorted()
        val bottomSheet = SeasonSelectBottomSheet(seasons, currentSeason) { selectedSeason ->
            currentSeason = selectedSeason
            binding.sectionMore.text = "Season $currentSeason ▼"
            renderEpisodes()
        }
        bottomSheet.show(supportFragmentManager, "season_selector")
    }

    private fun showStreams(episode: Video?, meta: com.ultrastream.data.models.MetaItem) {
        val bottomSheet = StreamBottomSheet(meta.id, meta.type, episode)
        bottomSheet.show(supportFragmentManager, "stream_sheet")
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
