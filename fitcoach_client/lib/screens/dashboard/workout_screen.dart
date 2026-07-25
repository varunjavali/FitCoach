import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/workout_model.dart';
import '../../services/workout_service.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final WorkoutService workoutService = WorkoutService();

  List<WorkoutModel> workouts = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadWorkouts();
  }

  Future<void> loadWorkouts() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("clientToken");

      if (token == null) {
        throw Exception("Please login again");
      }

      final data = await workoutService.getMyWorkouts(
        token,
      );

      setState(() {
        workouts = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Widget exerciseTile(ExerciseModel exercise) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.fitness_center),
        ),
        title: Text(
          exercise.exerciseName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text("Sets : ${exercise.sets}"),
            Text("Reps : ${exercise.reps}"),
            Text("Weight : ${exercise.weight} kg"),
            Text("Rest : ${exercise.rest} sec"),
          ],
        ),
      ),
    );
  }

  Widget workoutCard(WorkoutModel workout) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            Text(
              workout.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Chip(
              label: Text(workout.day),
              avatar: const Icon(Icons.calendar_today),
            ),

            const SizedBox(height: 15),

            const Divider(),

            ...workout.exercises.map(
              (exercise) => exerciseTile(exercise),
            ),

          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Workouts"),
      ),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadWorkouts,
              child: workouts.isEmpty
                  ? const Center(
                      child: Text(
                        "No workouts assigned",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding:
                          const EdgeInsets.all(16),
                      itemCount: workouts.length,
                      itemBuilder: (_, index) {
                        return workoutCard(
                          workouts[index],
                        );
                      },
                    ),
            ),
    );
  }
}