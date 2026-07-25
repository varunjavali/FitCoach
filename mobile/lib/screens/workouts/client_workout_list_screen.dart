import 'package:fit_coach/screens/workouts/add_workout_screen.dart';
import 'package:fit_coach/screens/workouts/workout_details_screen.dart'
    show WorkoutDetailScreen;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/client_model.dart';
import '../../models/workout_model.dart';
import '../../services/workout_service.dart';

class ClientWorkoutListScreen extends StatefulWidget {
  final ClientModel client;

  const ClientWorkoutListScreen({super.key, required this.client});

  @override
  State<ClientWorkoutListScreen> createState() =>
      _ClientWorkoutListScreenState();
}

class _ClientWorkoutListScreenState extends State<ClientWorkoutListScreen> {
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

      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("Login expired");
      }

      final data = await workoutService.getClientWorkouts(
        token,
        widget.client.id,
      );

      setState(() {
        workouts = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget workoutCard(WorkoutModel workout) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.fitness_center)),
        title: Text(
          workout.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Day : ${workout.day}"),
            Text("${workout.exercises.length} Exercises"),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == "edit") {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddWorkoutScreen(workout: workout),
                ),
              );

              if (result == true) {
                await loadWorkouts();
              }
            }

            if (value == "delete") {
              await deleteWorkout(workout.id);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem<String>(value: "edit", child: Text("Edit")),
            PopupMenuItem<String>(value: "delete", child: Text("Delete")),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WorkoutDetailScreen(workout: workout),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.client.name}'s Workouts")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddWorkoutScreen()),
          );

          if (result == true) {
            loadWorkouts();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text("Assign Workout"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadWorkouts,
              child: workouts.isEmpty
                  ? const Center(
                      child: Text(
                        "No workouts assigned",
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(15),
                      itemCount: workouts.length,
                      itemBuilder: (_, index) {
                        return workoutCard(workouts[index]);
                      },
                    ),
            ),
    );
  }

  Future<void> deleteWorkout(String workoutId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Workout"),
        content: const Text("Are you sure you want to delete this workout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("Login expired");
      }

      await workoutService.deleteWorkout(token, workoutId);

      loadWorkouts();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Workout deleted"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
