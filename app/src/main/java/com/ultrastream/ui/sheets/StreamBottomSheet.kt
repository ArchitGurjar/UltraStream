// app/src/main/java/com/ultrastream/ui/sheets/StreamBottomSheet.kt
package com.ultrastream.ui.sheets

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.google.android.material.snackbar.Snackbar
import com.ultrastream.databinding.SheetStreamsBinding
import com.ultrastream.data.models.Stream
import com.ultrastream.data.models.Video
import com.ultrastream.ui.adapters.StreamAdapter
import com.ultrastream.utils.NetworkUtils
import kotlinx.coroutines.*

class StreamBottomSheet(
    private val metaId: String,
    private val metaType: String,
    private val episode: Video? = null
) : BottomSheetDialogFragment() {

    private var _binding: SheetStreamsBinding? = null
    private val binding get() = _binding!!

    private lateinit var adapter: StreamAdapter
    private val streams = mutableListOf<Stream>()
    private var isFetching = false

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = SheetStreamsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val title = episode?.let {
            "S${it.season.toString().padStart(2, '0')}E${it.episode.toString().padStart(2, '0')}"
        } ?: "Streams"

        binding.sheetTitle.text = title

        setupAdapter()
        fetchStreams()
    }

    private fun setupAdapter() {
        adapter = StreamAdapter { stream ->
            // Open Stream Action Sheet
            val actionSheet = StreamActionBottomSheet(stream, getStreamTitle())
            actionSheet.show(parentFragmentManager, "stream_action")
        }
        binding.rvStreams.adapter = adapter
    }

    private fun getStreamTitle(): String {
        return episode?.let {
            "S${it.season.toString().padStart(2, '0')}E${it.episode.toString().padStart(2, '0')}"
        } ?: metaId
    }

    private fun fetchStreams() {
        if (isFetching) return
        isFetching = true

        binding.loadingSpinner.visibility = View.VISIBLE
        binding.tvNoStreams.visibility = View.GONE

        val id = if (episode != null) {
            "$metaId:${episode.season}:${episode.episode}"
        } else {
            metaId
        }

        CoroutineScope(Dispatchers.IO).launch {
            try {
                val result = NetworkUtils.fetchStreams(id, metaType)
                withContext(Dispatchers.Main) {
                    streams.clear()
                    streams.addAll(result)
                    adapter.submitList(streams)
                    binding.loadingSpinner.visibility = View.GONE
                    if (streams.isEmpty()) {
                        binding.tvNoStreams.visibility = View.VISIBLE
                    }
                    isFetching = false
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    binding.loadingSpinner.visibility = View.GONE
                    binding.tvNoStreams.visibility = View.VISIBLE
                    binding.tvNoStreams.text = "Error: ${e.message}"
                    isFetching = false
                }
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }

    companion object {
        private const val TAG = "StreamBottomSheet"
    }
}
