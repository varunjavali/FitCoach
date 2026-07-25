class DietModel {
  final String id;
  final String clientId;
  final String trainerId;
  final String title;
  final String day;
  final List<MealModel> meals;
  final int waterIntake;
  final String notes;

  DietModel({
    required this.id,
    required this.clientId,
    required this.trainerId,
    required this.title,
    required this.day,
    required this.meals,
    required this.waterIntake,
    required this.notes,
  });

  factory DietModel.fromJson(Map<String, dynamic> json) {
    return DietModel(
      id: json["_id"]?.toString() ?? "",
      clientId: json["client"] is Map
          ? json["client"]["_id"]
          : json["client"]?.toString() ?? "",
      trainerId: json["trainer"] is Map
          ? json["trainer"]["_id"]
          : json["trainer"]?.toString() ?? "",
      title: json["title"] ?? "",
      day: json["day"] ?? "",
      meals: (json["meals"] as List? ?? [])
          .map((e) => MealModel.fromJson(e))
          .toList(),
      waterIntake: json["waterIntake"] ?? 0,
      notes: json["notes"] ?? "",
    );
  }

  int get totalCalories =>
      meals.fold(0, (sum, meal) => sum + meal.calories);
}

class MealModel {
  final String mealType;
  final String food;
  final String quantity;
  final int calories;

  MealModel({
    required this.mealType,
    required this.food,
    required this.quantity,
    required this.calories,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      mealType: json["mealType"] ?? "",
      food: json["food"] ?? "",
      quantity: json["quantity"] ?? "",
      calories: json["calories"] ?? 0,
    );
  }
}