package com.example.mindflip_native.repositories

import com.example.mindflip_native.models.Category

interface ICategoriesRepository {
    fun getAllCategories(): List<Category>
    fun getCategoryById(id: Int): Category?
    fun addCategory(category: Category): Category
    fun deleteCategory(id: Int)
    fun updateCategory(category: Category)
    fun incFlashcardCount(id: Int)
    fun decFlashcardCount(id: Int)
}