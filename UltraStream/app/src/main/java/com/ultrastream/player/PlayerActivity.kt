package com.ultrastream.player

import android.content.pm.ActivityInfo
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.google.android.exoplayer2.*
import com.google.android.exoplayer2.source.MediaSource
import com.google.android.exoplayer2.source.ProgressiveMediaSource
import com.google.android.exoplayer2.source.dash.DashMediaSource
import com.google.android.exoplayer2.source.hls.HlsMediaSource
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector
import com.google.android.exoplayer2.ui.PlayerView
import com.google.android.exoplayer2.upstream.DefaultHttpDataSource
import com.google.android.exoplayer2.util.Util
import com.ultrastream.R
import com.ultrastream.UltraStreamApplication
import com.ultrastream.data.models.WatchHistory
import com.ultrastream.data.models.WatchProgress
import com.ultrastream.databinding.ActivityPlayerBinding
import com.ultrastream.utils.M3UParser
import kotlinx.coroutines.*
import java.net.URLDecoder

class PlayerActivity : AppCompatActivity() {

    private lateinit var binding: ActivityPlayerBinding
    private lateinit var player: ExoPlayer
    private lateinit var trackSelector: DefaultTrackSelector

    private var mediaUrl: String = ""
    private var mediaTitle: String = ""
    private var subtitleUrl: String? = null
    private var isLive: Boolean = false
    private var metaId: String? = null
    private var episodeKey: String? = null
    private var isM3U: Boolean = false
    private var m3uEntries: List<M3UParser.M3UEntry> = emptyList()
    private var m3uIndex: Int = 0

    private var isControlsLocked = false
    private val handler = Handler(Looper.getMainLooper())
    private var hideControlsRunnable: Runnable? = null
    private var progressSaveJob: Job? = null

    private var touchX = 0f
    private var touchY = 0f
    private var startBrightness = 0f
    private var startVolume = 0f

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityPlayerBinding.inflate(layoutInflater)
        setContentView(binding.root)

        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        mediaUrl = intent.getStringExtra(EXTRA_MEDIA_URL) ?: ""
        mediaTitle = intent.getStringExtra(EXTRA_MEDIA_TITLE) ?: "Video"
        subtitleUrl = intent.getStringExtra(EXTRA_SUBTITLE_URL)
        isLive = intent.getBooleanExtra(EXTRA_IS_LIVE, false)
        metaId = intent.getStringExtra(EXTRA_META_ID)
        episodeKey = intent.getStringExtra(EXTRA_EPISODE_KEY)

        if (mediaUrl.isEmpty()) {
            finish()
            return
        }

        // Check if it's an M3U playlist
        isM3U = mediaUrl.lowercase().contains(".m3u") && !mediaUrl.lowercase().contains(".m3u8")
        if (isM3U) {
            loadM3UPlaylist(mediaUrl)
        } else {
            setupPlayer(mediaUrl, subtitleUrl)
        }

        setupUI()
    }

    private fun loadM3UPlaylist(url: String) {
        lifecycleScope.launch(Dispatchers.IO) {
            try {
                val content = java.net.URL(url).readText()
                m3uEntries = M3UParser.parse(content)
                if (m3uEntries.isNotEmpty()) {
                    val first = m3uEntries.first()
                    withContext(Dispatchers.Main) {
                        setupPlayer(first.url, null)
                        mediaTitle = first.title
                        m3uIndex = 0
                        binding.playerView.setControllerVisibilityListener { visibility ->
                            if (visibility == View.VISIBLE) showCustomControls()
                        }
                    }
                } else {
                    withContext(Dispatchers.Main) {
                        Toast.makeText(this@PlayerActivity, "No playable entries in M3U", Toast.LENGTH_SHORT).show()
                        finish()
                    }
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    Toast.makeText(this@PlayerActivity, "Failed to load M3U", Toast.LENGTH_SHORT).show()
                    finish()
                }
            }
        }
    }

    private fun setupPlayer(url: String, subtitleUrl: String?) {
        trackSelector = DefaultTrackSelector(this)
        player = ExoPlayer.Builder(this)
            .setTrackSelector(trackSelector)
            .build()

        binding.playerView.player = player
        binding.playerView.setShowBuffering(PlayerView.SHOW_BUFFERING_WHEN_PLAYING)
        binding.playerView.useController = true

        val dataSourceFactory = DefaultHttpDataSource.Factory()
        val mediaSource = buildMediaSource(url, dataSourceFactory)

        // Subtitle injection
        var mediaItem = MediaItem.fromUri(Uri.parse(url))
        if (subtitleUrl != null) {
            val subtitleConfiguration = MediaItem.SubtitleConfiguration.Builder(Uri.parse(subtitleUrl))
                .setMimeType("text/vtt")
                .setLanguage("en")
                .build()
            mediaItem = mediaItem.buildUpon()
                .setSubtitleConfigurations(listOf(subtitleConfiguration))
                .build()
        }

        player.setMediaSource(mediaSource)
        player.prepare()
        player.playWhenReady = true

        // Auto-play next for M3U if enabled
        player.addListener(object : Player.Listener {
            override fun onPlaybackStateChanged(state: Int) {
                if (state == Player.STATE_ENDED) {
                    if (isM3U && m3uEntries.isNotEmpty()) {
                        val nextIndex = m3uIndex + 1
                        if (nextIndex < m3uEntries.size) {
                            m3uIndex = nextIndex
                            val next = m3uEntries[nextIndex]
                            Toast.makeText(this@PlayerActivity, "Next: ${next.title}", Toast.LENGTH_SHORT).show()
                            // Play next
                            setupPlayer(next.url, null)
                            mediaTitle = next.title
                        }
                    }
                    // Also check for series auto-play next
                    if (metaId != null && episodeKey != null && m3uEntries.isEmpty()) {
                        val prefs = UltraStreamApplication.instance.prefs
                        if (prefs.getAutoPlayNext()) {
                            // Suggest next episode - not implemented in this simplified version
                        }
                    }
                }
            }
        })

        // Save progress periodically and on pause
        player.addListener(object : Player.Listener {
            override fun onPlaybackStateChanged(state: Int) {
                if (state == Player.STATE_READY) {
                    scheduleProgressSave()
                } else if (state == Player.STATE_ENDED) {
                    saveProgress(100f, saveHistory = true)
                }
            }
            override fun onIsPlayingChanged(isPlaying: Boolean) {
                if (!isPlaying) {
                    saveProgress(getCurrentPercent(), saveHistory = false)
                }
            }
        })

        // Save history when playback starts
        if (metaId != null) {
            lifecycleScope.launch(Dispatchers.IO) {
                val meta = UltraStreamApplication.instance.repository.getCachedMeta(metaId!!)
                if (meta != null) {
                    val history = WatchHistory(
                        id = meta.id,
                        type = meta.type,
                        name = meta.name,
                        poster = meta.poster
                    )
                    UltraStreamApplication.instance.repository.addHistory(history)
                }
            }
        }
    }

    private fun getCurrentPercent(): Float {
        if (player.duration <= 0) return 0f
        return (player.currentPosition.toFloat() / player.duration.toFloat()) * 100
    }

    private fun scheduleProgressSave() {
        progressSaveJob?.cancel()
        progressSaveJob = lifecycleScope.launch {
            while (isActive) {
                delay(5000) // Save every 5 seconds
                saveProgress(getCurrentPercent(), saveHistory = false)
            }
        }
    }

    private fun saveProgress(percent: Float, saveHistory: Boolean) {
        if (metaId == null) return
        val id = episodeKey ?: metaId!!
        lifecycleScope.launch(Dispatchers.IO) {
            val progress = WatchProgress(id, percent.coerceIn(0f, 100f))
            UltraStreamApplication.instance.repository.saveProgress(progress)
            if (saveHistory && percent >= 95f) {
                // Mark as watched
                if (episodeKey != null) {
                    UltraStreamApplication.instance.repository.markEpisodeWatched(episodeKey!!)
                }
            }
        }
    }

    private fun buildMediaSource(url: String, dataSourceFactory: DefaultHttpDataSource.Factory): MediaSource {
        val uri = Uri.parse(url)
        return when {
            url.contains(".m3u8") -> HlsMediaSource.Factory(dataSourceFactory).createMediaSource(MediaItem.fromUri(uri))
            url.contains(".mpd") -> DashMediaSource.Factory(dataSourceFactory).createMediaSource(MediaItem.fromUri(uri))
            else -> ProgressiveMediaSource.Factory(dataSourceFactory).createMediaSource(MediaItem.fromUri(uri))
        }
    }

    private fun setupUI() {
        binding.playerView.setControllerVisibilityListener { visibility ->
            if (visibility == View.VISIBLE) {
                showCustomControls()
            }
        }

        binding.btnPip.setOnClickListener {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                enterPictureInPictureMode()
            }
        }

        binding.btnLock.setOnClickListener {
            isControlsLocked = !isControlsLocked
            binding.btnLock.setImageResource(
                if (isControlsLocked) R.drawable.ic_lock else R.drawable.ic_lock_open
            )
            if (isControlsLocked) {
                binding.playerView.useController = false
                binding.btnPip.visibility = View.GONE
                binding.btnLock.visibility = View.GONE
                Toast.makeText(this, "Controls Locked", Toast.LENGTH_SHORT).show()
            } else {
                binding.playerView.useController = true
                binding.btnPip.visibility = View.VISIBLE
                binding.btnLock.visibility = View.VISIBLE
                Toast.makeText(this, "Controls Unlocked", Toast.LENGTH_SHORT).show()
            }
        }

        binding.playerView.setOnTouchListener { _, event ->
            if (isControlsLocked) return@setOnTouchListener false
            handleTouch(event)
            true
        }

        binding.playerView.setOnClickListener {
            if (isControlsLocked) return@setOnClickListener
            if (player.isPlaying) {
                player.pause()
            } else {
                player.play()
            }
        }

        player.addListener(object : Player.Listener {
            override fun onPlayerError(error: PlaybackException) {
                showError("Playback Error: ${error.message}")
            }
        })
    }

    private fun showCustomControls() {
        binding.btnPip.visibility = if (!isControlsLocked) View.VISIBLE else View.GONE
        binding.btnLock.visibility = View.VISIBLE
        hideControlsRunnable?.let { handler.removeCallbacks(it) }
        hideControlsRunnable = Runnable {
            binding.btnPip.visibility = View.GONE
            binding.btnLock.visibility = View.GONE
        }
        handler.postDelayed(hideControlsRunnable!!, 3000)
    }

    private fun handleTouch(event: MotionEvent) {
        when (event.action) {
            MotionEvent.ACTION_DOWN -> {
                touchX = event.x
                touchY = event.y
                startBrightness = window.attributes.screenBrightness
                startVolume = player.volume
            }
            MotionEvent.ACTION_MOVE -> {
                val deltaX = event.x - touchX
                val deltaY = event.y - touchY

                if (event.x < binding.playerView.width * 0.3f) {
                    val brightnessChange = -deltaY / binding.playerView.height
                    val newBrightness = (startBrightness + brightnessChange).coerceIn(0.01f, 1f)
                    window.attributes = window.attributes.apply {
                        screenBrightness = newBrightness
                    }
                } else if (event.x > binding.playerView.width * 0.7f) {
                    val volumeChange = -deltaY / binding.playerView.height
                    val newVolume = (startVolume + volumeChange).coerceIn(0f, 1f)
                    player.volume = newVolume
                } else {
                    val seekAmount = (deltaX / binding.playerView.width) * 60000
                    val currentPos = player.currentPosition
                    val newPos = (currentPos + seekAmount.toLong()).coerceIn(0L, player.duration)
                    player.seekTo(newPos)
                }
            }
        }
    }

    override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean, newConfig: android.content.res.Configuration) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        if (isInPictureInPictureMode) {
            binding.playerView.useController = false
        } else {
            binding.playerView.useController = true
        }
    }

    private fun showError(message: String) {
        binding.errorLayout.visibility = View.VISIBLE
        binding.tvError.text = message
        binding.btnRetry.setOnClickListener {
            binding.errorLayout.visibility = View.GONE
            player.prepare()
            player.playWhenReady = true
        }
    }

    override fun onPause() {
        super.onPause()
        if (Util.SDK_INT < 24) {
            player.playWhenReady = false
            saveProgress(getCurrentPercent(), saveHistory = true)
        }
    }

    override fun onStop() {
        super.onStop()
        if (Util.SDK_INT >= 24) {
            player.playWhenReady = false
            saveProgress(getCurrentPercent(), saveHistory = true)
        }
        progressSaveJob?.cancel()
    }

    override fun onDestroy() {
        super.onDestroy()
        player.release()
        handler.removeCallbacksAndMessages(null)
        progressSaveJob?.cancel()
    }

    override fun onKeyDown(keyCode: Int, event: android.view.KeyEvent?): Boolean {
        return when (keyCode) {
            android.view.KeyEvent.KEYCODE_DPAD_CENTER -> {
                if (player.isPlaying) player.pause() else player.play()
                true
            }
            android.view.KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE -> {
                if (player.isPlaying) player.pause() else player.play()
                true
            }
            else -> super.onKeyDown(keyCode, event)
        }
    }

    companion object {
        const val EXTRA_MEDIA_URL = "media_url"
        const val EXTRA_MEDIA_TITLE = "media_title"
        const val EXTRA_SUBTITLE_URL = "subtitle_url"
        const val EXTRA_IS_LIVE = "is_live"
        const val EXTRA_META_ID = "meta_id"
        const val EXTRA_EPISODE_KEY = "episode_key"
    }
}
