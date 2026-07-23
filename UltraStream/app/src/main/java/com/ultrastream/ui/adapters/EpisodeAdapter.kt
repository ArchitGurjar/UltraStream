package com.ultrastream.ui.adapters

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.ultrastream.databinding.ItemEpisodeBinding
import com.ultrastream.data.models.Video

class EpisodeAdapter(
    private val onItemClick: (Video) -> Unit
) : RecyclerView.Adapter<EpisodeAdapter.EpisodeViewHolder>() {

    private var items: List<Video> = emptyList()
    private var watchedEpisodes: Set<String> = emptySet()

    fun submitList(newItems: List<Video>, watched: Set<String> = emptySet()) {
        items = newItems
        watchedEpisodes = watched
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): EpisodeViewHolder {
        val binding = ItemEpisodeBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return EpisodeViewHolder(binding)
    }

    override fun onBindViewHolder(holder: EpisodeViewHolder, position: Int) {
        holder.bind(items[position])
    }

    override fun getItemCount(): Int = items.size

    inner class EpisodeViewHolder(
        private val binding: ItemEpisodeBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(episode: Video) {
            Glide.with(binding.root.context)
                .load(episode.thumbnail)
                .placeholder(com.ultrastream.R.drawable.placeholder_poster)
                .into(binding.epThumb)

            binding.epBadge.text = "S${episode.season.toString().padStart(2, '0')}E${episode.episode.toString().padStart(2, '0')}"
            binding.epTitle.text = episode.name ?: episode.title ?: "Episode ${episode.episode}"
            binding.epDesc.text = episode.description ?: "No description available."

            val episodeKey = "S${episode.season}E${episode.episode}"
            if (watchedEpisodes.contains(episodeKey)) {
                binding.epWatched.visibility = android.view.View.VISIBLE
                binding.epWatched.text = "✅ Watched"
            } else {
                binding.epWatched.visibility = android.view.View.GONE
            }

            binding.root.setOnClickListener {
                onItemClick(episode)
            }
        }
    }
}
