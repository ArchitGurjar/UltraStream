package com.ultrastream.ui.sheets

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.ultrastream.R
import com.ultrastream.data.models.Stream
import com.ultrastream.databinding.SheetStreamActionBinding
import com.ultrastream.player.PlayerActivity

class StreamActionBottomSheet(
    private val stream: Stream,
    private val title: String
) : BottomSheetDialogFragment() {

    private var _binding: SheetStreamActionBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = SheetStreamActionBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupActions()
    }

    private fun setupActions() {
        binding.btnPlayExternal.setOnClickListener {
            val url = stream.url ?: stream.streamUrl ?: stream.externalUrl
            if (url.isNullOrEmpty()) { showToast("No URL available"); return@setOnClickListener }
            val intent = Intent(requireContext(), PlayerActivity::class.java).apply {
                putExtra(PlayerActivity.EXTRA_MEDIA_URL, url)
                putExtra(PlayerActivity.EXTRA_MEDIA_TITLE, title)
                putExtra(PlayerActivity.EXTRA_IS_LIVE, stream.isLive)
            }
            startActivity(intent)
            dismiss()
        }

        binding.btnDownload.setOnClickListener {
            val url = stream.url ?: stream.streamUrl
            if (url.isNullOrEmpty()) { showToast("No direct download link"); return@setOnClickListener }
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
            startActivity(Intent.createChooser(intent, "Open with..."))
            dismiss()
        }

        binding.btnCopyMagnet.setOnClickListener {
            var magnet: String? = null
            if (!stream.infoHash.isNullOrEmpty()) {
                magnet = "magnet:?xt=urn:btih:${stream.infoHash}"
                stream.name?.let { magnet += "&dn=${Uri.encode(it)}" }
            } else if (stream.url?.startsWith("magnet:") == true) {
                magnet = stream.url
            } else if (stream.externalUrl?.startsWith("magnet:") == true) {
                magnet = stream.externalUrl
            }
            if (magnet.isNullOrEmpty()) { showToast("No magnet link available"); return@setOnClickListener }
            copyToClipboard(magnet)
            showToast("Magnet copied!")
            dismiss()
        }

        binding.btnCopyUrl.setOnClickListener {
            val url = stream.url ?: stream.streamUrl ?: stream.externalUrl
            if (url.isNullOrEmpty()) { showToast("No URL available"); return@setOnClickListener }
            copyToClipboard(url)
            showToast("URL copied!")
            dismiss()
        }

        binding.btnSubtitles.setOnClickListener {
            val subs = stream.subtitles
            if (subs.isNullOrEmpty()) { showToast("No subtitles found"); return@setOnClickListener }
            val sheet = SubtitleBottomSheet(subs)
            sheet.show(parentFragmentManager, "subtitles")
            dismiss()
        }

        binding.btnExportM3u.setOnClickListener {
            val url = stream.url ?: stream.streamUrl ?: stream.externalUrl
            if (url.isNullOrEmpty() || url.startsWith("magnet:")) {
                showToast("Cannot export magnet as M3U")
                return@setOnClickListener
            }
            val m3uContent = "#EXTM3U\n#EXTINF:-1,$title\n$url"
            val sheet = M3UActionBottomSheet(m3uContent, "$title.m3u")
            sheet.show(parentFragmentManager, "m3u_actions")
            dismiss()
        }
    }

    private fun copyToClipboard(text: String) {
        val clipboard = requireContext().getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = ClipData.newPlainText("URL", text)
        clipboard.setPrimaryClip(clip)
    }

    private fun showToast(message: String) {
        Toast.makeText(requireContext(), message, Toast.LENGTH_SHORT).show()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
