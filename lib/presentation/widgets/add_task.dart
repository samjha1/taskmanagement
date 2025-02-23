import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game/presentation/screens/home.dart';
import 'package:game/main.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final isLoadingProvider = StateProvider<bool>((ref) => false);

class AddTaskPage extends ConsumerStatefulWidget {
  final int? taskId; // Nullable taskId for editing

  const AddTaskPage({Key? key, this.taskId}) : super(key: key);

  @override
  ConsumerState<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends ConsumerState<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  String _priority = 'medium';
  bool _isUrgent = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.taskId != null) {
      _fetchTaskDetails(widget.taskId!);
    }
  }

  Future<void> _fetchTaskDetails(int taskId) async {
    final url = 'https://api.indataai.in/wereads/todoedit.php?id=$taskId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['success'] == true && data['task'] != null) {
          final task = data['task'];

          setState(() {
            _titleController.text = task['title'] ?? '';
            _descriptionController.text = task['description'] ?? '';
            _selectedDate = task['dueDate'] != null
                ? DateTime.parse(task['dueDate'])
                : null;
            _priority = task['priority'] ?? 'low'; // Default to 'low'
            _isUrgent = task['is_urgent'] == 1;
          });
        } else {
          print('Error: Task not found');
        }
      } else {
        print('Failed to fetch task details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching task details: $e');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      ref.read(isLoadingProvider.notifier).state = true;

      final task = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'dueDate': _selectedDate?.toIso8601String(),
        'priority': _priority,
        'is_urgent': _isUrgent ? 1 : 0,
      };

      final url = widget.taskId == null
          ? 'https://api.indataai.in/wereads/taskadd.php'
          : 'https://api.indataai.in/wereads/updatetodo.php';

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            widget.taskId == null ? task : {...task, 'id': widget.taskId}),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(widget.taskId == null ? 'Task created' : 'Task updated'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw responseData['message'] ?? 'Unknown error occurred';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Create New Task',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Theme.of(context).primaryColor,
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 30),
              child: const Icon(
                Icons.assignment_add,
                size: 64,
                color: Colors.white,
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTitleField(),
                      const SizedBox(height: 20),
                      _buildDescriptionField(),
                      const SizedBox(height: 20),
                      _buildDatePicker(),
                      const SizedBox(height: 24),
                      _buildPrioritySelector(),
                      const SizedBox(height: 20),
                      _buildUrgentToggle(),
                      const SizedBox(height: 32),
                      _buildSubmitButton(isLoading),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Task Title',
        hintText: 'Enter task title',
        prefixIcon: const Icon(Icons.title),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a title';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Description',
        hintText: 'Enter task description',
        prefixIcon: const Icon(Icons.description),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        alignLabelWithHint: true,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a description';
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.calendar_today,
                    color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text(
                  _selectedDate == null
                      ? 'Select Due Date'
                      : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                  style: TextStyle(
                    color:
                        _selectedDate == null ? Colors.grey[600] : Colors.black,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey.shade600),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority Level',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPriorityChip('Low', Colors.green),
            _buildPriorityChip('Medium', Colors.orange),
            _buildPriorityChip('High', Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityChip(String label, Color color) {
    final isSelected = _priority == label.toLowerCase();
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : color,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          setState(() => _priority = label.toLowerCase());
        }
      },
      backgroundColor: color.withOpacity(0.1),
      selectedColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildUrgentToggle() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: _isUrgent ? Colors.red.shade50 : Colors.grey[50],
        border: Border.all(
          color: _isUrgent ? Colors.red.shade200 : Colors.grey.shade300,
        ),
      ),
      child: SwitchListTile(
        title: Text(
          'Urgent Task',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: _isUrgent ? Colors.red : Colors.grey[800],
          ),
        ),
        subtitle: Text(
          'Mark this task as urgent priority',
          style: TextStyle(
            color: _isUrgent ? Colors.red.shade700 : Colors.grey[600],
          ),
        ),
        value: _isUrgent,
        onChanged: (value) => setState(() => _isUrgent = value),
        secondary: Icon(
          Icons.priority_high,
          color: _isUrgent ? Colors.red : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return ElevatedButton(
      onPressed: isLoading
          ? null
          : () async {
              await _submitForm();
              if (mounted) {
                // Refresh the task list using Riverpod
                ref.refresh(taskProvider);

                // Navigate back to home and replace the current route
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              }
            },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_task),
                SizedBox(width: 8),
                Text(
                  'Create Task',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    );
  }
}
