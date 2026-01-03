package com.example.mindflip_native.models

import java.time.Instant

data class Category(
    val localId: Int,
    val serverId: Int? = null,
    val name: String,
    val flashcardCount: Int,
    val deleted: Boolean? = false,
    val pendingSync: Boolean? = false,
    val lastModified: Long = Instant.now().toEpochMilli()
);
