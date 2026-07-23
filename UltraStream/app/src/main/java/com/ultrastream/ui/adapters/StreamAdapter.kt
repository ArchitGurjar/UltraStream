// app/src/main/java/com/ultrastream/ui/adapters/StreamAdapter.kt
package com.ultrastream.ui.adapters

import android.content.res.ColorStateList
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.chip.Chip
import com.ultrastream.R
import com.ultrastream.databinding.ItemStreamBinding
import com.ultrastream.data.models.Stream
import com.ultrastream.utils.StreamParser

class StreamAdapter(
    private val onItemClick: (Stream) -> Unit
) : RecyclerView.Adapter<StreamAdapter.StreamViewHolder>() {

    private var items: List<Stream> = emptyList()

    fun submitList(newItems: List<Stream>) {
        items = newItems
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): StreamViewHolder {
        val binding = ItemStreamBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return StreamViewHolder(binding)
    }

    override fun onBindViewHolder(holder: StreamViewHolder, position: Int) {
        holder.bind(items[position])
    }

    override fun getItemCount(): Int = items.size

    inner class StreamViewHolder(
        private val binding: ItemStreamBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(stream: Stream) {
            binding.streamAddon.text = stream.addonName ?: "Unknown"

            val streamText = (stream.title ?: "") + "\n" + (stream.description ?: "") + "\n" + (stream.name ?: "")
            val parsed = StreamParser.parse(streamText)
            binding.streamTitle.text = parsed.cleanText

            val quality = parsed.quals.firstOrNull() ?: "Unknown"
            binding.streamQuality.text = quality

            binding.streamChipGroup.removeAllViews()
            var hasBadges = false

            if (parsed.hasHindi) {
                addChip("🇮🇳 Hindi", R.color.accent_orange)
                hasBadges = true
            }
            parsed.size?.let {
                addChip("💾 $it", R.color.accent_gold)
                hasBadges = true
            }
            parsed.seeds?.let {
                addChip("👤 $it", R.color.accent_green)
                hasBadges = true
            }
            if (parsed.isLive) {
                addChip("🔴 LIVE", R.color.accent_red)
                hasBadges = true
            }
            parsed.quals.forEach { qual ->
                if (qual != quality) {
                    addChip("📺 $qual", R.color.accent_blue)
                    hasBadges = true
                }
            }
            parsed.langs.forEach { lang ->
                if (!lang.contains("hindi", ignoreCase = true)) {
                    addChip("🗣 $lang", R.color.accent_purple)
                    hasBadges = true
                }
            }

            binding.streamChipGroup.visibility = if (hasBadges) View.VISIBLE else View.GONE

            binding.root.setOnClickListener {
                onItemClick(stream)
            }
        }

        private fun addChip(text: String, colorRes: Int) {
            val chip = Chip(binding.root.context).apply {
                this.text = text
                setChipBackgroundColorResource(android.R.color.transparent)
                setTextColor(binding.root.context.getColor(colorRes))
                chipStrokeColor = ColorStateList.valueOf(binding.root.context.getColor(colorRes))
                chipStrokeWidth = 1f
                textSize = 10f
                isClickable = false
            }
            binding.streamChipGroup.addView(chip)
        }
    }
}
