package com.example.mindflip_native.views

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.ArrowForward
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.*
import androidx.navigation.NavController
import com.example.mindflip_native.models.Flashcard
import com.example.mindflip_native.viewModels.MainViewModel


@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PracticeScreen(
    navController: NavController,
    viewModel: MainViewModel
) {
    val flashcards by viewModel.flashcards.observeAsState(emptyList())

    var currentIndex by remember { mutableIntStateOf(0) }
    var showAnswer by remember { mutableStateOf(false) }

    val total = flashcards.size
    val currentFlashcard: Flashcard? = flashcards.getOrNull(currentIndex)

    if (currentFlashcard == null) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(Color(0xFFF0F0F0)),
            contentAlignment = Alignment.Center
        ) {
            Text("No flashcards available for this category.")
        }
        return
    }

    Scaffold(
        containerColor = Color(0xFFF0F0F0),
        topBar = {
            Column {
                CenterAlignedTopAppBar(
                    title = { Text("Practice") },
                    navigationIcon = {
                        IconButton(onClick = { navController.popBackStack() }) {
                            Icon(Icons.Default.Close, contentDescription = "Back", tint = Color.Black)
                        }
                    },
                    colors = TopAppBarDefaults.centerAlignedTopAppBarColors(
                        containerColor = Color(0xFFF0F0F0)
                    )
                )
                Divider(color = Color.Black.copy(alpha = 0.07f), thickness = 1.dp)
            }
        },
        bottomBar = {
            // Navigation buttons
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp, vertical = 12.dp),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Button(
                    onClick = {
                        if (currentIndex > 0) {
                            currentIndex--
                            showAnswer = false
                        }
                    },
                    enabled = currentIndex > 0,
                    colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF1280ED)),
                    modifier = Modifier.size(width = 170.dp, height = 50.dp),
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Icon(Icons.Default.ArrowBack, contentDescription = "Previous", tint = Color.White)
                    Spacer(Modifier.width(8.dp))
                    Text("Previous", color = Color.White, fontSize = 16.sp)
                }

                Button(
                    onClick = {
                        if (currentIndex < total - 1) {
                            currentIndex++
                            showAnswer = false
                        }
                    },
                    enabled = currentIndex < total - 1,
                    colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFFFA726)),
                    modifier = Modifier.size(width = 170.dp, height = 50.dp),
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Text("Next", color = Color.White, fontSize = 16.sp)
                    Spacer(Modifier.width(8.dp))
                    Icon(Icons.Default.ArrowForward, contentDescription = "Next", tint = Color.White)
                }
            }
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .padding(paddingValues)
                .fillMaxSize()
                .padding(horizontal = 24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Top
        ) {
            Spacer(modifier = Modifier.height(40.dp)) // more space under top bar

            // Progress info
            Text(
                text = "${currentIndex + 1}/$total",
                fontWeight = FontWeight.Medium,
                color = Color.Gray,
                fontSize = 16.sp
            )

            Spacer(modifier = Modifier.height(20.dp))

            // Blue progress bar
            LinearProgressIndicator(
                progress = (currentIndex + 1f) / total.toFloat(),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(8.dp)
                    .clip(RoundedCornerShape(4.dp)),
                color = Color(0xFF1280ED),
                trackColor = Color.LightGray
            )

            Spacer(modifier = Modifier.height(60.dp))

            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .fillMaxHeight(0.55f)
                    .background(Color.White, RoundedCornerShape(20.dp))
                    .clickable { showAnswer = !showAnswer }
                    .padding(20.dp),
                contentAlignment = Alignment.Center
            ) {
                Column(
                    modifier = Modifier.fillMaxSize(),
                    verticalArrangement = Arrangement.Top,
                    horizontalAlignment = Alignment.Start
                ) {
                    // Difficulty box
                    val (bgColor, textColor) = when (currentFlashcard.difficulty.name) {
                        "EASY" -> Pair(Color(0x334CAF50), Color(0xFF4CAF50))
                        "MEDIUM" -> Pair(Color(0x33FFA726), Color(0xFFFFA726))
                        "HARD" -> Pair(Color(0x33F44336), Color(0xFFF44336))
                        else -> Pair(Color.LightGray.copy(alpha = 0.3f), Color.Gray)
                    }

                    Box(
                        modifier = Modifier
                            .background(bgColor, RoundedCornerShape(8.dp))
                            .padding(horizontal = 12.dp, vertical = 6.dp)
                    ) {
                        Text(
                            text = currentFlashcard.difficulty.name,
                            color = textColor,
                            fontWeight = FontWeight.Bold
                        )
                    }

                    Spacer(modifier = Modifier.height(24.dp))

                    // Dynamic font size based on text length (smooth scaling)
                    val text = if (showAnswer) currentFlashcard.answer else currentFlashcard.question
                    val dynamicFontSize = remember(text) {
                        val baseSize = 45f
                        val minSize = 14f
                        val scale = (baseSize - (text.length * 0.25f)).coerceIn(minSize, baseSize)
                        scale.sp
                    }

                    Text(
                        text = text,
                        fontSize = dynamicFontSize,
                        fontWeight = FontWeight.Medium,
                        color = Color.Black,
                        textAlign = TextAlign.Start,
                        modifier = Modifier
                            .align(Alignment.Start)
                            .fillMaxWidth()
                    )
                }
            }

            Spacer(modifier = Modifier.height(36.dp))

            // Show/Hide Button
            Button(
                onClick = { showAnswer = !showAnswer },
                colors = ButtonDefaults.buttonColors(
                    containerColor = if (showAnswer) Color(0xFFFFA726) else Color(0xFF1280ED) // 🔸 orange when showing answer
                ),
                modifier = Modifier
                    .fillMaxWidth(0.75f)
                    .height(70.dp),
                shape = RoundedCornerShape(40.dp)
            ) {
                Text(
                    if (!showAnswer) "Show Answer" else "Hide Answer",
                    fontSize = 20.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = Color.White
                )
            }


            Spacer(modifier = Modifier.height(24.dp))
        }
    }
}
