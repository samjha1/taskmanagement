import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game/presentation/widgets/add_task.dart';
import 'package:game/data/models/task_model.dart';
import 'package:game/main.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsyncValue = ref.watch(taskProvider);
    final filter = ref.watch(filterProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(context, ref, filter),
      body: Column(
        children: [
          _buildStatusBar(tasksAsyncValue),
          Expanded(
            child: _buildTaskList(tasksAsyncValue, filter),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskPage()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
        elevation: 4,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, WidgetRef ref, String filter) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      title: const Text(
        'Task Manager',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      actions: [
        _buildFilterButton(ref),
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () => _showSearchDialog(context),
        ),
      ],
    );
  }

  Widget _buildFilterButton(WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.filter_list, color: Colors.white),
      onSelected: (value) => ref.read(filterProvider.notifier).state = value,
      itemBuilder: (context) => [
        _buildFilterMenuItem('all', 'All Tasks', Icons.list),
        _buildFilterMenuItem('completed', 'Completed', Icons.check_circle),
        _buildFilterMenuItem('pending', 'Pending', Icons.pending_actions),
        _buildFilterMenuItem('priority', 'High Priority', Icons.priority_high),
      ],
    );
  }

  PopupMenuItem<String> _buildFilterMenuItem(
      String value, String text, IconData icon) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildStatusBar(AsyncValue<List<Task>> tasksAsyncValue) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: tasksAsyncValue.when(
        data: (tasks) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatusItem(
              'Total',
              tasks.length.toString(),
              Icons.assignment,
              Colors.blue,
            ),
            _buildStatusItem(
              'Completed',
              tasks.where((t) => t.isCompleted).length.toString(),
              Icons.check_circle,
              Colors.green,
            ),
            _buildStatusItem(
              'Pending',
              tasks.where((t) => !t.isCompleted).length.toString(),
              Icons.pending,
              Colors.orange,
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Text('Error loading statistics'),
      ),
    );
  }

  Widget _buildStatusItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskList(AsyncValue<List<Task>> tasksAsyncValue, String filter) {
    return tasksAsyncValue.when(
      data: (tasks) {
        final filteredTasks = _getFilteredTasks(tasks, filter);
        return filteredTasks.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) => TaskCard(
                  task: filteredTasks[index],
                  onStatusChanged: () => _handleStatusChange(context),
                  onDelete: () => _handleDelete(context),
                ),
              );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildErrorState(error.toString()),
    );
  }

  List<Task> _getFilteredTasks(List<Task> tasks, String filter) {
    return switch (filter) {
      'completed' => tasks.where((task) => task.isCompleted).toList(),
      'pending' => tasks.where((task) => !task.isCompleted).toList(),
      'priority' => tasks.where((task) => task.priority == 'high').toList(),
      _ => tasks,
    };
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a new task to get started',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Implement retry logic
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    // Implement add task dialog
  }

  void _showSearchDialog(BuildContext context) {
    // Implement search dialog
  }

  void _handleStatusChange(BuildContext context) {
    // Implement status change logic
  }

  void _handleDelete(BuildContext context) {
    // Implement delete logic
  }
}

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onStatusChanged;
  final VoidCallback onDelete;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onStatusChanged,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getPriorityColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showTaskDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildPriorityIndicator(),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTitle()),
                  _buildStatusIcon(),
                ],
              ),
              const SizedBox(height: 8),
              _buildDescription(),
              const SizedBox(height: 12),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator() {
    return Container(
      width: 4,
      height: 24,
      decoration: BoxDecoration(
        color: _getPriorityColor(),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      task.title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
      ),
    );
  }

  Widget _buildStatusIcon() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: task.isCompleted ? Colors.green[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        task.isCompleted ? Icons.check_circle : Icons.pending,
        size: 20,
        color: task.isCompleted ? Colors.green : Colors.grey,
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      task.description,
      style: TextStyle(
        color: Colors.grey[600],
        height: 1.5,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Future<void> _deleteTask(String taskId) async {
    final url =
        Uri.parse('https://api.indataai.in/wereads/taskdelete.php?id=$task.Id');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Task deleted successfully",
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar("Error", "Failed to delete task: ${response.body}",
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to delete task: $e",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        if (task.dueDate != null) ...[
          Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            _formatDate(task.dueDate!),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
        ],
        _buildActionButton(
          icon: Icons.edit,
          label: 'Edit',
          onTap: () => _showEditDialog(context),
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.delete,
          label: 'Delete',
          onTap: () {
            Get.defaultDialog(
              title: "Delete Task",
              middleText: "Are you sure you want to delete this task?",
              textConfirm: "Yes",
              textCancel: "No",
              confirmTextColor: Colors.white,
              onConfirm: () {
                _deleteTask(task.id.toString()); // Convert int to String
                Get.back(); // Close dialog after deletion
              },
            );
          },
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isDestructive ? Colors.red[400] : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDestructive ? Colors.red[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor() {
    return switch (task.priority) {
      'high' => Colors.red[400]!,
      'medium' => Colors.orange[400]!,
      _ => Colors.green[400]!,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showTaskDetails(BuildContext context) {
    // Implement task details dialog
  }

  void _showEditDialog(BuildContext context) {
    // Implement edit dialog
  }
}
