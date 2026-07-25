import 'package:flutter/material.dart';
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

  Widget mealTile(MealModel meal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withOpacity(.15),
          child: Icon(
            mealIcon(meal.mealType),
            color: Colors.green,
          ),
        ),
        title: Text(
          meal.mealType,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(meal.food),
            Text(
              "Qty : ${meal.quantity}",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${meal.calories}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Text(
              "kcal",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget dietCard(DietModel diet) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    diet.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    "${diet.totalCalories} kcal",
                  ),
                  backgroundColor: Colors.green.withOpacity(.15),
                ),
              ],
            ),

            const SizedBox(height: 5),

            Row(
              children: [
                Chip(
                  label: Text(diet.day),
                  avatar: const Icon(Icons.calendar_today),
                ),
                const SizedBox(width: 10),
                Chip(
                  label: Text("${diet.waterIntake} L water"),
                  avatar: const Icon(Icons.water_drop),
                  backgroundColor: Colors.blue.withOpacity(.1),
                ),
              ],
            ),

            const SizedBox(height: 15),

            const Divider(),

            ...diet.meals.map((meal) => mealTile(meal)),

            if (diet.notes.trim().isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.sticky_note_2_outlined,
                    size: 18,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      diet.notes,
                      style: const TextStyle(
                        color: Colors.grey,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Diet Plan"),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadDiets,
              child: error != null
                  ? ListView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height:
                              MediaQuery.of(context).size.height * .6,
                          child: Center(
                            child: Text(
                              error!,
                              style: const TextStyle(
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    )
                  : diets.isEmpty
                      ? ListView(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context)
                                      .size
                                      .height *
                                  .6,
                              child: const Center(
                                child: Text(
                                  "No diet plan assigned",
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: diets.length,
                          itemBuilder: (_, index) {
                            return dietCard(diets[index]);
                          },
                        ),
            ),
    );
  }
}