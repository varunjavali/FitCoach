class WorkoutModel {
  final String id;
  final String clientId;
  final String trainerId;
  final String title;
  final String day;
  final List<ExerciseModel> exercises;

  WorkoutModel({
    required this.id,
    required this.clientId,
    required this.trainerId,
    required this.title,
    required this.day,
    required this.exercises,
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json["_id"]?.toString() ?? "",
      clientId: json["client"] is Map
          ? json["client"]["_id"]
          : json["client"]?.toString() ?? "",
      trainerId: json["trainer"] is Map
          ? json["trainer"]["_id"]
          : json["trainer"]?.toString() ?? "",
      title: json["title"] ?? "",
      day: json["day"] ?? "",
      exercises: (json["exercises"] as List? ?? [])
          .map((e) => ExerciseModel.fromJson(e))
          .toList(),
    );
  }
}

class ExerciseModel {
  final String exerciseName;
  final int sets;
  final int reps;
  final double weight;
  final int rest;

  ExerciseModel({
    required this.exerciseName,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.rest,
  });

  factory ExerciseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ExerciseModel(
      exerciseName: json["exerciseName"] ?? "",
      sets: json["sets"] ?? 0,
      reps: json["reps"] ?? 0,
      weight: (json["weight"] ?? 0).toDouble(),
      rest: json["rest"] ?? 0,
    );
  }
}