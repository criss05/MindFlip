
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/main_view_model.dart';
import '../models/flashcard.dart';

class FlashcardsScreen extends StatelessWidget {
  final int categoryId;
  final VoidCallback onBack;
  final VoidCallback onAddFlashcard;
  final ValueChanged<int> onEditFlashcard;
  final VoidCallback onPractice;

  const FlashcardsScreen({
    super.key,
    required this.categoryId,
    required this.onBack,
    required this.onAddFlashcard,
    required this.onEditFlashcard,
    required this.onPractice,
  });

  void _showDeleteDialog(BuildContext context, Flashcard flashcard, MainViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Do you really want to delete the card?", textAlign: TextAlign.center),
          actionsAlignment: MainAxisAlignment.center,
          backgroundColor: const Color(0xFFF0F0F0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                viewModel.deleteFlashcard(flashcard.localId, flashcard.categoryId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8C00),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text("Yes", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD3D3D3),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text("No", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MainViewModel>();
    final flashcards = viewModel.flashcards;
    final categoryName = viewModel.getCategoryName(categoryId);

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName, style: const TextStyle(color: Colors.black, fontSize: 22.0)),
        backgroundColor: const Color(0xFFF0F0F0),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: onBack, 
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ElevatedButton(
              onPressed: onPractice, 
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                minimumSize: const Size(0, 40.0),
              ),
              child: const Text("Practice", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(color: Colors.black.withOpacity(0.07), thickness: 1.0),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView.builder(
          itemCount: flashcards.length,
          itemBuilder: (context, index) {
            final flashcard = flashcards[index];
            Color diffColor;

            switch (flashcard.difficulty.name) {
              case 'easy':
                diffColor = const Color(0xFF4CAF50);
                break;
              case 'medium':
                diffColor = const Color(0xFFFFA500);
                break;
              case 'hard':
                diffColor = const Color(0xFFF44336);
                break;
              default:
                diffColor = Colors.black;
            }

            return Card(
              elevation: 6.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    
                    Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: const Icon(Icons.copy_outlined, color: Colors.black),
                    ),
                    const SizedBox(width: 12.0),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            flashcard.question,
                            style: const TextStyle(fontSize: 16.0, color: Colors.black),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            
                            '${flashcard.difficulty.name[0].toUpperCase()}${flashcard.difficulty.name.substring(1)}',
                            style: TextStyle(fontSize: 14.0, color: diffColor),
                          ),
                        ],
                      ),
                    ),
                    
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20.0),
                          onPressed: () => onEditFlashcard(flashcard.localId), 
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20.0),
                          onPressed: () => _showDeleteDialog(context, flashcard, viewModel),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: onAddFlashcard, 
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8C00),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60.0)),
                minimumSize: const Size(double.infinity, 60.0),
              ),
              child: const Text("+ Add Flashcard", style: TextStyle(color: Colors.white, fontSize: 22.0)),
            ),
          ],
        ),
      ),
    );
  }
}