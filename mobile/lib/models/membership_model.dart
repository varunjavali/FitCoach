class MembershipModel {
  final String id;
  final String clientId;
  final String trainerId;

  final String badge;
  final int durationMonths;

  final DateTime startDate;
  final DateTime endDate;

  final double totalFees;
  final double amountPaid;
  final double balanceDue;

  final String status;
  final String remarks;

  MembershipModel({
    required this.id,
    required this.clientId,
    required this.trainerId,
    required this.badge,
    required this.durationMonths,
    required this.startDate,
    required this.endDate,
    required this.totalFees,
    required this.amountPaid,
    required this.balanceDue,
    required this.status,
    this.remarks = "",
  });

  factory MembershipModel.fromJson(Map<String, dynamic> json) {
    return MembershipModel(
      id: json["_id"] ?? "",
      clientId: json["client"] ?? "",
      trainerId: json["trainer"] ?? "",
      badge: json["badge"] ?? "Basic",
      durationMonths: json["durationMonths"] ?? 1,
      startDate: DateTime.parse(json["startDate"]),
      endDate: DateTime.parse(json["endDate"]),
      totalFees: (json["totalFees"] as num?)?.toDouble() ?? 0,
      amountPaid: (json["amountPaid"] as num?)?.toDouble() ?? 0,
      balanceDue: (json["balanceDue"] as num?)?.toDouble() ?? 0,
      status: json["status"] ?? "Active",
      remarks: json["remarks"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "badge": badge,
      "durationMonths": durationMonths,
      "totalFees": totalFees,
      "amountPaid": amountPaid,
      "remarks": remarks,
    };
  }
}