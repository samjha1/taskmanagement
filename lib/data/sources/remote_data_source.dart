import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';

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


