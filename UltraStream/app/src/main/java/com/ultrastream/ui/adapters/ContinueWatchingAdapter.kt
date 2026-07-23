// app/src/main/java/com/ultrastream/ui/adapters/ContinueWatchingAdapter.kt
package com.ultrastream.ui.adapters

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.ultrastream.databinding.ItemCwBinding
import com.ultrastream.data.models.WatchHistory
import com.ultrastream.data.models.WatchProgress

class ContinueWatchingAdapter(
    private val onItemClick: (WatchHistory) -> Unit
) : RecyclerView.Adapter<ContinueWatchingAdapter.CWViewHolder>() {

    private var items: List<WatchHistory> = emptyList()
    private var progressMap: Map<String, WatchProgress> = emptyMap()

    fun submitList(newItems: List<WatchHistory>, progress: Map<String, WatchProgress> = emptyMap()) {
        items = newItems
        progressMap = progress
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): CWViewHolder {
        val binding = ItemCwBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return CWViewHolder(binding)
    }

    override fun onBindViewHolder(holder: CWViewHolder, position: Int) {
        holder.bind(items[position])
    }

    override fun getItemCount(): Int = items.size

    inner class CWViewHolder(
        private val binding: ItemCwBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(item: WatchHistory) {
            Glide.with(binding.root.context)
                .load(item.poster)
                .placeholder(android.R.drawable.ic_menu_gallery)
                .into(binding.cwThumb)

            binding.cwTitle.text = item.name
            binding.cwMeta.text = item.type.uppercase()

            val progress = progressMap[item.id]
            if (progress != null && progress.percent > 0f) {
                binding.cwProgress.progress = progress.percent.toInt()
                binding.cwProgress.visibility = android.view.View.VISIBLE
            } else {
                binding.cwProgress.visibility = android.view.View.GONE
            }

            binding.root.setOnClickListener {
                onItemClick(item)
            }
        }
    }
}
