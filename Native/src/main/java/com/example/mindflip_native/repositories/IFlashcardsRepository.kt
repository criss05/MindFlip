package com.example.mindflip_native.repositories

import com.example.mindflip_native.models.Flashcard

interface IFlashcardsRepository {
    fun getAllFlashcards(categoryId: Int): List<Flashcard>
    fun getFlashcardById(id: Int): Flashcard?
    fun addFlashcard(flashcard: Flashcard): Flashcard
    fun deleteFlashcard(id: Int)
    fun updateFlashcard(flashcard: Flashcard): Flashcard
}