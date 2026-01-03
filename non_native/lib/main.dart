
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/database.dart';
import 'repositories/categories_repository.dart';
import 'repositories/flashcards_repository.dart';
import 'services/api_service.dart';
import 'services/socket_service.dart';
import 'view_models/main_view_model.dart';
import 'views/categories_screen.dart';
import 'views/add_category_screen.dart';
import 'views/flashcards_screen.dart';
import 'views/add_flashcard_screen.dart';
import 'views/edit_flashcard_screen.dart';
import 'views/practice_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  final database = AppDatabase();

  final socketService = SocketService();

  late final ApiService apiService;
  late final CategoriesRepository catRepo;
  late final FlashcardsRepository flashRepo;

  apiService = ApiService(
    socketService: socketService,
    onCategoryCreated: (d) => catRepo.handleSocketCreate(d),
    onCategoryUpdated: (d) => catRepo.handleSocketUpdate(d),
    onCategoryDeleted: (id) => catRepo.handleSocketDelete(id),
    onFlashcardCreated: (d) => flashRepo.handleSocketCreate(d),
    onFlashcardUpdated: (d) => flashRepo.handleSocketUpdate(d),
    onFlashcardDeleted: (id) => flashRepo.handleSocketDelete(id),
  );

  catRepo = CategoriesRepository(database, apiService);
  flashRepo = FlashcardsRepository(database, apiService);

  runApp(MainApp(
    categoriesRepo: catRepo,
    flashcardsRepo: flashRepo,
    apiService: apiService,
    socketService: socketService,
  ));
}

class MainApp extends StatelessWidget {
  final CategoriesRepository categoriesRepo;
  final FlashcardsRepository flashcardsRepo;
  final ApiService apiService;
  final SocketService socketService;

  const MainApp({
    super.key,
    required this.categoriesRepo,
    required this.flashcardsRepo,
    required this.apiService,
    required this.socketService,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MainViewModel(
        categoriesRepo: categoriesRepo,
        flashcardsRepo: flashcardsRepo,
        apiService: apiService,
        socketService: socketService,
      ),
      child: MaterialApp(
        title: 'MindFlip',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFFF0F0F0),
          useMaterial3: true,
        ),
        builder: (context, child) {
          return ConnectivityBanner(child: ErrorListener(child: child!));
        },
        home: Builder(
          builder: (context) {
            final navigator = Navigator.of(context);
            final viewModel = context.read<MainViewModel>();

            void onAddCategory() => navigator.push(
              MaterialPageRoute(builder: (c) => const AddCategoryScreen()),
            );

            void onCategoryClick(int categoryId) {
              viewModel.selectCategory(categoryId);
              navigator.push(
                MaterialPageRoute(
                  builder: (c) => FlashcardsScreen(
                    categoryId: categoryId,
                    onBack: () => navigator.pop(),
                    onAddFlashcard: () => navigator.push(
                      MaterialPageRoute(builder: (c) => AddFlashcardScreen(categoryId: categoryId)),
                    ),
                    onEditFlashcard: (flashcardId) => navigator.push(
                      MaterialPageRoute(builder: (c) => EditFlashcardScreen(flashcardId: flashcardId)),
                    ),
                    onPractice: () => navigator.push(
                      MaterialPageRoute(builder: (c) => const PracticeScreen()),
                    ),
                  ),
                ),
              );
            }

            return CategoriesScreen(
              onAddCategory: onAddCategory,
              onCategoryClick: onCategoryClick,
            );
          },
        ),
      ),
    );
  }
}

class ErrorListener extends StatelessWidget {
  final Widget child;
  const ErrorListener({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MainViewModel>();
    if (viewModel.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(viewModel.errorMessage!), backgroundColor: Colors.red),
        );
        viewModel.clearError();
      });
    }
    return child;
  }
}

class ConnectivityBanner extends StatelessWidget {
  final Widget child;
  const ConnectivityBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final status = context.select((MainViewModel vm) => vm.connectionStatus);
    final isOffline = status != ConnectionStatus.online;

    final backgroundColor = const Color(0xFFFFF59D);
    final contentColor = const Color(0xFF5D4037);

    String text = "Offline mode: Content may not be up-to-date";
    IconData icon = Icons.wifi_off_rounded;

    if (status == ConnectionStatus.serverDown) {
      text = "Server unavailable: Content may not be up-to-date";
      icon = Icons.cloud_off_rounded;
    }

    return Column(
      children: [

        Expanded(child: child),

        if (isOffline)
          Container(

            color: Theme.of(context).scaffoldBackgroundColor,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, color: contentColor, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            text,
                            style: TextStyle(
                              color: contentColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}