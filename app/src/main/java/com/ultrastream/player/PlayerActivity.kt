package com.ultrastream.player

import android.content.pm.ActivityInfo
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import androidx.appcompat.app.AppCompatActivity
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
import com.ultrastream.databinding.ActivityPlayerBinding

class PlayerActivity : AppCompatActivity() {

    private lateinit var binding: ActivityPlayerBinding
    private lateinit var player: ExoPlayer
    private lateinit var trackSelector: DefaultTrackSelector

    private var mediaUrl: String = ""
    private var mediaTitle: String = ""
    private var subtitleUrl: String? = null
    private var isLive: Boolean = false

    private var isControlsLocked = false
    private val handler = Handler(Looper.getMainLooper())
    private var hideControlsRunnable: Runnable? = null

    private var touchX = 0f
    private var touchY = 0f
    private var startBrightness = 0f
    private var startVolume = 0f

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityPlayerBinding.inflate(layoutInflater)
        setContentView(binding.root)

        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        mediaUrl = intent.getStringExtra("media_url") ?: ""
        mediaTitle = intent.getStringExtra("media_title") ?: "Video"
        subtitleUrl = intent.getStringExtra("subtitle_url")
        isLive = intent.getBooleanExtra("is_live", false)

        if (mediaUrl.isEmpty()) {
            finish()
            return
        }

        setupPlayer()
        setupUI()
    }

    private fun setupPlayer() {
        trackSelector = DefaultTrackSelector(this)
        player = ExoPlayer.Builder(this)
            .setTrackSelector(trackSelector)
            .build()

        binding.playerView.player = player
        binding.playerView.setShowBuffering(PlayerView.SHOW_BUFFERING_WHEN_PLAYING)
        binding.playerView.useController = true

        val dataSourceFactory = DefaultHttpDataSource.Factory()
        val mediaSource = buildMediaSource(mediaUrl, dataSourceFactory)

        player.setMediaSource(mediaSource)
        player.prepare()
        player.playWhenReady = true
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
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
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
                showToast("Controls Locked")
            } else {
                binding.playerView.useController = true
                binding.btnPip.visibility = View.VISIBLE
                binding.btnLock.visibility = View.VISIBLE
                showToast("Controls Unlocked")
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
                startVolume = 0f
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
                    // Volume
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

    private fun showToast(message: String) {
        android.widget.Toast.makeText(this, message, android.widget.Toast.LENGTH_SHORT).show()
    }

    override fun onStart() {
        super.onStart()
        if (Util.SDK_INT >= 24) {
            player.playWhenReady = true
        }
    }

    override fun onResume() {
        super.onResume()
        if (Util.SDK_INT < 24 || !::player.isInitialized) {
            player.playWhenReady = true
        }
    }

    override fun onPause() {
        super.onPause()
        if (Util.SDK_INT < 24) {
            player.playWhenReady = false
        }
    }

    override fun onStop() {
        super.onStop()
        if (Util.SDK_INT >= 24) {
            player.playWhenReady = false
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        player.release()
        handler.removeCallbacksAndMessages(null)
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
    }
}
