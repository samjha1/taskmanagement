import 'package:game/core/usecase.dart';
import 'package:game/domain/entities/task.dart';
import 'package:game/domain/repositories/task_repository.dart';

class GetTasksUseCase implements UseCase<List<Task>, void> {
  final TaskRepository repository;

  GetTasksUseCase(this.repository);

  @override
  Future<List<Task>> call(void params) async {
    return await repository.getTasks();
  }
}
