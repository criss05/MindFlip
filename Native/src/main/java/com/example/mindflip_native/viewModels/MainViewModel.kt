package com.example.mindflip_native.viewModels

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.example.mindflip_native.models.Category
import com.example.mindflip_native.models.Flashcard
import com.example.mindflip_native.repositories.CategoriesRepository
import com.example.mindflip_native.repositories.FlashcardsRepository

class MainViewModel : ViewModel() {
    private val categoriesRepo = CategoriesRepository()
    private val flashcardsRepo = FlashcardsRepository()

    private val _categories = MutableLiveData(categoriesRepo.getAllCategories())
    val categories: LiveData<List<Category>> get() = _categories

    private val _flashcards = MutableLiveData<List<Flashcard>>(emptyList())
    val flashcards: LiveData<List<Flashcard>> get() = _flashcards

    private val _selectedCategoryId = MutableLiveData<Int?>()
    val selectedCategoryId: LiveData<Int?> get() = _selectedCategoryId


    fun selectCategory(categoryId: Int) {
        _selectedCategoryId.value = categoryId
        _flashcards.value = flashcardsRepo.getAllFlashcards(categoryId)
    }

    fun addCategory(category: Category) {
        val newCategory = categoriesRepo.addCategory(category)
        _categories.value = _categories.value.orEmpty() + newCategory
    }

    fun deleteCategory(categoryId: Int) {
        // Delete all flashcards in that category
        val flashcardsToDelete = flashcardsRepo.getAllFlashcards(categoryId).toList()

        // Delete all flashcards safely
        flashcardsToDelete.forEach {
            flashcardsRepo.deleteFlashcard(it.localId)
        }

        categoriesRepo.deleteCategory(categoryId)
        _categories.value = _categories.value?.filterNot { it.localId == categoryId }

        // If currently selected, clear flashcards
        if (_selectedCategoryId.value == categoryId) {
            _flashcards.value = emptyList()
            _selectedCategoryId.value = null
        }
    }

    fun addFlashcard(flashcard: Flashcard) {
        val newFlashcard = flashcardsRepo.addFlashcard(flashcard)
        categoriesRepo.incFlashcardCount(flashcard.categoryId)

        _flashcards.value = _flashcards.value.orEmpty() + newFlashcard
        _categories.value = _categories.value?.map {
            if (it.localId == newFlashcard.categoryId)
                it.copy(flashcardCount = it.flashcardCount + 1)
            else it
        }
    }

    fun updateFlashcard(flashcard: Flashcard) {
        val newFlashcard = flashcardsRepo.updateFlashcard(flashcard)
        _flashcards.value = _flashcards.value?.map {
            if (it.localId == newFlashcard.localId) newFlashcard else it
        }
    }

    fun deleteFlashcard(flashcardId: Int, categoryId: Int) {
        flashcardsRepo.deleteFlashcard(flashcardId)
        categoriesRepo.decFlashcardCount(categoryId)

        _flashcards.value = _flashcards.value?.filterNot { it.localId == flashcardId }
        _categories.value = _categories.value?.map {
            if (it.localId == categoryId)
                it.copy(flashcardCount = it.flashcardCount - 1)
            else it
        }
    }
}
