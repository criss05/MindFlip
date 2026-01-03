package com.example.mindflip_native.repositories

import com.example.mindflip_native.models.Category

class CategoriesRepository : ICategoriesRepository{
    private val categories = mutableListOf<Category>()
    private var lastId = 0
    init {
        seedCategories()
    }

    private fun seedCategories() {
        addCategory(Category(localId = -1, name = "Mathematics", flashcardCount = 3))
        addCategory(Category(localId = -1, name = "Databases", flashcardCount = 3))
        addCategory(Category(localId = -1, name = "Algorithms", flashcardCount = 3))
    }

    override fun getAllCategories(): List<Category> = categories.toList()

    override fun getCategoryById(id: Int): Category? {
        return categories.find{ it.localId == id }
    }

    override fun addCategory(category: Category): Category {
        val copyCategory = category.copy(localId = lastId++)
        categories.add(copyCategory)
        return copyCategory
    }

    override fun deleteCategory(id: Int) {
        categories.removeIf { it.localId == id }
    }

    override fun updateCategory(category: Category) {
        val index = categories.indexOfFirst { it.localId == category.localId }
        if (index != -1) categories[index] = category
    }

    override fun incFlashcardCount(id: Int) {
        val category = getCategoryById(id)
        val newCount = category!!.flashcardCount + 1;
        category.let {
            val updated = it.copy(flashcardCount = newCount)
            updateCategory(updated)
        }
    }

    override fun decFlashcardCount(id: Int) {
        val category = getCategoryById(id)
        val newCount = category!!.flashcardCount - 1;
        category.let {
            val updated = it.copy(flashcardCount = newCount)
            updateCategory(updated)
        }
    }
}