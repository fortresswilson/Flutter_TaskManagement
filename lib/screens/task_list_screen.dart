
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../widgets/task_tile.dart';
import '../main.dart';
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});
  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TaskService _service = TaskService();
  final TextEditingController _taskController = TextEditingController();
  String _searchQuery = '';
  String _selectedPriority = 'medium';

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _addTask() async {
    final title = _taskController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task name cannot be empty!'),
            backgroundColor: Colors.red));
      return;
    }
    await _service.addTask(title, priority: _selectedPriority);
    _taskController.clear();
  }

  Future<void> _confirmDelete(String taskId, String taskTitle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Delete "$taskTitle"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) await _service.deleteTask(taskId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
  title: const Text('Task Manager',
      style: TextStyle(fontWeight: FontWeight.bold)),
  backgroundColor: Theme.of(context).colorScheme.primary,
  foregroundColor: Colors.white,
  actions: [
    IconButton(
      icon: Icon(
        MyApp.of(context).isDark ? Icons.light_mode : Icons.dark_mode,
      ),
      onPressed: () => MyApp.of(context).toggleTheme(),
      tooltip: 'Toggle dark mode',
    ),
  ],
),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search tasks…',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPriority,
                      onChanged: (v) => setState(() => _selectedPriority = v!),
                      items: ['low', 'medium', 'high'].map((p) =>
                          DropdownMenuItem(value: p,
                              child: Text(p[0].toUpperCase() + p.substring(1)))).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    onSubmitted: (_) => _addTask(),
                    decoration: InputDecoration(
                      hintText: 'New task name…',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: _service.streamTasks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final tasks = snapshot.data ?? [];
                final filtered = _searchQuery.isEmpty
                    ? tasks
                    : tasks.where((t) => t.title.toLowerCase().contains(_searchQuery)).toList();
                if (filtered.isEmpty) {
                  return const Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.checklist_rounded, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('No tasks yet — add one above!',
                          style: TextStyle(color: Colors.grey)),
                    ]),
                  );
                }
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final task = filtered[index];
                    return TaskTile(
                      task: task,
                      service: _service,
                      onDelete: () => _confirmDelete(task.id, task.title),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
