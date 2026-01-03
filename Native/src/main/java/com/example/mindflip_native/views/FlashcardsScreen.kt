package com.example.mindflip_native.views

import android.R
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.outlined.FileCopy
import androidx.compose.material.icons.outlined.Folder
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.mindflip_native.models.Flashcard
import com.example.mindflip_native.viewModels.MainViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FlashcardsScreen(
    viewModel: MainViewModel,
    categoryId: Int,
    onAddFlashcard: () -> Unit,
    onBack: () -> Unit,
    onEditFlashcard: (Int) -> Unit,
    onPractice: () -> Unit
) {
    val flashcards by viewModel.flashcards.observeAsState(emptyList())
    var flashcardToDelete by remember { mutableStateOf<Flashcard?>(null) }
    val categoryName = viewModel.categories.value?.find { it.localId == categoryId }?.name ?: "Category"

    Scaffold(
        topBar = {
            Column {
                TopAppBar(
                    title = { Text(categoryName, color = Color.Black, fontSize = 22.sp) },
                    navigationIcon = {
                        IconButton(onClick = onBack) {
                            Icon(
                                Icons.Default.ArrowBack,
                                contentDescription = "Back",
                                tint = Color.Black
                            )
                        }
                    },
                    actions = {
                        Button(
                            onClick = onPractice,
                            colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF2196F3)),
                            shape = RoundedCornerShape(10.dp),
                            modifier = Modifier
                                .height(40.dp)
                        ) {
                            Text("Practice", color = Color.White)
                        }
                    },
                    colors = TopAppBarDefaults.centerAlignedTopAppBarColors(
                        containerColor = Color(0xFFF0F0F0)
                    )
                )
                Divider(color = Color.Black.copy(alpha = 0.07f), thickness = 1.dp)
            }
        },
        containerColor = Color(0xFFF0F0F0),
        bottomBar = {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(Color.Transparent),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Spacer(modifier = Modifier.height(8.dp))
                Button(
                    onClick = onAddFlashcard,
                    modifier = Modifier
                        .fillMaxWidth(0.7f)
                        .height(60.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFFF8C00)),
                    shape = RoundedCornerShape(60.dp)
                ) {
                    Text("+ Add Flashcard", color = Color.White, fontSize = 22.sp)
                }
                Spacer(modifier = Modifier.height(30.dp))
            }
        },
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(top = paddingValues.calculateTopPadding(), bottom = paddingValues.calculateBottomPadding())
                .padding(horizontal = 16.dp)
        ) {
            items(flashcards) { flashcard ->
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 8.dp),
                    colors = CardDefaults.cardColors(containerColor = Color.White),
                    elevation = CardDefaults.cardElevation(defaultElevation = 6.dp),
                    shape = RoundedCornerShape(8.dp)
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(12.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        // Left square with folder icon
                        Box(
                            modifier = Modifier
                                .size(50.dp)
                                .clip(RoundedCornerShape(4.dp))
                                .background(Color(0xFFF0F0F0)),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = Icons.Outlined.FileCopy,
                                contentDescription = "FileCopy",
                                tint = Color.Black
                            )
                        }

                        Spacer(modifier = Modifier.width(12.dp))

                        Column(modifier = Modifier.weight(1f)) {
                            Text(
                                text = flashcard.question,
                                fontSize = 16.sp,
                                color = Color.Black,
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis
                            )

                            val diffColor = when (flashcard.difficulty.name) {
                                "EASY" -> Color(0xFF4CAF50)
                                "MEDIUM" -> Color(0xFFFFA500)
                                "HARD" -> Color(0xFFF44336)
                                else -> Color.Black
                            }

                            Text(
                                text = flashcard.difficulty.name.lowercase()
                                    .replaceFirstChar { it.uppercase() },
                                fontSize = 14.sp,
                                color = diffColor
                            )
                        }

                        Row {
                            IconButton(
                                onClick = { onEditFlashcard(flashcard.localId) },
                                modifier = Modifier.size(36.dp)
                            ) {
                                Icon(Icons.Default.Edit, contentDescription = "Edit Flashcard", modifier = Modifier.size(20.dp))
                            }
                            IconButton(
                                onClick = { flashcardToDelete = flashcard },
                                modifier = Modifier.size(36.dp)
                            ) {
                                Icon(Icons.Default.Delete, contentDescription = "Delete Flashcard", modifier = Modifier.size(20.dp))
                            }
                        }
                    }
                }
            }
        }

        // Delete dialog
        flashcardToDelete?.let { flashcard ->
            AlertDialog(
                onDismissRequest = { flashcardToDelete = null },
                title = {
                    Text(
                        "Do you really want to delete the card?",
                        textAlign = TextAlign.Center,
                        modifier = Modifier.fillMaxWidth()
                    )
                },
                confirmButton = {
                    Button(
                        onClick = {
                            viewModel.deleteFlashcard(flashcardToDelete!!.localId, categoryId)
                            flashcardToDelete = null
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFFF8C00)),
                        modifier = Modifier
                            .padding(horizontal = 8.dp),

                    ) {
                        Text("Yes")
                    }
                },
                dismissButton = {
                    Button(
                        onClick = { flashcardToDelete = null },
                        colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFD3D3D3)),
                        modifier = Modifier
                            .padding(horizontal = 8.dp)
                    ) {
                        Text("No", color = Color.Black)
                    }
                },
                containerColor = Color(0xFFF0F0F0),
                modifier = Modifier.shadow(8.dp, shape = RoundedCornerShape(16.dp))
            )

        }
    }
}
