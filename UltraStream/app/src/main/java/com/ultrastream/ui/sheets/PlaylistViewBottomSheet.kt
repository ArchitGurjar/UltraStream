// app/src/main/java/com/ultrastream/ui/sheets/PlaylistViewBottomSheet.kt
package com.ultrastream.ui.sheets

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.lifecycle.lifecycleScope
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.ultrastream.UltraStreamApplication
import com.ultrastream.data.models.PlaylistEpisode
import com.ultrastream.data.models.SmartPlaylist
import com.ultrastream.databinding.SheetPlaylistViewBinding
import com.ultrastream.utils.LinkVerifier
import com.ultrastream.utils.NetworkUtils
import kotlinx.coroutines.*

class PlaylistViewBottomSheet(
    private val playlist: SmartPlaylist
) : BottomSheetDialogFragment() {

    private var _binding: SheetPlaylistViewBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = SheetPlaylistViewBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        binding.playlistTitle.text = "${playlist.metaName} - S${playlist.season}"
        renderEpisodes()
    }

    private fun renderEpisodes() {
        binding.episodesContainer.removeAllViews()
        for (ep in playlist.episodes) {
            val itemView = layoutInflater.inflate(android.R.layout.simple_list_item_2, binding.episodesContainer, false)
            val text1 = itemView.findViewById<android.widget.TextView>(android.R.id.text1)
            val text2 = itemView.findViewById<android.widget.TextView>(android.R.id.text2)
            text1.text = "E${ep.epNum} - ${ep.epName}"
            if (ep.stream != null && !ep.isMissing) {
                text2.text = "✅ Ready (${ep.stream.addonName})"
                text2.setTextColor(requireContext().getColor(android.R.color.holo_green_light))
                itemView.setOnClickListener {
                    // Play
                    val actionSheet = StreamActionBottomSheet(ep.stream!!, ep.title)
                    actionSheet.show(parentFragmentManager, "stream_action")
                }
            } else {
                text2.text = "❌ Missing - Tap to retry or manual pick"
                text2.setTextColor(requireContext().getColor(android.R.color.holo_red_light))
                itemView.setOnClickListener {
                    // Retry or manual
                    showRetryOptions(ep)
                }
            }
            binding.episodesContainer.addView(itemView)
        }
    }

    private fun showRetryOptions(ep: PlaylistEpisode) {
        // Dialog with retry and manual pick
        val options = arrayOf("Auto Retry", "Manual Pick")
        androidx.appcompat.app.AlertDialog.Builder(requireContext())
            .setTitle("Episode ${ep.epNum}")
            .setItems(options) { _, which ->
                when (which) {
                    0 -> retryEpisode(ep)
                    1 -> manualPick(ep)
                }
            }
            .show()
    }

    private fun retryEpisode(ep: PlaylistEpisode) {
        Toast.makeText(requireContext(), "Retrying...", Toast.LENGTH_SHORT).show()
        lifecycleScope.launch(Dispatchers.IO) {
            val fullId = "${playlist.metaId}:${playlist.season}:${ep.epNum}"
            val addons = UltraStreamApplication.instance.repository.getEnabledAddons()
            for (addon in addons) {
                val streams = NetworkUtils.fetchStreams(fullId, "series")
                val valid = streams.filter { it.url != null }
                if (valid.isNotEmpty()) {
                    // Verify first link
                    val link = valid.first().url!!
                    val isAlive = LinkVerifier.verify(link)
                    if (isAlive) {
                        // Update playlist
                        val updatedEp = ep.copy(stream = valid.first(), isMissing = false)
                        val updatedEpisodes = playlist.episodes.map { if (it.epNum == ep.epNum) updatedEp else it }
                        val updatedPlaylist = playlist.copy(episodes = updatedEpisodes)
                        UltraStreamApplication.instance.repository.updatePlaylist(updatedPlaylist)
                        withContext(Dispatchers.Main) {
                            renderEpisodes()
                            Toast.makeText(requireContext(), "Episode updated with working stream", Toast.LENGTH_SHORT).show()
                        }
                        return@launch
                    }
                }
            }
            withContext(Dispatchers.Main) {
                Toast.makeText(requireContext(), "No working stream found", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun manualPick(ep: PlaylistEpisode) {
        // Open stream bottom sheet for this episode
        val sheet = StreamBottomSheet(playlist.metaId, "series", com.ultrastream.data.models.Video(
            season = playlist.season,
            episode = ep.epNum,
            name = ep.epName
        ))
        sheet.show(parentFragmentManager, "manual_pick")
        dismiss()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
