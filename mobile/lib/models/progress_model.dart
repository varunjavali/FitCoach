class ProgressModel {
  final String id;
  final String clientId;
  final String trainerId;
  final DateTime date;

  final double weight;
  final double height;
  final double bmi;

  final double bodyFat;
  final double chest;
  final double waist;
  final double biceps;
  final double forearm;
  final double thigh;
  final double shoulder;
  final double neck;

  final String photo;
  final String notes;

  ProgressModel({
    required this.id,
    required this.clientId,
    required this.trainerId,
    required this.date,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.bodyFat,
    required this.chest,
    required this.waist,
    required this.biceps,
    required this.forearm,
    required this.thigh,
    required this.shoulder,
    required this.neck,
    required this.photo,
    required this.notes,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      id: json["_id"]?.toString() ?? "",
      clientId: json["client"] is Map
          ? json["client"]["_id"]
          : json["client"]?.toString() ?? "",
      trainerId: json["trainer"] is Map
          ? json["trainer"]["_id"]
          : json["trainer"]?.toString() ?? "",
      date: DateTime.parse(
        json["date"] ?? DateTime.now().toIso8601String(),
      ),
      weight: (json["weight"] ?? 0).toDouble(),
      height: (json["height"] ?? 0).toDouble(),
      bmi: (json["bmi"] ?? 0).toDouble(),
      bodyFat: (json["bodyFat"] ?? 0).toDouble(),
      chest: (json["chest"] ?? 0).toDouble(),
      waist: (json["waist"] ?? 0).toDouble(),
      biceps: (json["biceps"] ?? 0).toDouble(),
      forearm: (json["forearm"] ?? 0).toDouble(),
      thigh: (json["thigh"] ?? 0).toDouble(),
      shoulder: (json["shoulder"] ?? 0).toDouble(),
      neck: (json["neck"] ?? 0).toDouble(),
      photo: json["photo"] ?? "",
      notes: json["notes"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "client": clientId,
      "date": date.toIso8601String(),
      "weight": weight,
      "height": height,
      "bmi": bmi,
      "bodyFat": bodyFat,
      "chest": chest,
      "waist": waist,
      "biceps": biceps,
      "forearm": forearm,
      "thigh": thigh,
      "shoulder": shoulder,
      "neck": neck,
      "photo": photo,
      "notes": notes,
    };
  }
}