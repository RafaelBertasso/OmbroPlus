class DailyExerciseData {
  final String protocolId;
  final List<Map<String, dynamic>> exercises;
  final Set<String> completedExerciseIds;

  DailyExerciseData({
    required this.protocolId,
    required this.exercises,
    required this.completedExerciseIds,
  });
}
