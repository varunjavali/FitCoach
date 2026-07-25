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
      meals: (json["meals"] as List<dynamic>? ?? [])
          .map((e) => MealModel.fromJson(e))
          .toList(),
      waterIntake: json["waterIntake"] ?? 3,
      notes: json["notes"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "client": clientId,
      "title": title,
      "day": day,
      "meals": meals.map((e) => e.toJson()).toList(),
      "waterIntake": waterIntake,
      "notes": notes,
    };
  }
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

  Map<String, dynamic> toJson() {
    return {
      "mealType": mealType,
      "food": food,
      "quantity": quantity,
      "calories": calories,
    };
  }
}