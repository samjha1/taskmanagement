import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:game/home.dart';

class Task {
  final int id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime? dueDate;
  final String priority;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.dueDate,
    this.priority = 'medium',
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: int.tryParse(json['id'].toString()) ?? 0, // Ensure id is int
      title: json['title'],
      description: json['description'],
      isCompleted:
          json['isCompleted'].toString() == "1", // Convert string to bool
    );
  }
}

class ApiService {
  static const String baseUrl = 'https://api.indataai.in/wereads';

  Future<List<Task>> fetchTasks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/taskget.php'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.isNotEmpty
            ? data.map((task) => Task.fromJson(task)).toList()
            : [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}

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
