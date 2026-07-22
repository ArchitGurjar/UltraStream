# Add project specific ProGuard rules here.

# Keep ExoPlayer classes
-keep class com.google.android.exoplayer2.** { *; }
-keep interface com.google.android.exoplayer2.** { *; }

# Keep Retrofit
-keep class retrofit2.** { *; }
-keep interface retrofit2.** { *; }

# Keep Gson
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep Room
-keep class androidx.room.** { *; }
-keep class * extends androidx.room.RoomDatabase

# Keep models
-keep class com.ultrastream.data.models.** { *; }

# Keep Parcelable
-keep class * implements android.os.Parcelable {
    public static final *** CREATOR;
}

# Keep Serializable
-keep class * implements java.io.Serializable

# Keep annotations
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature

# For FileProvider
-keep class androidx.core.content.FileProvider { *; }

# For ExoPlayer HLS/DASH extensions
-keep class com.google.android.exoplayer2.ext.** { *; }

# OkHttp
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
