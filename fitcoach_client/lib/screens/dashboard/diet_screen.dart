import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/diet_model.dart';
import '../../services/diet_service.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  final DietService dietService = DietService();

  List<DietModel> diets = [];

  bool loading = true;
  String? error;

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
    loadDiets();
  }

  Future<void> loadDiets() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("clientToken");

      if (token == null) {
        throw Exception("Please login again");
      }

      final data = await dietService.getMyDiets(token);

      setState(() {
        diets = data;
        loading = false;
        error = null;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  IconData mealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case "breakfast":
        return Icons.free_breakfast;
      case "lunch":
        return Icons.lunch_dining;
      case "dinner":
        return Icons.dinner_dining;
      case "snack":
      case "snacks":
        return Icons.cookie;
      default:
        return Icons.restaurant;
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

  // Small pill chip used for day / calories / water — icons kept
  // compact (14px) so they read as labels, not focal points.
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

  Widget mealTile(MealModel meal) {
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
            // Small, clear icon circle — sized to feel like a label,
            // not compete with the calorie count.
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accent.withOpacity(.16),
              ),
              child: Icon(
                mealIcon(meal.mealType),
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
                    meal.mealType,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    meal.food,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Qty : ${meal.quantity}",
                    style: GoogleFonts.poppins(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${meal.calories}",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "kcal",
                  style: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget dietCard(DietModel diet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: _glassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    diet.title,
                    style: GoogleFonts.poppins(
                      fontSize: 19,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _pillChip(
                  icon: Icons.local_fire_department,
                  label: "${diet.totalCalories} kcal",
                  tint: _accent,
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                _pillChip(
                  icon: Icons.calendar_today,
                  label: diet.day,
                ),
                const SizedBox(width: 8),
                _pillChip(
                  icon: Icons.water_drop,
                  label: "${diet.waterIntake} L water",
                  tint: Colors.lightBlueAccent.shade200,
                ),
              ],
            ),

            const SizedBox(height: 16),

            Divider(color: Colors.white.withOpacity(.12)),

            const SizedBox(height: 4),

            ...diet.meals.map((meal) => mealTile(meal)),

            if (diet.notes.trim().isNotEmpty) ...[
              Divider(color: Colors.white.withOpacity(.12)),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.sticky_note_2_outlined,
                    size: 15,
                    color: Colors.white38,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      diet.notes,
                      style: GoogleFonts.poppins(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
      appBar: _glassAppBar("My Diet Plan"),
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
                    onRefresh: loadDiets,
                    color: _accent,
                    backgroundColor: const Color(0xff203A43),
                    child: error != null
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.only(top: kToolbarHeight),
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * .5,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                    ),
                                    child: Text(
                                      error!,
                                      style: GoogleFonts.poppins(
                                        color: Colors.redAccent.shade100,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : diets.isEmpty
                            ? ListView(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                padding:
                                    EdgeInsets.only(top: kToolbarHeight),
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context)
                                            .size
                                            .height *
                                        .5,
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 64,
                                            height: 64,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white
                                                  .withOpacity(.08),
                                            ),
                                            child: const Icon(
                                              Icons.restaurant_outlined,
                                              color: Colors.white54,
                                              size: 28,
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          Text(
                                            "No diet plan assigned",
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
                                itemCount: diets.length,
                                itemBuilder: (_, index) {
                                  return dietCard(diets[index]);
                                },
                              ),
                  ),
          ),
        ],
      ),
    );
  }
}