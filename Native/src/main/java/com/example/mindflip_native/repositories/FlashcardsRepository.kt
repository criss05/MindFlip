package com.example.mindflip_native.repositories

import com.example.mindflip_native.assets.Difficulty
import com.example.mindflip_native.models.Category
import com.example.mindflip_native.models.Flashcard

class FlashcardsRepository : IFlashcardsRepository{
    private val flashcards = mutableListOf<Flashcard>()
    private var lastId = 0
    init {
        seedFlashcards()
    }

    private fun seedFlashcards() {
        addFlashcard(Flashcard(localId = -1, question = "What is 2 + 2?", answer = "4", difficulty = Difficulty.EASY, categoryId = 0))
        addFlashcard(Flashcard(localId = -1, question = "Define derivative.", answer = "The rate of change of a function.", difficulty = Difficulty.MEDIUM, categoryId = 0))
        addFlashcard(Flashcard(localId = -1, question = "What is an integral?", answer = "The area under a curve.", difficulty = Difficulty.HARD, categoryId = 0))
        addFlashcard(Flashcard(localId = -1, question = "What is SQL?", answer = "Structured Query Language.", difficulty = Difficulty.EASY, categoryId = 1))
        addFlashcard(Flashcard(localId = -1, question = "Define normalization.", answer = "Process to reduce data redundancy.", difficulty = Difficulty.MEDIUM, categoryId = 1))
        addFlashcard(Flashcard(localId = -1, question = "What is a foreign key?", answer = "A field linking two tables.", difficulty = Difficulty.HARD, categoryId = 1))
        addFlashcard(Flashcard(localId = -1, question = "What is a binary search?", answer = "Search algorithm dividing data by half each step.", difficulty = Difficulty.EASY, categoryId = 2))
        addFlashcard(Flashcard(localId = -1, question = "Define Big O notation.", answer = "Describes time complexity of an algorithm.", difficulty = Difficulty.MEDIUM, categoryId = 2))
        addFlashcard(Flashcard(localId = -1, question = "What is dynamic programming?", answer = "Technique for optimizing recursive problems.", difficulty = Difficulty.HARD, categoryId = 2))
    }
    override fun getAllFlashcards(categoryId: Int): List<Flashcard> = flashcards.filter{it.categoryId == categoryId}.toList()

    override fun getFlashcardById(id: Int): Flashcard? {
        return flashcards.find{ it.localId == id }
    }

    override fun addFlashcard(flashcard: Flashcard): Flashcard {
        val copyFlashcard = flashcard.copy(localId = lastId++)
        flashcards.add(copyFlashcard)
        return copyFlashcard
    }

    override fun deleteFlashcard(id: Int) {
        flashcards.removeAll { it.localId == id }
    }

    override fun updateFlashcard(flashcard: Flashcard): Flashcard {
        val index = flashcards.indexOfFirst { it.localId == flashcard.localId }
        if (index != -1) flashcards[index] = flashcard
        return flashcards[index]
    }
}