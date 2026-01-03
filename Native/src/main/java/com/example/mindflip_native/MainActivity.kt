package com.example.mindflip_native

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.example.mindflip_native.viewModels.MainViewModel
import com.example.mindflip_native.views.AddCategoryScreen
import com.example.mindflip_native.views.AddFlashcardScreen
import com.example.mindflip_native.views.CategoriesScreen
import com.example.mindflip_native.views.EditFlashcardScreen
import com.example.mindflip_native.views.FlashcardsScreen
import com.example.mindflip_native.views.PracticeScreen

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            val mainViewModel: MainViewModel = viewModel() // Single instance shared in Compose

            val navController = rememberNavController()
            NavHost(navController = navController, startDestination = "categories") {
                composable("categories") {
                    CategoriesScreen(
                        viewModel = mainViewModel,
                        onAddCategory = { navController.navigate("addCategory") },
                        onCategoryClick = { categoryId ->
                            mainViewModel.selectCategory(categoryId)
                            navController.navigate("flashcards/$categoryId")
                        }
                    )
                }

                composable("addCategory") {
                    AddCategoryScreen(
                        viewModel = mainViewModel,
                        onSave = { navController.popBackStack() },
                        onCancel = { navController.popBackStack() }
                    )
                }

                composable(
                    "flashcards/{categoryId}",
                    arguments = listOf(navArgument("categoryId") { type = androidx.navigation.NavType.IntType })
                ) { backStackEntry ->
                    val categoryId = backStackEntry.arguments?.getInt("categoryId")!!
                    FlashcardsScreen(
                        viewModel = mainViewModel,
                        categoryId = categoryId,
                        onAddFlashcard = { navController.navigate("addFlashcard/$categoryId") },
                        onBack = { navController.popBackStack() },
                        onEditFlashcard = { flashcardId -> navController.navigate("editFlashcard/$flashcardId") },
                        onPractice = {navController.navigate("practice")}
                    )
                }

                composable(
                    "addFlashcard/{categoryId}",
                    arguments = listOf(navArgument("categoryId") { type = androidx.navigation.NavType.IntType })
                ) { backStackEntry ->
                    val categoryId = backStackEntry.arguments?.getInt("categoryId")!!
                    AddFlashcardScreen(
                        viewModel = mainViewModel,
                        categoryId = categoryId,
                        onCancel = { navController.popBackStack() },
                        onSave = { navController.popBackStack() }
                    )
                }

                composable(
                    "editFlashcard/{flashcardId}",
                    arguments = listOf(navArgument("flashcardId") { type = androidx.navigation.NavType.IntType })
                ) { backStackEntry ->
                    val flashcardId = backStackEntry.arguments?.getInt("flashcardId")!!
                    EditFlashcardScreen(
                        viewModel = mainViewModel,
                        flashcardId = flashcardId,
                        onSave = { navController.popBackStack() },
                        onCancel = { navController.popBackStack() }
                    )
                }

                composable("practice") {
                    PracticeScreen(navController = navController, viewModel = mainViewModel)
                }
            }
        }
    }
}
