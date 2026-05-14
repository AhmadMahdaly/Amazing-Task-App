class TaskListEntity {
  TaskListEntity({
    required this.id,
    required this.title,
    this.position = 0,
  });
  final String id;
  final String title;
  final int position;
}
