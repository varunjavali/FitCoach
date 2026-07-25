class ClientModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final int? age;
  final String? gender;
  final double? height;
  final double? weight;
  final String? goal;
  final DateTime? joiningDate;
  final String? medicalHistory;
  final String? notes;

  ClientModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.goal,
    this.joiningDate,
    this.medicalHistory,
    this.notes,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      age: json["age"],
      gender: json["gender"],
      height: json["height"] == null
          ? null
          : (json["height"] as num).toDouble(),
      weight: json["weight"] == null
          ? null
          : (json["weight"] as num).toDouble(),
      goal: json["goal"],
      joiningDate: json["joiningDate"] == null
          ? null
          : DateTime.parse(json["joiningDate"]),
      medicalHistory: json["medicalHistory"],
      notes: json["notes"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "phone": phone,
      "age": age,
      "gender": gender,
      "height": height,
      "weight": weight,
      "goal": goal,
      "joiningDate": joiningDate?.toIso8601String(),
      "medicalHistory": medicalHistory,
      "notes": notes,
    };
  }
}