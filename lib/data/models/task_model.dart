
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
