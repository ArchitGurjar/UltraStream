package com.ultrastream.ui.adapters

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.ultrastream.R
import com.ultrastream.databinding.ItemRecommendedAddonBinding

data class RecommendedAddon(
    val name: String,
    val desc: String,
    val url: String,
    var isInstalled: Boolean = false
)

class RecommendedAddonAdapter(
    private val onInstallClick: (RecommendedAddon) -> Unit
) : RecyclerView.Adapter<RecommendedAddonAdapter.AddonViewHolder>() {

    private var items: List<RecommendedAddon> = emptyList()

    fun submitList(newItems: List<RecommendedAddon>) {
        items = newItems
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): AddonViewHolder {
        val binding = ItemRecommendedAddonBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return AddonViewHolder(binding)
    }

    override fun onBindViewHolder(holder: AddonViewHolder, position: Int) {
        holder.bind(items[position])
    }

    override fun getItemCount(): Int = items.size

    inner class AddonViewHolder(
        private val binding: ItemRecommendedAddonBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(addon: RecommendedAddon) {
            binding.addonName.text = addon.name
            binding.addonDesc.text = addon.desc

            binding.btnInstall.text = if (addon.isInstalled) "Installed" else "Install"
            binding.btnInstall.isEnabled = !addon.isInstalled
            binding.btnInstall.backgroundTintList = if (addon.isInstalled) {
                android.content.res.ColorStateList.valueOf(
                    binding.root.context.getColor(R.color.accent_green)
                )
            } else {
                android.content.res.ColorStateList.valueOf(
                    binding.root.context.getColor(R.color.accent_blue)
                )
            }

            binding.btnInstall.setOnClickListener {
                if (!addon.isInstalled) {
                    onInstallClick(addon)
                }
            }
        }
    }
}
