package com.ultrastream.ui.sheets

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.ultrastream.R
import com.ultrastream.databinding.SheetSeasonsBinding

class SeasonSelectBottomSheet(
    private val seasons: List<Int>,
    private val currentSeason: Int,
    private val onSeasonSelected: (Int) -> Unit
) : BottomSheetDialogFragment() {

    private var _binding: SheetSeasonsBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = SheetSeasonsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        binding.rvSeasons.layoutManager = LinearLayoutManager(requireContext())
        binding.rvSeasons.adapter = object : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
            override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
                val view = LayoutInflater.from(parent.context)
                    .inflate(android.R.layout.simple_list_item_1, parent, false)
                return object : RecyclerView.ViewHolder(view) {}
            }

            override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
                val season = seasons[position]
                val tv = holder.itemView as android.widget.TextView
                tv.text = "Season $season"
                tv.setBackgroundColor(
                    if (season == currentSeason) {
                        resources.getColor(android.R.color.holo_blue_light)
                    } else {
                        android.R.color.transparent
                    }
                )
                tv.setOnClickListener {
                    if (season != currentSeason) {
                        onSeasonSelected(season)
                        dismiss()
                    }
                }
            }

            override fun getItemCount(): Int = seasons.size
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
