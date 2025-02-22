import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../sources/remote_data_source.dart';

class TaskRepositoryImpl implements TaskRepository {
  final ApiService remoteDataSource;

  TaskRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Task>> getTasks() async {
    // Assuming remoteDataSource.getTasks() returns a List<Task>
    List<Task> tasks = remoteDataSource.fetchTasks() as List<Task>;
    return tasks;
  }
}
