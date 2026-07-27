import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  static final _accent = Colors.greenAccent.shade400;

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

  //---------------------------------------------------------
  // Themed building blocks
  //---------------------------------------------------------

  Widget _glassCard({required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
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
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(.18)),
          ),
          child: child,
        ),
      ),
    );
  }

  // Small pill chip — icon kept compact (14px) so it reads as a
  // label, not a focal point.
  Widget _pillChip({
    required IconData icon,
    required String label,
    Color? tint,
  }) {
    final color = tint ?? Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Small stat with a tiny icon — used for sets/reps/weight/rest so
  // four numbers can sit in a row without visual clutter.
  Widget _statChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.white38),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget exerciseTile(ExerciseModel exercise) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(.10)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Small, clear icon circle so it reads as a label,
            // not a competing focal point.
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accent.withOpacity(.16),
              ),
              child: Icon(
                Icons.fitness_center,
                color: _accent,
                size: 17,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.exerciseName,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 14,
                    runSpacing: 6,
                    children: [
                      _statChip(Icons.repeat, "${exercise.sets} sets"),
                      _statChip(Icons.numbers, "${exercise.reps} reps"),
                      _statChip(
                        Icons.monitor_weight_outlined,
                        "${exercise.weight} kg",
                      ),
                      _statChip(
                        Icons.timer_outlined,
                        "${exercise.rest} sec rest",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget workoutCard(WorkoutModel workout) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: _glassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              workout.title,
              style: GoogleFonts.poppins(
                fontSize: 19,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            _pillChip(
              icon: Icons.calendar_today,
              label: workout.day,
            ),

            const SizedBox(height: 16),

            Divider(color: Colors.white.withOpacity(.12)),

            const SizedBox(height: 4),

            ...workout.exercises.map(
              (exercise) => exerciseTile(exercise),
            ),

          ],
        ),
      ),
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
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _glassAppBar("My Workouts"),
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
            child: loading
                ? Center(
                    child: CircularProgressIndicator(color: _accent),
                  )
                : RefreshIndicator(
                    onRefresh: loadWorkouts,
                    color: _accent,
                    backgroundColor: const Color(0xff203A43),
                    child: workouts.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.only(top: kToolbarHeight),
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * .5,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                              Colors.white.withOpacity(.08),
                                        ),
                                        child: const Icon(
                                          Icons.fitness_center_outlined,
                                          color: Colors.white54,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        "No workouts assigned",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white70,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: EdgeInsets.fromLTRB(
                              16,
                              kToolbarHeight + 16,
                              16,
                              16,
                            ),
                            itemCount: workouts.length,
                            itemBuilder: (_, index) {
                              return workoutCard(
                                workouts[index],
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}