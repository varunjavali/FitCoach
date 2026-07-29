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
  String paymentMethod;

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
    required this.paymentMethod,
    required this.status,
    this.remarks = "",
  });

  factory MembershipModel.fromJson(Map<String, dynamic> json) {
    return MembershipModel(
      id: json["_id"]?.toString() ?? "",

      clientId: json["client"] is Map
          ? json["client"]["_id"]?.toString() ?? ""
          : json["client"]?.toString() ?? "",

      trainerId: json["trainer"] is Map
          ? json["trainer"]["_id"]?.toString() ?? ""
          : json["trainer"]?.toString() ?? "",

      badge: json["badge"] ?? "Basic",

      durationMonths: json["durationMonths"] ?? 1,

      startDate: DateTime.tryParse(json["startDate"] ?? "") ?? DateTime.now(),

      endDate: DateTime.tryParse(json["endDate"] ?? "") ?? DateTime.now(),

      totalFees: (json["totalFees"] as num?)?.toDouble() ?? 0,

      amountPaid: (json["amountPaid"] as num?)?.toDouble() ?? 0,

      balanceDue: (json["balanceDue"] as num?)?.toDouble() ?? 0,

      paymentMethod: json["paymentMethod"] ?? "Cash",

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
      "paymentMethod": paymentMethod,
    };
  }
}
