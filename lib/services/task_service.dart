
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskService {
  final _col = FirebaseFirestore.instance.collection('tasks');

  Future<void> addTask(String title, {String priority = 'medium'}) async {
    if (title.trim().isEmpty) return;
    await _col.add({
      'title': title.trim(),
      'isCompleted': false,
      'subtasks': [],
      'createdAt': DateTime.now().toIso8601String(),
      'priority': priority,
    });
  }

  Stream<List<Task>> streamTasks() => _col
      .orderBy('createdAt', descending: false)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => Task.fromMap(d.id, d.data() as Map<String, dynamic>))
          .toList());

  Future<void> toggleTask(Task task) async {
    await _col.doc(task.id).update({'isCompleted': !task.isCompleted});
  }

  Future<void> addSubtask(Task task, String subtaskTitle) async {
    if (subtaskTitle.trim().isEmpty) return;
    final updated = List<Map<String, dynamic>>.from(task.subtasks)
      ..add({'title': subtaskTitle.trim(), 'isCompleted': false});
    await _col.doc(task.id).update({'subtasks': updated});
  }

  Future<void> toggleSubtask(Task task, int index) async {
    final updated = List<Map<String, dynamic>>.from(task.subtasks);
    updated[index] = {
      ...updated[index],
      'isCompleted': !(updated[index]['isCompleted'] ?? false),
    };
    await _col.doc(task.id).update({'subtasks': updated});
  }

  Future<void> removeSubtask(Task task, int index) async {
    final updated = List<Map<String, dynamic>>.from(task.subtasks)
      ..removeAt(index);
    await _col.doc(task.id).update({'subtasks': updated});
  }

  Future<void> deleteTask(String taskId) async {
    await _col.doc(taskId).delete();
  }
}
