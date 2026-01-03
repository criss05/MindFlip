package com.example.mindflip_native.views

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Folder
import androidx.compose.material.icons.filled.Search
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
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.mindflip_native.models.Category
import com.example.mindflip_native.viewModels.MainViewModel
import kotlin.random.Random

private val categoryColors = listOf(
    Color(0xFFBFDFFF),
    Color(0xFFD3FFBF),
    Color(0xFFFFBFBF),
    Color(0xFFE0BFFF),
    Color(0xFFBFFFFE),
    Color(0xFFFFE2BF),
    Color(0xFFFFFFBF),
    Color(0xFFECBFFF),
    Color(0xFFFFBFEA)
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CategoriesScreen(
    viewModel: MainViewModel,
    onAddCategory: () -> Unit,
    onCategoryClick: (Int) -> Unit
) {
    val categories by viewModel.categories.observeAsState(emptyList())
    var categoryToDelete by remember { mutableStateOf<Category?>(null) }


    Scaffold(
        topBar = {
            CenterAlignedTopAppBar(
                title = { Text("Categories", color = Color.White) },
                colors = TopAppBarDefaults.centerAlignedTopAppBarColors(
                    containerColor = Color(0xFF2196F3)
                ),
                actions = {
                    IconButton(onClick = { /* TODO: handle search */ }) {
                        Icon(
                            imageVector = Icons.Default.Search,
                            contentDescription = "Search",
                            tint = Color.White
                        )
                    }
                }
            )
        },
        containerColor = Color(0xFFF0F0F0),
        floatingActionButton = {
            FloatingActionButton(
                onClick = onAddCategory,
                containerColor = Color(0xFF2196F3),
                shape = RoundedCornerShape(10.dp) // square shape
            ) {
                Text(
                    text = "+",
                    color = Color.White,
                    fontSize = 28.sp,
                    modifier = Modifier.padding(bottom = 2.dp)
                )
            }
        },
        bottomBar = {
            Column (
                modifier = Modifier
                    .fillMaxWidth()
                    .heightIn(min = 56.dp) // sets a minimum height for the bottom bar
            ) {
                Divider(
                    color = Color.Black.copy(alpha = 0.07f),
                    thickness = 1.dp
                )

                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(12.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "Tip: Tap a category to see your flashcards!",
                        color = Color.Gray,
                        style = MaterialTheme.typography.bodySmall
                    )
                }
            }
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(horizontal = 12.dp, vertical = 8.dp)
        ) {
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                itemsIndexed(categories) { index, category ->
                    val color = categoryColors[index % categoryColors.size]

                    Card(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { onCategoryClick(category.localId) },
                        colors = CardDefaults.cardColors(containerColor = Color.White),
                        elevation = CardDefaults.cardElevation(defaultElevation = 6.dp),
                        shape = RoundedCornerShape(12.dp)
                    ) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(16.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            // Colored square with folder icon
                            Box(
                                modifier = Modifier
                                    .size(48.dp)
                                    .clip(RoundedCornerShape(8.dp))
                                    .background(color),
                                contentAlignment = Alignment.Center
                            ) {
                                Icon(
                                    imageVector = Icons.Outlined.Folder,
                                    contentDescription = null,
                                    tint = Color.Black
                                )
                            }

                            Spacer(modifier = Modifier.width(16.dp))

                            // Category name & card count
                            Column(
                                modifier = Modifier.weight(1f)
                            ) {
                                Text(
                                    text = category.name,
                                    color = Color.Black,
                                    fontSize = 18.sp
                                )
                                Text(
                                    text = "${category.flashcardCount} cards",
                                    color = Color.DarkGray,
                                    fontSize = 14.sp
                                )
                            }

                            // Delete icon
                            IconButton(onClick = { categoryToDelete = category }) {
                                Icon(
                                    imageVector = Icons.Default.Close,
                                    contentDescription = "Delete Category",
                                    tint = Color.Gray
                                )
                            }
                        }
                    }
                }
            }

            // Delete dialog
            categoryToDelete?.let { category ->
                AlertDialog(
                    onDismissRequest = { categoryToDelete = null },
                    title = {
                        Text(
                            "Do you really want to delete this category?",
                            textAlign = TextAlign.Center,
                            modifier = Modifier.fillMaxWidth()
                        )
                    },
                    text = {
                        Text(
                            "All flashcards from '${category.name}' will also be deleted.",
                            textAlign = TextAlign.Center,
                            modifier = Modifier.fillMaxWidth()
                        )
                    },
                    confirmButton = {
                        Button(
                            onClick = {
                                viewModel.deleteCategory(category.localId)
                                categoryToDelete = null
                            },
                            colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFFF8C00)),
                            modifier = Modifier
                                .padding(horizontal = 8.dp)
                        ) {
                            Text("Yes")
                        }
                    },
                    dismissButton = {
                        Button(
                            onClick = { categoryToDelete = null },
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
}
