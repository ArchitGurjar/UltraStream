package com.ultrastream.ui.library

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.LinearLayoutManager
import com.ultrastream.databinding.FragmentLibraryBinding
import com.ultrastream.ui.adapters.ContinueWatchingAdapter
import com.ultrastream.ui.adapters.PosterAdapter
import com.ultrastream.ui.adapters.SmartPlaylistAdapter

class LibraryFragment : Fragment() {

    private var _binding: FragmentLibraryBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentLibraryBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        setupSmartPlaylists()
        setupHistory()
        setupWatchlist()
        setupLibraryGrid()
    }

    private fun setupSmartPlaylists() {
        val adapter = SmartPlaylistAdapter(
            onItemClick = { /* open playlist */ },
            onM3UClick = { /* show M3U sheet */ },
            onDeleteClick = { /* delete playlist */ }
        )
        binding.rvSmartPlaylists.layoutManager = LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false)
        binding.rvSmartPlaylists.adapter = adapter
    }

    private fun setupHistory() {
        val adapter = ContinueWatchingAdapter { /* navigate */ }
        binding.rvLibHistory.layoutManager = LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false)
        binding.rvLibHistory.adapter = adapter
    }

    private fun setupWatchlist() {
        val adapter = PosterAdapter { /* navigate */ }
        binding.rvWatchlist.layoutManager = GridLayoutManager(context, 2)
        binding.rvWatchlist.adapter = adapter
    }

    private fun setupLibraryGrid() {
        val adapter = PosterAdapter { /* navigate */ }
        binding.rvLibraryGrid.layoutManager = GridLayoutManager(context, 2)
        binding.rvLibraryGrid.adapter = adapter
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
