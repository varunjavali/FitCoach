import 'membership_model.dart';

class DashboardModel {
  final Client client;
  final TodayWorkout? todayWorkout;
  final TodayDiet? todayDiet;
  final MembershipModel? membership;

  DashboardModel({
    required this.client,
    this.todayWorkout,
    this.todayDiet,
    this.membership,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      client: Client.fromJson(json["client"]),
      todayWorkout: json["todayWorkout"] == null
          ? null
          : TodayWorkout.fromJson(json["todayWorkout"]),
      todayDiet: json["todayDiet"] == null
          ? null
          : TodayDiet.fromJson(json["todayDiet"]),
      membership: json["membership"] == null
          ? null
          : MembershipModel.fromJson(json["membership"]),
    );
  }
}

class Client {
  final String id;
  final String name;
  final String email;
  final String phone;
  final int age;
  final String gender;
  final double height;
  final double weight;
  final String goal;
  final DateTime? joiningDate;

  final double totalFees;
  final double amountPaid;
  final double balanceDue;

  Client({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.goal,
    required this.totalFees,
    required this.amountPaid,
    required this.balanceDue,
    this.joiningDate,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json["_id"]?.toString() ??
          json["id"]?.toString() ??
          "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      age: json["age"] ?? 0,
      gender: json["gender"] ?? "",
      height: (json["height"] ?? 0).toDouble(),
      weight: (json["weight"] ?? 0).toDouble(),
      goal: json["goal"] ?? "",
      totalFees: (json["totalFees"] ?? 0).toDouble(),
      amountPaid: (json["amountPaid"] ?? 0).toDouble(),
      balanceDue: (json["balanceDue"] ?? 0).toDouble(),
      joiningDate: json["joiningDate"] == null
          ? null
          : DateTime.tryParse(json["joiningDate"]),
    );
  }
}

class TodayWorkout {
  final String id;
  final String title;
  final int exerciseCount;

  TodayWorkout({
    required this.id,
    required this.title,
    required this.exerciseCount,
  });

  factory TodayWorkout.fromJson(Map<String, dynamic> json) {
    return TodayWorkout(
      id: json["_id"]?.toString() ??
          json["id"]?.toString() ??
          "",
      title: json["title"] ?? "",
      exerciseCount: json["exerciseCount"] ?? 0,
    );
  }
}

class TodayDiet {
  final String id;
  final String title;
  final int calories;

  TodayDiet({
    required this.id,
    required this.title,
    required this.calories,
  });

  factory TodayDiet.fromJson(Map<String, dynamic> json) {
    return TodayDiet(
      id: json["_id"]?.toString() ??
          json["id"]?.toString() ??
          "",
      title: json["title"] ?? "",
      calories: json["calories"] ?? 0,
    );
  }
}