class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final List<Map<String, dynamic>> subtasks;
  final DateTime createdAt;
  final String priority; // 'low', 'medium', 'high'

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.subtasks = const [],
    required this.createdAt,
    this.priority = 'medium',
  });

  // Serialize → Firestore
  Map<String, dynamic> toMap() => {
        'title': title,
        'isCompleted': isCompleted,
        'subtasks': subtasks,
        'createdAt': createdAt.toIso8601String(),
        'priority': priority,
      };

  // Deserialize ← Firestore snapshot
  factory Task.fromMap(String id, Map<String, dynamic> data) => Task(
        id: id,
        title: data['title'] ?? '',
        isCompleted: data['isCompleted'] ?? false,
        subtasks: List<Map<String, dynamic>>.from(data['subtasks'] ?? []),
        createdAt:
            DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
        priority: data['priority'] ?? 'medium',
      );

  // Immutable update helper
  Task copyWith({
    String? title,
    bool? isCompleted,
    List<Map<String, dynamic>>? subtasks,
    String? priority,
  }) =>
      Task(
        id: id,
        title: title ?? this.title,
        isCompleted: isCompleted ?? this.isCompleted,
        subtasks: subtasks ?? this.subtasks,
        createdAt: createdAt,
        priority: priority ?? this.priority,
      );
}
