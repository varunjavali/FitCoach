import 'package:flutter/material.dart';

import '../../models/diet_model.dart';

class DietDetailScreen extends StatelessWidget {
  final DietModel diet;

  const DietDetailScreen({
    super.key,
    required this.diet,
  });

  @override
  Widget build(BuildContext context) {
    final totalCalories = diet.meals.fold<int>(
      0,
      (sum, meal) => sum + meal.calories,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(diet.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    diet.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 10),
                      Text("Day : ${diet.day}"),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(Icons.water_drop),
                      const SizedBox(width: 10),
                      Text("Water : ${diet.waterIntake} L"),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(Icons.local_fire_department),
                      const SizedBox(width: 10),
                      Text("Calories : $totalCalories kcal"),
                    ],
                  ),

                  if (diet.notes.isNotEmpty) ...[
                    const SizedBox(height: 15),
                    const Divider(),
                    const SizedBox(height: 10),

                    const Text(
                      "Notes",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(diet.notes),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            "Meals",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          ...diet.meals.map(
            (meal) => Card(
              margin: const EdgeInsets.only(bottom: 15),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(
                    meal.mealType.substring(0, 1),
                  ),
                ),
                title: Text(
                  meal.food,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text("Meal : ${meal.mealType}"),
                    Text("Quantity : ${meal.quantity}"),
                    Text("Calories : ${meal.calories} kcal"),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}