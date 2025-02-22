import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game/main.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

// ✅ Repository Provider (Corrected)
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(ref.watch(apiProvider));
});

// ✅ Use Case Provider (Corrected)
final getTasksProvider = Provider<GetTasksUseCase>((ref) {
  return GetTasksUseCase(ref.watch(taskRepositoryProvider));
});

// ✅ Task List Provider (Corrected)
final taskListProvider = FutureProvider<List<Task>>((ref) async {
  return ref.watch(getTasksProvider).call(null);
});
