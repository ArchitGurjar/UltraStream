package com.ultrastream.ui.sheets

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.core.content.FileProvider
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.ultrastream.R
import com.ultrastream.databinding.SheetM3uActionsBinding
import com.ultrastream.player.PlayerActivity
import com.ultrastream.utils.M3UParser
import java.io.File
import java.io.FileOutputStream

class M3UActionBottomSheet(
    private val m3uContent: String,
    private val fileName: String = "playlist.m3u"
) : BottomSheetDialogFragment() {

    private var _binding: SheetM3uActionsBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = SheetM3uActionsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val entries = M3UParser.parse(m3uContent)
        binding.tvM3uDesc.text = "${entries.size} track${if (entries.size > 1) "s" else ""} • Choose an action below"
        binding.btnClose.setOnClickListener { dismiss() }

        binding.btnExportM3u.setOnClickListener {
            exportM3U()
            dismiss()
        }
        binding.btnPlayM3u.setOnClickListener {
            playM3U()
            dismiss()
        }
    }

    private fun exportM3U() {
        try {
            val outputFile = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                File(requireContext().filesDir, fileName)
            } else {
                File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS), fileName)
            }
            FileOutputStream(outputFile).use { fos ->
                fos.write(m3uContent.toByteArray())
            }

            val uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                FileProvider.getUriForFile(
                    requireContext(),
                    requireContext().packageName + ".fileprovider",
                    outputFile
                )
            } else {
                Uri.fromFile(outputFile)
            }

            val shareIntent = Intent(Intent.ACTION_SEND).apply {
                type = "audio/x-mpegurl"
                putExtra(Intent.EXTRA_STREAM, uri)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            startActivity(Intent.createChooser(shareIntent, "Export M3U"))
            Toast.makeText(requireContext(), "M3U saved: ${outputFile.absolutePath}", Toast.LENGTH_SHORT).show()
        } catch (e: Exception) {
            Toast.makeText(requireContext(), "Export failed: ${e.message}", Toast.LENGTH_LONG).show()
        }
    }

    private fun playM3U() {
        val entries = M3UParser.parse(m3uContent)
        if (entries.isEmpty()) {
            Toast.makeText(requireContext(), "No playable entries found", Toast.LENGTH_SHORT).show()
            return
        }
        val firstEntry = entries.first()
        val intent = Intent(requireContext(), PlayerActivity::class.java).apply {
            putExtra(PlayerActivity.EXTRA_MEDIA_URL, firstEntry.url)
            putExtra(PlayerActivity.EXTRA_MEDIA_TITLE, firstEntry.title)
        }
        startActivity(intent)
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
