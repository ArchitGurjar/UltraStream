package com.ultrastream.ui.home

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.GridLayoutManager
import com.ultrastream.databinding.FragmentHomeBinding
import com.ultrastream.ui.adapters.PosterAdapter
import com.ultrastream.ui.details.DetailsActivity

class HomeFragment : Fragment() {

    private var _binding: FragmentHomeBinding? = null
    private val binding get() = _binding!!
    private lateinit var viewModel: HomeViewModel
    private lateinit var adapter: PosterAdapter

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentHomeBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        viewModel = androidx.lifecycle.ViewModelProvider(this).get(HomeViewModel::class.java)

        adapter = PosterAdapter { meta ->
            val intent = android.content.Intent(requireContext(), DetailsActivity::class.java)
            intent.putExtra(DetailsActivity.EXTRA_META_ID, meta.id)
            intent.putExtra(DetailsActivity.EXTRA_META_TYPE, meta.type)
            startActivity(intent)
        }
        binding.rvHome.layoutManager = GridLayoutManager(requireContext(), 3)
        binding.rvHome.adapter = adapter

        viewModel.catalogs.observe(viewLifecycleOwner) { catalogs ->
            if (catalogs.isEmpty()) {
                Toast.makeText(requireContext(), "No catalogs found. Install addons.", Toast.LENGTH_LONG).show()
            }
            adapter.submitList(catalogs)
        }

        viewModel.loadCatalogs()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
