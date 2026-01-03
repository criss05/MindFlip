import 'package:flutter/material.dart';
import '../assets/difficulty.dart';

class DifficultyDropdown extends StatelessWidget {
  final Difficulty selectedDifficulty;
  final ValueChanged<Difficulty> onDifficultySelected;

  const DifficultyDropdown({
    super.key,
    required this.selectedDifficulty,
    required this.onDifficultySelected,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Difficulty>(
      value: selectedDifficulty,
      decoration: const InputDecoration(
        labelText: 'Difficulty',
        border: OutlineInputBorder(),
      ),
      items: Difficulty.values.map((Difficulty difficulty) {
        return DropdownMenuItem<Difficulty>(
          value: difficulty,
          
          child: Text('${difficulty.name[0].toUpperCase()}${difficulty.name.substring(1)}'),
        );
      }).toList(),
      onChanged: (Difficulty? newValue) {
        if (newValue != null) {
          onDifficultySelected(newValue);
        }
      },
    );
  }
}