
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/main_view_model.dart';
import '../models/flashcard.dart';
import '../assets/difficulty.dart';
import 'difficulty_dropdown.dart';

class EditFlashcardScreen extends StatefulWidget {
  final int flashcardId;
  const EditFlashcardScreen({super.key, required this.flashcardId});

  @override
  State<EditFlashcardScreen> createState() => _EditFlashcardScreenState();
}

class _EditFlashcardScreenState extends State<EditFlashcardScreen> {
  late Flashcard _initialFlashcard;
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  late Difficulty _selectedDifficulty;
  String? _errorQuestion;
  String? _errorAnswer;

  @override
  void initState() {
    super.initState();
    
    final viewModel = context.read<MainViewModel>();
    _initialFlashcard = viewModel.getFlashcardById(widget.flashcardId)!;

    
    _questionController = TextEditingController(text: _initialFlashcard.question);
    _answerController = TextEditingController(text: _initialFlashcard.answer);
    _selectedDifficulty = _initialFlashcard.difficulty;
  }

  void _validateQuestion(String input) {
    if (input.trim().isEmpty) {
      _errorQuestion = "Question cannot be empty";
    } else if (input.length > 150) {
      _errorQuestion = "Maximum 150 characters";
    } else {
      _errorQuestion = null;
    }
  }

  void _validateAnswer(String input) {
    if (input.trim().isEmpty) {
      _errorAnswer = "Answer cannot be empty";
    } else if (input.length > 150) {
      _errorAnswer = "Maximum 150 characters";
    } else {
      _errorAnswer = null;
    }
  }

  void _validateAndSave(MainViewModel viewModel) {
    
    setState(() {
      _validateQuestion(_questionController.text);
      _validateAnswer(_answerController.text);
    });

    if (_errorQuestion == null && _errorAnswer == null) {
      
      final updatedFlashcard = _initialFlashcard.copyWith(
        question: _questionController.text.trim(),
        answer: _answerController.text.trim(),
        difficulty: _selectedDifficulty,
      );

      
      viewModel.updateFlashcard(updatedFlashcard);
      Navigator.of(context).pop(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<MainViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        title: const Text("Edit card"),
        backgroundColor: const Color(0xFFF0F0F0),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(), 
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(color: Colors.black.withOpacity(0.07), thickness: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            const Text("Question", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0)),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: _questionController,
              onChanged: (value) {
                
                if (_errorQuestion != null) setState(() => _errorQuestion = null);
              },
              maxLines: null,
              minLines: 5,
              maxLength: 150,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(fontSize: 18.0),
              decoration: InputDecoration(
                hintText: "e.g. What is the capital of Japan?",
                border: const OutlineInputBorder(),
                errorText: _errorQuestion,
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF1280ED))),
                counterText: '',
              ),
            ),
            const SizedBox(height: 12.0),

            
            const Text("Answer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0)),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: _answerController,
              onChanged: (value) {
                
                if (_errorAnswer != null) setState(() => _errorAnswer = null);
              },
              maxLines: null,
              minLines: 4,
              maxLength: 150,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(fontSize: 18.0),
              decoration: InputDecoration(
                hintText: "e.g. Tokyo",
                border: const OutlineInputBorder(),
                errorText: _errorAnswer,
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF1280ED))),
                counterText: '',
              ),
            ),
            const SizedBox(height: 12.0),

            
            DifficultyDropdown(
              selectedDifficulty: _selectedDifficulty,
              onDifficultySelected: (newDifficulty) {
                setState(() {
                  _selectedDifficulty = newDifficulty;
                });
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 25.0,
          right: 25.0,
          top: 25.0,
          bottom: 25.0 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(), 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                ),
                child: const Text("Cancel", style: TextStyle(color: Colors.black)),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _validateAndSave(viewModel), 
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                ),
                child: const Text("Save", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}