
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/main_view_model.dart';
import '../models/category.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _errorText;

  void _validateAndSave(MainViewModel viewModel) {
    final name = _nameController.text.trim();
    String? error;

    if (name.isEmpty) {
      error = "Name cannot be empty";
    } else if (name.length > 30) {
      error = "Maximum 30 characters";
    }

    setState(() {
      _errorText = error;
    });

    if (error == null) {
      viewModel.addCategory(
        Category(localId: -1, name: name, flashcardCount: 0),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<MainViewModel>();
    const blueColor = Color(0xFF2196F3);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Category", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: blueColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              onChanged: (value) {
                
                if (_errorText != null) {
                  setState(() {
                    _errorText = null;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: "Category Name",
                labelStyle: const TextStyle(color: Colors.black),
                errorText: _errorText, 

                
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: blueColor), 
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: blueColor, width: 2.0), 
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: blueColor),
                ),

              ),
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 30.0,
          right: 30.0,
          top: 30.0,
          bottom: 30.0 + MediaQuery.of(context).viewInsets.bottom, 
        ),
        child: Row(
          children: [
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
            const SizedBox(width: 16.0),
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
          ],
        ),
      ),
    );
  }
}