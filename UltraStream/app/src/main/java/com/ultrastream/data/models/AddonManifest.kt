// app/src/main/java/com/ultrastream/data/models/AddonManifest.kt
package com.ultrastream.data.models

data class AddonManifest(
    val id: String,
    val name: String,
    val version: String,
    val description: String? = null,
    val catalogs: List<CatalogItem> = emptyList(),
    val resources: List<String> = emptyList(),
    val types: List<String> = emptyList()
) {
    data class CatalogItem(
        val type: String,
        val id: String,
        val name: String
    )
}
