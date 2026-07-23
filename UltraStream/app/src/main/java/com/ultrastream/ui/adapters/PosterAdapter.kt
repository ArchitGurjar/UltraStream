// app/src/main/java/com/ultrastream/ui/adapters/PosterAdapter.kt
package com.ultrastream.ui.adapters

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.ultrastream.databinding.ItemPosterBinding
import com.ultrastream.data.models.MetaItem

class PosterAdapter(
    private val onItemClick: (MetaItem) -> Unit
) : RecyclerView.Adapter<PosterAdapter.PosterViewHolder>() {

    private var items: List<MetaItem> = emptyList()

    fun submitList(newItems: List<MetaItem>) {
        items = newItems
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): PosterViewHolder {
        val binding = ItemPosterBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return PosterViewHolder(binding)
    }

    override fun onBindViewHolder(holder: PosterViewHolder, position: Int) {
        holder.bind(items[position])
    }

    override fun getItemCount(): Int = items.size

    inner class PosterViewHolder(
        private val binding: ItemPosterBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(item: MetaItem) {
            Glide.with(binding.root.context)
                .load(item.poster ?: item.background)
                .placeholder(android.R.drawable.ic_menu_gallery)
                .into(binding.posterImage)

            binding.tvTitle.text = item.name

            if (item.imdbRating != null && item.imdbRating!! > 0f) {
                binding.tvRating.text = "⭐ ${item.imdbRating}"
                binding.tvRating.visibility = android.view.View.VISIBLE
            } else {
                binding.tvRating.visibility = android.view.View.GONE
            }

            if (item.type.isNotEmpty()) {
                binding.tvType.text = item.type.uppercase()
                binding.tvType.visibility = android.view.View.VISIBLE
            } else {
                binding.tvType.visibility = android.view.View.GONE
            }

            if (item.year != null && item.year!! > 0) {
                binding.tvYear.text = item.year.toString()
                binding.tvYear.visibility = android.view.View.VISIBLE
            } else {
                binding.tvYear.visibility = android.view.View.GONE
            }

            // Progress - we'll handle this separately

            binding.root.setOnClickListener {
                onItemClick(item)
            }
        }
    }
}
