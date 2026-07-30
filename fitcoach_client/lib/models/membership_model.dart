
class MembershipModel {
  final String id;
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
    required this.badge,
    required this.durationMonths,
    required this.startDate,
    required this.endDate,
    required this.totalFees,
    required this.amountPaid,
    required this.balanceDue,
    required this.status,
    required this.remarks,
  });

  factory MembershipModel.fromJson(Map<String, dynamic> json) {
    return MembershipModel(
      id: json["_id"] ?? "",
      badge: json["badge"] ?? "",
      durationMonths: json["durationMonths"] ?? 0,
      startDate: DateTime.parse(json["startDate"]),
      endDate: DateTime.parse(json["endDate"]),
      totalFees: (json["totalFees"] ?? 0).toDouble(),
      amountPaid: (json["amountPaid"] ?? 0).toDouble(),
      balanceDue: (json["balanceDue"] ?? 0).toDouble(),
      status: json["status"] ?? "",
      remarks: json["remarks"] ?? "",
    );
  }
}