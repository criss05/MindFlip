
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/main_view_model.dart';
import '../models/flashcard.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  int _currentIndex = 0;
  bool _showAnswer = false;

  void _nextCard(int total) {
    if (_currentIndex < total - 1) {
      setState(() {
        _currentIndex++;
        _showAnswer = false;
      });
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _showAnswer = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MainViewModel>();
    final flashcards = viewModel.flashcards;
    final total = flashcards.length;

    if (total == 0) {
      return Scaffold(
        backgroundColor: const Color(0xFFF0F0F0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("No flashcards available for this category."),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final currentFlashcard = flashcards[_currentIndex];
    final text = _showAnswer ? currentFlashcard.answer : currentFlashcard.question;

    
    const baseSize = 45.0;
    const minSize = 14.0;
    final scale = (baseSize - (text.length * 0.25)).clamp(minSize, baseSize);
    final dynamicFontSize = scale;

    Color diffBgColor;
    Color diffTextColor;
    switch (currentFlashcard.difficulty.name) {
      case 'easy':
        diffBgColor = const Color(0x334CAF50); 
        diffTextColor = const Color(0xFF4CAF50); 
        break;
      case 'medium':
        diffBgColor = const Color(0x33FFA726); 
        diffTextColor = const Color(0xFFFFA726); 
        break;
      case 'hard':
        diffBgColor = const Color(0x33F44336); 
        diffTextColor = const Color(0xFFF44336); 
        break;
      default:
        diffBgColor = Colors.grey.withOpacity(0.3);
        diffTextColor = Colors.grey;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        title: const Text("Practice"),
        backgroundColor: const Color(0xFFF0F0F0),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(color: Colors.black.withOpacity(0.07), thickness: 1.0),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40.0),
            
            Text('${_currentIndex + 1}/$total', style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey, fontSize: 16.0)),
            const SizedBox(height: 20.0),
            
            LinearProgressIndicator(
              value: (_currentIndex + 1) / total.toDouble(),
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1280ED)),
              minHeight: 8.0,
              borderRadius: BorderRadius.circular(4.0),
            ),
            const SizedBox(height: 60.0),
            
            Expanded(
              flex: 5,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showAnswer = !_showAnswer;
                  });
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20.0),
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Container(
                        decoration: BoxDecoration(
                          color: diffBgColor,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                        child: Text(
                          
                          '${currentFlashcard.difficulty.name[0].toUpperCase()}${currentFlashcard.difficulty.name.substring(1)}',
                          style: TextStyle(color: diffTextColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: dynamicFontSize,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36.0),
            
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              height: 70.0,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showAnswer = !_showAnswer;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _showAnswer ? const Color(0xFFFFA726) : const Color(0xFF1280ED),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
                ),
                child: Text(
                  _showAnswer ? "Hide Answer" : "Show Answer",
                  style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 170.0,
                    height: 50.0,
                    child: ElevatedButton(
                      onPressed: _currentIndex > 0 ? _previousCard : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1280ED),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.arrow_back, color: Colors.white),
                          const SizedBox(width: 8.0),
                          Text("Previous", style: TextStyle(color: Colors.white.withOpacity(_currentIndex > 0 ? 1.0 : 0.5), fontSize: 16.0)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 170.0,
                    height: 50.0,
                    child: ElevatedButton(
                      onPressed: _currentIndex < total - 1 ? () => _nextCard(total) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA726),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Next", style: TextStyle(color: Colors.white.withOpacity(_currentIndex < total - 1 ? 1.0 : 0.5), fontSize: 16.0)),
                          const SizedBox(width: 8.0),
                          const Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}