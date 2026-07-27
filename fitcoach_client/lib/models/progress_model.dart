class ProgressModel {
  final String id;
  final DateTime date;
  final double weight;
  final double height;
  final double bmi;
  final String notes;
  final String? photo;

  /// True for entries added while offline that haven't reached the
  /// server yet. Not sent to/from the backend — set locally only.
  final bool isPending;

  ProgressModel({
    required this.id,
    required this.date,
    required this.weight,
    required this.height,
    required this.bmi,
    this.notes = "",
    this.photo,
    this.isPending = false,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      id: json["_id"]?.toString() ?? "",
      date: DateTime.tryParse(json["date"] ?? "") ?? DateTime.now(),
      weight: (json["weight"] ?? 0).toDouble(),
      height: (json["height"] ?? 0).toDouble(),
      bmi: (json["bmi"] ?? 0).toDouble(),
      notes: json["notes"] ?? "",
      photo: (json["photo"] as String?)?.isEmpty ?? true
          ? null
          : json["photo"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "date": date.toIso8601String(),
      "weight": weight,
      "height": height,
      "bmi": bmi,
      "notes": notes,
      "photo": photo ?? "",
    };
  }

  /// Payload shape expected by POST /clients/progress.
  Map<String, dynamic> toRequestBody() {
    return {
      "date": date.toIso8601String(),
      "weight": weight,
      if (height > 0) "height": height,
      "notes": notes,
      "photo": photo ?? "",
    };
  }

  ProgressModel copyWith({bool? isPending}) {
    return ProgressModel(
      id: id,
      date: date,
      weight: weight,
      height: height,
      bmi: bmi,
      notes: notes,
      photo: photo,
      isPending: isPending ?? this.isPending,
    );
  }
}
