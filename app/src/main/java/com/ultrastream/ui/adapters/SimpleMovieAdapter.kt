package com.ultrastream.ui.adapters

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.ultrastream.R
import com.ultrastream.ui.home.MetaItem

class SimpleMovieAdapter(private val movies: List<MetaItem>) : RecyclerView.Adapter<SimpleMovieAdapter.MovieViewHolder>() {

    class MovieViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val title: TextView = view.findViewById(R.id.home_poster_title)
        val img: ImageView = view.findViewById(R.id.home_poster_img)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MovieViewHolder {
        // असली फिक्स: यहाँ R.id की जगह R.layout कर दिया गया है
        val view = LayoutInflater.from(parent.context).inflate(R.layout.item_home_movie, parent, false)
        return MovieViewHolder(view)
    }

    override fun onBindViewHolder(holder: MovieViewHolder, position: Int) {
        val movie = movies[position]
        holder.title.text = movie.name
        if (!movie.poster.isNullOrEmpty()) {
            Glide.with(holder.img.context)
                .load(movie.poster)
                .into(holder.img)
        }
    }

    override fun getItemCount() = movies.size
}
