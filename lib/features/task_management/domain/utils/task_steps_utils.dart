import 'package:s/features/task_management/domain/entities/task_entity.dart';
import 'package:s/features/task_management/domain/entities/task_step.dart';

TaskEntity syncTaskStepCounts(TaskEntity task, List<TaskStep> steps) {
  final completed = steps.where((s) => s.isCompleted).length;
  return task.copyWith(
    steps: steps,
    completedSteps: completed,
    totalSteps: steps.length,
  );
}

bool areAllStepsCompleted(List<TaskStep> steps) {
  return steps.isNotEmpty && steps.every((s) => s.isCompleted);
}
