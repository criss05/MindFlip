package com.example.mindflip_native.views

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.example.mindflip_native.models.Category
import com.example.mindflip_native.viewModels.MainViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddCategoryScreen(
    viewModel: MainViewModel,
    onCancel: () -> Unit,
    onSave: () -> Unit
) {
    var name by remember { mutableStateOf("") }
    var error by remember { mutableStateOf("") }

    fun validateName(input: String) {
        error = when {
            input.isBlank() -> "Name cannot be empty"
            input.length > 30 -> "Maximum 30 characters"
            else -> ""
        }
    }

    Scaffold(
        topBar = {
            CenterAlignedTopAppBar(
                title = { Text("Add Category", color = Color.White) },
                colors = TopAppBarDefaults.centerAlignedTopAppBarColors(
                    containerColor = Color(0xFF2196F3) // Blue background
                )
            )
        },
        containerColor = Color(0xFFF0F0F0),
        bottomBar = {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(30.dp)
                    .imePadding(),
                horizontalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Button(
                    onClick = {
                        validateName(name)

                        if (error.isEmpty()) {
                            viewModel.addCategory(Category(localId = -1, name = name, flashcardCount = 0))
                            onSave()
                        }
                    },
                    colors = ButtonDefaults.buttonColors(
                        containerColor = Color(0xFF1E88E5) // blue
                    ),
                    modifier = Modifier.weight(1f)
                ) {
                    Text("Save", color = Color.White)
                }

                Button(
                    onClick = onCancel,
                    colors = ButtonDefaults.buttonColors(
                        containerColor = Color.LightGray
                    ),
                    modifier = Modifier.weight(1f)
                ) {
                    Text("Cancel", color = Color.Black)
                }
            }
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(16.dp),
            verticalArrangement = Arrangement.Top
        ) {
            OutlinedTextField(
                value = name,
                onValueChange = {
                    name = it
                    validateName(it)
                },
                label = { Text("Category Name", color = Color.Black) },
                isError = error.isNotEmpty(),
                modifier = Modifier.fillMaxWidth(),
               colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = Color(0xFF2196F3),
                    unfocusedBorderColor = Color(0xFF2196F3)
                ),
            )

            if (error.isNotEmpty()) {
                Text(
                    text = error,
                    color = Color.Red,
                    style = MaterialTheme.typography.bodySmall,
                    modifier = Modifier.padding(top = 4.dp)
                )
            }

            Spacer(modifier = Modifier.height(24.dp))
        }
    }
}
