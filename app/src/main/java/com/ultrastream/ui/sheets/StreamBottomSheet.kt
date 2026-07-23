package com.ultrastream.ui.sheets

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.ultrastream.databinding.SheetStreamsBinding
import com.ultrastream.data.models.Stream
import com.ultrastream.data.models.Video
import com.ultrastream.ui.adapters.StreamAdapter
import com.ultrastream.utils.EpisodeMatcher
import com.ultrastream.network.NetworkUtils
import kotlinx.coroutines.*

class StreamBottomSheet(
    private val metaId: String,
    private val metaType: String,
    private val episode: Video? = null
) : BottomSheetDialogFragment() {

    private var _binding: SheetStreamsBinding? = null
    private val binding get() = _binding!!

    private lateinit var adapter: StreamAdapter
    private var isFetching = false

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = SheetStreamsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val title = episode?.let {
            "S${it.season.toString().padStart(2, '0')}E${it.episode.toString().padStart(2, '0')}"
        } ?: "Available Streams"

        binding.sheetTitle.text = title
        binding.btnClose.setOnClickListener { dismiss() }

        // CRITICAL FIX: Make sure stream click actually opens the options sheet!
        adapter = StreamAdapter { stream ->
            val actionSheet = StreamActionBottomSheet(stream, title)
            actionSheet.show(parentFragmentManager, "stream_action")
        }
        
        binding.rvStreams.layoutManager = LinearLayoutManager(requireContext())
        binding.rvStreams.adapter = adapter

        fetchStreams()
    }

    private fun fetchStreams() {
        if (isFetching) return
        isFetching = true

        binding.loadingSpinner.visibility = View.VISIBLE
        binding.tvNoStreams.visibility = View.GONE

        val id = episode?.let { "$metaId:${it.season}:${it.episode}" } ?: metaId

        lifecycleScope.launch(Dispatchers.IO) {
            try {
                val result = NetworkUtils.fetchStreams(id, metaType)
                val filtered = if (episode != null) {
                    result.filter { EpisodeMatcher.isValidEpisodeStream(it, episode.season, episode.episode) }
                } else {
                    result
                }
                withContext(Dispatchers.Main) {
                    if (_binding == null) return@withContext
                    adapter.submitList(filtered)
                    binding.loadingSpinner.visibility = View.GONE
                    if (filtered.isEmpty()) {
                        binding.tvNoStreams.visibility = View.VISIBLE
                        binding.tvNoStreams.text = "No streams found. Check addons."
                    }
                    isFetching = false
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    if (_binding == null) return@withContext
                    binding.loadingSpinner.visibility = View.GONE
                    binding.tvNoStreams.visibility = View.VISIBLE
                    binding.tvNoStreams.text = "Error fetching streams."
                    isFetching = false
                }
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
