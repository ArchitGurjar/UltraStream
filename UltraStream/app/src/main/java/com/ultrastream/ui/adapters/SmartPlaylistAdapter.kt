package com.ultrastream.ui.adapters

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.ultrastream.R
import com.ultrastream.databinding.ItemSmartPlaylistBinding
import com.ultrastream.data.models.SmartPlaylist

class SmartPlaylistAdapter(
    private val onItemClick: (SmartPlaylist) -> Unit,
    private val onM3UClick: (SmartPlaylist) -> Unit,
    private val onDeleteClick: (SmartPlaylist) -> Unit
) : RecyclerView.Adapter<SmartPlaylistAdapter.PlaylistViewHolder>() {

    private var items: List<SmartPlaylist> = emptyList()

    fun submitList(newItems: List<SmartPlaylist>) {
        items = newItems
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): PlaylistViewHolder {
        val binding = ItemSmartPlaylistBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return PlaylistViewHolder(binding)
    }

    override fun onBindViewHolder(holder: PlaylistViewHolder, position: Int) {
        holder.bind(items[position])
    }

    override fun getItemCount(): Int = items.size

    inner class PlaylistViewHolder(
        private val binding: ItemSmartPlaylistBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(playlist: SmartPlaylist) {
            Glide.with(binding.root.context)
                .load(playlist.poster)
                .placeholder(com.ultrastream.R.drawable.placeholder_poster)
                .into(binding.playlistThumb)

            binding.playlistTitle.text = playlist.metaName
            binding.playlistMeta.text = "Season ${playlist.season} • ${playlist.addon}"

            val isComplete = playlist.fetched >= playlist.total
            binding.playlistStatus.text = if (isComplete) {
                "✅ Ready (${playlist.fetched}/${playlist.total})"
            } else {
                "⏳ Fetching (${playlist.fetched}/${playlist.total})"
            }
            binding.playlistStatus.setTextColor(
                binding.root.context.getColor(if (isComplete) R.color.accent_green else R.color.accent_gold)
            )

            val progress = if (playlist.total > 0) {
                (playlist.fetched.toFloat() / playlist.total * 100).toInt()
            } else 0
            binding.playlistProgress.progress = progress

            binding.btnM3u.setOnClickListener {
                onM3UClick(playlist)
            }

            binding.btnDeletePlaylist.setOnClickListener {
                onDeleteClick(playlist)
            }

            binding.root.setOnClickListener {
                onItemClick(playlist)
            }
        }
    }
}
