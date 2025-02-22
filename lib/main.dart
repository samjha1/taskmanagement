import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game/data/models/task_model.dart';
import 'package:game/data/sources/remote_data_source.dart';
import 'package:game/presentation/screens/home.dart';




final apiProvider = Provider((ref) => ApiService());

final taskProvider = FutureProvider<List<Task>>((ref) async {
  return ref.watch(apiProvider).fetchTasks();
});

final filterProvider = StateProvider<String>((ref) => 'all');

// Main App
void main() {
  runApp(const ProviderScope(child: TaskManagerApp()));
}

class TaskManagerApp extends ConsumerWidget {
  const TaskManagerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
