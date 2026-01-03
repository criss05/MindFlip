
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/main_view_model.dart';
import '../models/category.dart';


const List<Color> _categoryColors = [
  Color(0xFFBFDFFF),
  Color(0xFFD3FFBF),
  Color(0xFFFFBFBF),
  Color(0xFFE0BFFF),
  Color(0xFFBFFFFE),
  Color(0xFFFFE2BF),
  Color(0xFFFFFFBF),
  Color(0xFFECBFFF),
  Color(0xFFFFBFEA),
];

class CategoriesScreen extends StatefulWidget {
  final VoidCallback onAddCategory;
  final ValueChanged<int> onCategoryClick;

  const CategoriesScreen({
    super.key,
    required this.onAddCategory,
    required this.onCategoryClick,
  });

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteDialog(BuildContext context, Category category, MainViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Do you really want to delete this category?", textAlign: TextAlign.center),
          content: Text("All flashcards from '${category.name}' will also be deleted.", textAlign: TextAlign.center),
          actionsAlignment: MainAxisAlignment.center,
          backgroundColor: const Color(0xFFF0F0F0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                viewModel.deleteCategory(category.localId);
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
    final categories = viewModel.categories;
    return Scaffold(
      appBar: AppBar(
        
        title: _isSearching
            ? TextField(
          controller: _searchController,
          onChanged: (query) {
            
            viewModel.searchQuery = query;
          },
          decoration: const InputDecoration(
            hintText: 'Search categories...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white, fontSize: 18.0),
          autofocus: true,
        )
            : const Text("Categories", style: TextStyle(color: Colors.white)),

        centerTitle: true,
        backgroundColor: const Color(0xFF2196F3),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  
                  _searchController.clear();
                  viewModel.searchQuery = '';
                  FocusScope.of(context).unfocus(); 
                }
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final color = _categoryColors[index % _categoryColors.length];

            return Card(
              elevation: 6.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: InkWell(
                onTap: () {
                  widget.onCategoryClick(category.localId);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      
                      Container(
                        width: 48.0,
                        height: 48.0,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Icon(Icons.folder_outlined, color: Colors.black),
                      ),
                      const SizedBox(width: 16.0),
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(category.name, style: const TextStyle(color: Colors.black, fontSize: 18.0)),
                            Text('${category.flashcardCount} cards', style: const TextStyle(color: Colors.grey, fontSize: 14.0)),
                          ],
                        ),
                      ),
                      
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => _showDeleteDialog(context, category, viewModel),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onAddCategory,
        backgroundColor: const Color(0xFF2196F3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: const Text('+', style: TextStyle(color: Colors.white, fontSize: 28.0)),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(color: Colors.black.withOpacity(0.07), thickness: 1.0),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              "Tip: Tap a category to see your flashcards!",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}