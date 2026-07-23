package com.ultrastream.ui.search

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.GridLayoutManager
import com.ultrastream.databinding.FragmentSearchBinding
import com.ultrastream.ui.adapters.PosterAdapter

class SearchFragment : Fragment() {

    private var _binding: FragmentSearchBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?
    ): View {
        _binding = FragmentSearchBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        try {
            // Nullable context की जगह requireContext() का इस्तेमाल (क्रैश रोकेगा)
            binding.rvSearchResults.layoutManager = GridLayoutManager(requireContext(), 2)
            val adapter = PosterAdapter { /* navigate */ }
            binding.rvSearchResults.adapter = adapter
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
