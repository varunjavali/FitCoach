import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/client_model.dart';
import '../../models/workout_model.dart';
import '../../services/client_service.dart';
import '../../services/workout_service.dart';

class AddWorkoutScreen extends StatefulWidget {
  final WorkoutModel? workout;

  const AddWorkoutScreen({super.key, this.workout});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  bool loadingClients = true;

  final WorkoutService workoutService = WorkoutService();
  final ClientService clientService = ClientService();

  final titleController = TextEditingController();

  List<ClientModel> clients = [];

  ClientModel? selectedClient;

  String selectedDay = "Monday";

  bool loading = false;
  //bool loadingClients = true;

  List<ExerciseModel> exercises = [];

  void addExercise() {
    setState(() {
      exercises.add(
        ExerciseModel(exerciseName: "", sets: 0, reps: 0, weight: 0, rest: 60),
      );
    });
  }

  void removeExercise(int index) {
    setState(() {
      exercises.removeAt(index);
    });
  }

  List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  @override
  void initState() {
    super.initState();

    loadClients();

    if (widget.workout != null) {
      titleController.text = widget.workout!.title;

      selectedDay = widget.workout!.day;

      exercises = widget.workout!.exercises
          .map(
            (e) => ExerciseModel(
              exerciseName: e.exerciseName,
              sets: e.sets,
              reps: e.reps,
              weight: e.weight,
              rest: e.rest,
            ),
          )
          .toList();
    } else {
      addExercise();
    }
  }

  Future<void> loadClients() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("Login expired");
      }

      final data = await clientService.getClients(token);

      setState(() {
        clients = data;

        if (widget.workout != null) {
          selectedClient = clients.firstWhere(
            (c) => c.id == widget.workout!.clientId,
            orElse: () => clients.first,
          );
        } else if (clients.isNotEmpty) {
          selectedClient = clients.first;
        }

        loadingClients = false;
      });
    } catch (e) {
      setState(() {
        loadingClients = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget titleField() {
    return TextFormField(
      controller: titleController,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Workout title required";
        }

        return null;
      },
      decoration: InputDecoration(
        labelText: "Workout Title",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget dayDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedDay,
      decoration: InputDecoration(
        labelText: "Day",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: days.map((day) {
        return DropdownMenuItem(value: day, child: Text(day));
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedDay = value!;
        });
      },
    );
  }

  Widget clientDropdown() {
    return DropdownButtonFormField<ClientModel>(
      value: selectedClient,
      decoration: InputDecoration(
        labelText: "Select Client",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: clients.map((client) {
        return DropdownMenuItem(value: client, child: Text(client.name));
      }).toList(),
      onChanged: (client) {
        setState(() {
          selectedClient = client;
        });
      },
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loadingClients) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout == null ? "Add Workout" : "Edit Workout"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            titleField(),

            const SizedBox(height: 18),

            dayDropdown(),

            const SizedBox(height: 18),

            clientDropdown(),

            const SizedBox(height: 25),

            const Text(
              "Exercises",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            if (exercises.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    "No exercises added",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),

            ...List.generate(exercises.length, (index) => exerciseCard(index)),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: addExercise,
                icon: const Icon(Icons.add),
                label: const Text("Add Exercise"),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: loading ? null : saveWorkout,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.workout == null
                            ? "SAVE WORKOUT"
                            : "UPDATE WORKOUT",
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget exerciseCard(int index) {
    final exercise = exercises[index];

    final nameController = TextEditingController(text: exercise.exerciseName);

    final setsController = TextEditingController(
      text: exercise.sets == 0 ? "" : exercise.sets.toString(),
    );

    final repsController = TextEditingController(
      text: exercise.reps == 0 ? "" : exercise.reps.toString(),
    );

    final weightController = TextEditingController(
      text: exercise.weight == 0 ? "" : exercise.weight.toString(),
    );

    final restController = TextEditingController(
      text: exercise.rest.toString(),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "Exercise ${index + 1}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const Spacer(),

                IconButton(
                  onPressed: () => removeExercise(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),

            const SizedBox(height: 10),

            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Exercise Name",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                exercises[index] = ExerciseModel(
                  exerciseName: value,
                  sets: exercise.sets,
                  reps: exercise.reps,
                  weight: exercise.weight,
                  rest: exercise.rest,
                );
              },
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: setsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Sets",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      exercises[index] = ExerciseModel(
                        exerciseName: exercises[index].exerciseName,
                        sets: int.tryParse(value) ?? 0,
                        reps: exercises[index].reps,
                        weight: exercises[index].weight,
                        rest: exercises[index].rest,
                      );
                    },
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: TextFormField(
                    controller: repsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Reps",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      exercises[index] = ExerciseModel(
                        exerciseName: exercises[index].exerciseName,
                        sets: exercises[index].sets,
                        reps: int.tryParse(value) ?? 0,
                        weight: exercises[index].weight,
                        rest: exercises[index].rest,
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Weight",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      exercises[index] = ExerciseModel(
                        exerciseName: exercises[index].exerciseName,
                        sets: exercises[index].sets,
                        reps: exercises[index].reps,
                        weight: double.tryParse(value) ?? 0,
                        rest: exercises[index].rest,
                      );
                    },
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: TextFormField(
                    controller: restController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Rest",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      exercises[index] = ExerciseModel(
                        exerciseName: exercises[index].exerciseName,
                        sets: exercises[index].sets,
                        reps: exercises[index].reps,
                        weight: exercises[index].weight,
                        rest: int.tryParse(value) ?? 60,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveWorkout() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedClient == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a client")));
      return;
    }

    if (exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Add at least one exercise")),
      );
      return;
    }

    for (final exercise in exercises) {
      if (exercise.exerciseName.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Exercise name cannot be empty")),
        );
        return;
      }
    }

    try {
      setState(() {
        loading = true;
      });

      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("Login expired");
      }

      final workout = WorkoutModel(
        id: "",
        clientId: selectedClient!.id,
        trainerId: "",
        title: titleController.text.trim(),
        day: selectedDay,
        exercises: exercises,
      );

      if (widget.workout == null) {
        await workoutService.addWorkout(token, workout);
      } else {
        await workoutService.updateWorkout(token, widget.workout!.id, workout);
      }

      if (!mounted) return;

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.workout == null
                ? "Workout Created Successfully"
                : "Workout Updated Successfully",
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
