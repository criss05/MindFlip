package com.example.mindflip_native.views

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.input.KeyboardCapitalization
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.mindflip_native.assets.Difficulty
import com.example.mindflip_native.models.Flashcard
import com.example.mindflip_native.viewModels.MainViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EditFlashcardScreen(
    viewModel: MainViewModel,
    flashcardId: Int,
    onCancel: () -> Unit,
    onSave: () -> Unit
) {
    val flashcard = viewModel.flashcards.value?.find { it.localId == flashcardId }
    if (flashcard == null) {
        Text("Flashcard not found")
        return
    }

    var question by remember { mutableStateOf(flashcard.question) }
    var answer by remember { mutableStateOf(flashcard.answer) }
    var difficulty by remember { mutableStateOf(flashcard.difficulty) }
    var errorQuestion by remember { mutableStateOf("") }
    var errorAnswer by remember { mutableStateOf("") }

    fun validateQuestion(input: String) {
        errorQuestion = when {
            input.isBlank() -> "Question cannot be empty"
            input.length > 150 -> "Maximum 150 characters"
            else -> ""
        }
    }

    fun validateAnswer(input: String) {
        errorAnswer = when {
            input.isBlank() -> "Answer cannot be empty"
            input.length > 150 -> "Maximum 150 characters"
            else -> ""
        }
    }

    Scaffold(
        topBar = {
            Column {
                CenterAlignedTopAppBar(
                    title = { Text("Edit card") },
                    navigationIcon = {
                        IconButton(onClick = onCancel) {
                            Icon(Icons.Default.Close, contentDescription = "Back")
                        }
                    },
                    colors = TopAppBarDefaults.centerAlignedTopAppBarColors(
                        containerColor = Color(0xFFF0F0F0)
                    )
                )
                Divider(
                    color = Color.Black.copy(alpha = 0.07f),
                    thickness = 1.dp
                )
            }
        },
        bottomBar = {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(25.dp)
                    .imePadding(),
                horizontalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Button(
                    onClick = onCancel,
                    colors = ButtonDefaults.buttonColors(
                        containerColor = Color.LightGray
                    ),
                    modifier = Modifier.weight(1f)
                ) {
                    Text("Cancel", color = Color.Black)
                }

                Button(
                    onClick = {
                        validateQuestion(question)
                        validateAnswer(answer)

                        if (errorQuestion.isEmpty() && errorAnswer.isEmpty()) {
                            viewModel.updateFlashcard(
                                flashcard.copy(
                                    question = question,
                                    answer = answer,
                                    difficulty = difficulty
                                )
                            )
                            onSave()
                        }
                    },
                    colors = ButtonDefaults.buttonColors(
                        containerColor = Color(0xFF1E88E5)
                    ),
                    modifier = Modifier.weight(1f)
                ) {
                    Text("Save", color = Color.White)
                }
            }
        },
        containerColor = Color(0xFFF0F0F0)
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            // Question
            Text("Question", style = MaterialTheme.typography.labelMedium)
            OutlinedTextField(
                value = question,
                onValueChange = {
                    question = it
                    validateQuestion(it)
                },
                placeholder = {
                    Text(
                        "e.g. What is the capital of Japan?",
                        color = Color.Black.copy(alpha = 0.3f)
                    )
                },
                isError = errorQuestion.isNotEmpty(),
                singleLine = false,
                textStyle = LocalTextStyle.current.copy(
                    fontSize = 18.sp
                ),
                keyboardOptions = KeyboardOptions.Default.copy(
                    capitalization = KeyboardCapitalization.Sentences
                ),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(150.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = Color(0xFF1280ED)
                )
            )
            if (errorQuestion.isNotEmpty()) {
                Text(errorQuestion, color = Color.Red, style = MaterialTheme.typography.bodySmall)
            }

            // Answer
            Text("Answer", style = MaterialTheme.typography.labelMedium)
            OutlinedTextField(
                value = answer,
                onValueChange = {
                    answer = it
                    validateAnswer(it)
                },
                placeholder = {
                    Text("e.g. Tokyo", color = Color.Black.copy(alpha = 0.3f))
                },
                isError = errorAnswer.isNotEmpty(),
                singleLine = false,
                textStyle = LocalTextStyle.current.copy(
                    fontSize = 18.sp
                ),
                keyboardOptions = KeyboardOptions.Default.copy(
                    capitalization = KeyboardCapitalization.Sentences
                ),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(110.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = Color(0xFF1280ED)
                )
            )
            if (errorAnswer.isNotEmpty()) {
                Text(errorAnswer, color = Color.Red, style = MaterialTheme.typography.bodySmall)
            }

            // Difficulty Dropdown
            DifficultyDropdown(
                selectedDifficulty = difficulty,
                onDifficultySelected = { difficulty = it }
            )
        }
    }
}
