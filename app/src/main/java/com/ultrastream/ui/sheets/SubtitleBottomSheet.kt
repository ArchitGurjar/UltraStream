// app/src/main/java/com/ultrastream/ui/sheets/SubtitleBottomSheet.kt
package com.ultrastream.ui.sheets

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.ultrastream.R
import com.ultrastream.data.models.Subtitle
import com.ultrastream.databinding.SheetSubtitlesBinding

class SubtitleBottomSheet(
    private val subtitles: List<Subtitle>
) : BottomSheetDialogFragment() {

    private var _binding: SheetSubtitlesBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = SheetSubtitlesBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        binding.rvSubtitles.layoutManager = LinearLayoutManager(requireContext())
        binding.rvSubtitles.adapter = SubtitleAdapter(subtitles) { subtitle ->
            downloadSubtitle(subtitle)
        }
    }

    private fun downloadSubtitle(subtitle: Subtitle) {
        val url = subtitle.url ?: subtitle.file
        if (url.isNullOrEmpty()) {
            Toast.makeText(requireContext(), "No subtitle URL available", Toast.LENGTH_SHORT).show()
            return
        }

        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
        startActivity(Intent.createChooser(intent, "Download subtitle"))
        dismiss()
    }

    inner class SubtitleAdapter(
        private val items: List<Subtitle>,
        private val onItemClick: (Subtitle) -> Unit
    ) : RecyclerView.Adapter<SubtitleAdapter.ViewHolder>() {

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
            val view = LayoutInflater.from(parent.context)
                .inflate(android.R.layout.simple_list_item_2, parent, false)
            return ViewHolder(view)
        }

        override fun onBindViewHolder(holder: ViewHolder, position: Int) {
            val item = items[position]
            holder.bind(item)
        }

        override fun getItemCount(): Int = items.size

        inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
            fun bind(subtitle: Subtitle) {
                val text1 = itemView.findViewById<android.widget.TextView>(android.R.id.text1)
                val text2 = itemView.findViewById<android.widget.TextView>(android.R.id.text2)

                val langName = try {
                    java.util.Locale(subtitle.lang).displayName
                } catch (e: Exception) {
                    subtitle.lang
                }

                text1.text = langName
                text2.text = subtitle.name ?: "Subtitle"

                itemView.setOnClickListener {
                    onItemClick(subtitle)
                }
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
