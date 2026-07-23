package com.ultrastream.ui.library

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.LinearLayoutManager
import com.ultrastream.R
import com.ultrastream.UltraStreamApplication
import com.ultrastream.databinding.FragmentLibraryBinding
import com.ultrastream.ui.adapters.ContinueWatchingAdapter
import com.ultrastream.ui.adapters.PosterAdapter
import com.ultrastream.ui.adapters.SmartPlaylistAdapter
import com.ultrastream.ui.details.DetailsActivity
import com.ultrastream.ui.sheets.M3UActionBottomSheet
import com.ultrastream.ui.sheets.PlaylistViewBottomSheet
import com.ultrastream.utils.M3UParser
import kotlinx.coroutines.launch

class LibraryFragment : Fragment() {

    private var _binding: FragmentLibraryBinding? = null
    private val binding get() = _binding!!
    private lateinit var viewModel: LibraryViewModel

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentLibraryBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        viewModel = androidx.lifecycle.ViewModelProvider(this).get(LibraryViewModel::class.java)

        setupSmartPlaylists()
        setupHistory()
        setupWatchlist()
        setupLibraryGrid()

        viewModel.loadAllData()
    }

    private fun setupSmartPlaylists() {
        val adapter = SmartPlaylistAdapter(
            onItemClick = { playlist ->
                val sheet = PlaylistViewBottomSheet(playlist)
                sheet.show(parentFragmentManager, "playlist_view")
            },
            onM3UClick = { playlist ->
                val m3u = M3UParser.generate(
                    playlist.episodes.map {
                        M3UParser.M3UEntry(
                            title = "${playlist.metaName} - S${playlist.season}E${it.epNum} ${it.epName}",
                            url = it.stream?.url ?: it.stream?.streamUrl ?: ""
                        )
                    }
                )
                val sheet = M3UActionBottomSheet(m3u, "${playlist.metaName}_S${playlist.season}.m3u")
                sheet.show(parentFragmentManager, "m3u_actions")
            },
            onDeleteClick = { playlist ->
                viewModel.deletePlaylist(playlist.id)
            }
        )
        binding.rvSmartPlaylists.layoutManager = LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false)
        binding.rvSmartPlaylists.adapter = adapter

        viewModel.playlists.observe(viewLifecycleOwner) { playlists ->
            adapter.submitList(playlists)
        }
    }

    private fun setupHistory() {
        val adapter = ContinueWatchingAdapter { history ->
            val intent = android.content.Intent(requireContext(), DetailsActivity::class.java)
            intent.putExtra(DetailsActivity.EXTRA_META_ID, history.id)
            intent.putExtra(DetailsActivity.EXTRA_META_TYPE, history.type)
            startActivity(intent)
        }
        binding.rvLibHistory.layoutManager = LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false)
        binding.rvLibHistory.adapter = adapter

        viewModel.history.observe(viewLifecycleOwner) { history ->
            adapter.submitList(history, viewModel.progressMap.value ?: emptyMap())
        }
        viewModel.progressMap.observe(viewLifecycleOwner) { progress ->
            adapter.submitList(viewModel.history.value ?: emptyList(), progress)
        }
    }

    private fun setupWatchlist() {
        val adapter = PosterAdapter { meta ->
            val intent = android.content.Intent(requireContext(), DetailsActivity::class.java)
            intent.putExtra(DetailsActivity.EXTRA_META_ID, meta.id)
            intent.putExtra(DetailsActivity.EXTRA_META_TYPE, meta.type)
            startActivity(intent)
        }
        binding.rvWatchlist.layoutManager = GridLayoutManager(context, 2)
        binding.rvWatchlist.adapter = adapter

        viewModel.watchlist.observe(viewLifecycleOwner) { watchlist ->
            adapter.submitList(watchlist)
        }
    }

    private fun setupLibraryGrid() {
        val adapter = PosterAdapter { meta ->
            val intent = android.content.Intent(requireContext(), DetailsActivity::class.java)
            intent.putExtra(DetailsActivity.EXTRA_META_ID, meta.id)
            intent.putExtra(DetailsActivity.EXTRA_META_TYPE, meta.type)
            startActivity(intent)
        }
        binding.rvLibraryGrid.layoutManager = GridLayoutManager(context, 2)
        binding.rvLibraryGrid.adapter = adapter

        viewModel.library.observe(viewLifecycleOwner) { library ->
            adapter.submitList(library)
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
