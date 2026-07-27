import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  //---------------------------------------------------------
  // Theme constants — shared across the app
  //---------------------------------------------------------

  static const _bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xff0F2027),
      Color(0xff203A43),
      Color(0xff2C5364),
    ],
  );

  static final Color _accent = Colors.greenAccent.shade400;

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

  //---------------------------------------------------------
  // Themed input decoration — shared by all fields + dropdowns
  //---------------------------------------------------------

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  Widget _glassCard({required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(.12),
                Colors.white.withOpacity(.05),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(.18)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget titleField() {
    return TextFormField(
      controller: titleController,
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Workout title required";
        }

        return null;
      },
      decoration: _decoration("Workout Title"),
    );
  }

  Widget dayDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedDay,
      dropdownColor: const Color(0xff203A43),
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: Colors.white70,
      decoration: _decoration("Day"),
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
      dropdownColor: const Color(0xff203A43),
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: Colors.white70,
      decoration: _decoration("Select Client"),
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

  PreferredSizeWidget _glassAppBar(String title) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: AppBar(
            backgroundColor: Colors.white.withOpacity(.08),
            elevation: 0,
            scrolledUnderElevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
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
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: _bgGradient),
          child: Center(
            child: CircularProgressIndicator(color: _accent),
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _glassAppBar(
        widget.workout == null ? "Add Workout" : "Edit Workout",
      ),
      body: Stack(
        children: [

          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(gradient: _bgGradient),
          ),

          Positioned(
            top: -90,
            right: -70,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),

          Positioned(
            bottom: -110,
            left: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.fromLTRB(20, kToolbarHeight + 14, 20, 20),
                children: [
                  titleField(),

                  const SizedBox(height: 18),

                  dayDropdown(),

                  const SizedBox(height: 18),

                  clientDropdown(),

                  const SizedBox(height: 25),

                  Text(
                    "Exercises",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  if (exercises.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          "No exercises added",
                          style: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),

                  ...List.generate(
                    exercises.length,
                    (index) => exerciseCard(index),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withOpacity(.30),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: addExercise,
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(
                        "Add Exercise",
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: loading ? null : saveWorkout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.black,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              widget.workout == null
                                  ? "SAVE WORKOUT"
                                  : "UPDATE WORKOUT",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: _glassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Small, clear icon so each exercise reads at a
                // glance.
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _accent.withOpacity(.16),
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: _accent,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "Exercise ${index + 1}",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),

                const Spacer(),

                IconButton(
                  onPressed: () => removeExercise(index),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            TextFormField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: _decoration("Exercise Name"),
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
                    style: const TextStyle(color: Colors.white),
                    decoration: _decoration("Sets"),
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
                    style: const TextStyle(color: Colors.white),
                    decoration: _decoration("Reps"),
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
                    style: const TextStyle(color: Colors.white),
                    decoration: _decoration("Weight"),
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
                    style: const TextStyle(color: Colors.white),
                    decoration: _decoration("Rest"),
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