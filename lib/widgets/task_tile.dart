
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskTile extends StatefulWidget {
  final Task task;
  final TaskService service;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.service,
    required this.onDelete,
  });

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  bool _expanded = false;
  final TextEditingController _subtaskCtrl = TextEditingController();

  @override
  void dispose() {
    _subtaskCtrl.dispose();
    super.dispose();
  }

  Color _priorityColor() {
    switch (widget.task.priority) {
      case 'high': return Colors.red;
      case 'low': return Colors.green;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final completedSubs = task.subtasks.where((s) => s['isCompleted'] == true).length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _priorityColor().withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: Checkbox(
              value: task.isCompleted,
              activeColor: _priorityColor(),
              onChanged: (_) => widget.service.toggleTask(task),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                color: task.isCompleted ? Colors.grey : null,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: task.subtasks.isNotEmpty
                ? Text('$completedSubs / ${task.subtasks.length} subtasks done',
                    style: const TextStyle(fontSize: 12, color: Colors.grey))
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _priorityColor().withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(task.priority.toUpperCase(),
                      style: TextStyle(fontSize: 10, color: _priorityColor(), fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                children: [
                  ...List.generate(task.subtasks.length, (i) {
                    final sub = task.subtasks[i];
                    return Row(
                      children: [
                        Checkbox(
                          value: sub['isCompleted'] ?? false,
                          onChanged: (_) => widget.service.toggleSubtask(task, i),
                        ),
                        Expanded(
                          child: Text(sub['title'] ?? '',
                              style: TextStyle(
                                decoration: (sub['isCompleted'] ?? false)
                                    ? TextDecoration.lineThrough : null,
                                color: (sub['isCompleted'] ?? false) ? Colors.grey : null,
                              )),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, size: 18, color: Colors.red),
                          onPressed: () => widget.service.removeSubtask(task, i),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _subtaskCtrl,
                          onSubmitted: (_) => _submitSubtask(),
                          decoration: InputDecoration(
                            hintText: 'Add subtask…',
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(onPressed: _submitSubtask, child: const Text('Add')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _submitSubtask() {
    widget.service.addSubtask(widget.task, _subtaskCtrl.text);
    _subtaskCtrl.clear();
  }
}
