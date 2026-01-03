package com.example.mindflip_native.models
import com.example.mindflip_native.assets.Difficulty
import java.time.Instant

data class Flashcard(
    val localId: Int,
    val serverId: Int?=null,
    val question: String,
    val answer: String,
    val difficulty: Difficulty,
    val categoryId: Int,
    val pendingSync: Boolean? = false,
    val deleted: Boolean? = false,
    val lastModified: Long = Instant.now().toEpochMilli()
)
