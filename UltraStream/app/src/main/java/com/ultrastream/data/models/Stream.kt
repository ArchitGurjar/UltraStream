package com.ultrastream.data.models

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class Stream(
    val url: String? = null,
    val streamUrl: String? = null,
    val externalUrl: String? = null,
    val title: String? = null,
    val name: String? = null,
    val description: String? = null,
    val infoHash: String? = null,
    val subtitles: List<Subtitle>? = null,
    val addonName: String? = null,
    val quality: String? = null,
    val size: String? = null,
    val seeds: Int? = null,
    val languages: List<String>? = null,
    val isLive: Boolean = false
) : Parcelable

@Parcelize
data class Subtitle(
    val url: String,
    val lang: String = "en",
    val name: String? = null,
    val file: String? = null
) : Parcelable
