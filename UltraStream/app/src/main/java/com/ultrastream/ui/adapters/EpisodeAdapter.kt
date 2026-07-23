package com.ultrastream.ui.adapters

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.ultrastream.R
import com.ultrastream.databinding.ItemEpisodeBinding
import com.ultrastream.data.models.Video

class EpisodeAdapter(
    private val onItemClick: (Video) -> Unit,
    private val onMarkWatched: (Video) -> Unit
) : RecyclerView.Adapter<EpisodeAdapter.EpisodeViewHolder>() {

    private var items: List<Video> = emptyList()
    private var progressMap: Map<String, Float> = emptyMap()

    fun submitList(newItems: List<Video>, progress: Map<String, Float> = emptyMap()) {
        items = newItems
        progressMap = progress
        notifyDataSetChanged()
    }

    fun updateProgress(progress: Map<String, Float>) {
        progressMap = progress
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): EpisodeViewHolder {
        val binding = ItemEpisodeBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return EpisodeViewHolder(binding, onItemClick, onMarkWatched)
    }

    override fun onBindViewHolder(holder: EpisodeViewHolder, position: Int) {
        holder.bind(items[position], progressMap)
    }

    override fun getItemCount(): Int = items.size

    inner class EpisodeViewHolder(
        private val binding: ItemEpisodeBinding,
        private val onItemClick: (Video) -> Unit,
        private val onMarkWatched: (Video) -> Unit
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(episode: Video, progressMap: Map<String, Float>) {
            Glide.with(binding.root.context)
                .load(episode.thumbnail)
                .placeholder(R.drawable.placeholder_poster)
                .into(binding.epThumb)

            val episodeKey = "S${episode.season}E${episode.episode}"
            binding.epBadge.text = "S${episode.season.toString().padStart(2, '0')}E${episode.episode.toString().padStart(2, '0')}"
            binding.epTitle.text = episode.name ?: episode.title ?: "Episode ${episode.episode}"
            binding.epDesc.text = episode.description ?: "No description available."

            // Progress and watched status
            val progress = progressMap[episodeKey]
            if (progress != null && progress >= 100f) {
                binding.epWatched.visibility = View.VISIBLE
                binding.epWatched.text = "✅ Watched"
                binding.epWatched.setOnClickListener { /* already watched */ }
            } else if (progress != null && progress > 0f) {
                binding.epWatched.visibility = View.VISIBLE
                binding.epWatched.text = "⏳ ${progress.toInt()}%"
                binding.epWatched.setOnClickListener {
                    onMarkWatched(episode)
                }
            } else {
                binding.epWatched.visibility = View.GONE
            }

            // Progress bar
            if (progress != null && progress > 0f && progress < 100f) {
                binding.epProgress.visibility = View.VISIBLE
                binding.epProgress.progress = progress.toInt()
            } else {
                binding.epProgress.visibility = View.GONE
            }

            binding.root.setOnClickListener {
                onItemClick(episode)
            }
        }
    }
}
