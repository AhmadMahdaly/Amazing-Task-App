class TaskEntity {
  TaskEntity({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.isImportant = false,
    this.dueDate,
    this.reminderDate,
    this.repeatMode,
    this.completedSteps = 0,
    this.totalSteps = 0,
    this.listId,
    this.myDayDate,
    this.position = 0,
  });
  final String id;
  final String title;
  final bool isCompleted;
  final bool isImportant;
  final DateTime? dueDate;
  final DateTime? reminderDate;
  final String? repeatMode;
  final int completedSteps;
  final int totalSteps;
  final String? listId;
  final String? myDayDate;
  final int position;
}
