class PaymentModel {
  final String id;
  final double amount;
  final String paymentMethod;
  final String paymentType;
  final String status;
  final String receiptNo;
  final String remarks;
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    required this.paymentType,
    required this.status,
    required this.receiptNo,
    required this.remarks,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json["_id"]?.toString() ?? "",
      amount: (json["amount"] as num?)?.toDouble() ?? 0,
      paymentMethod: json["paymentMethod"]?.toString() ?? "",
      paymentType: json["paymentType"]?.toString() ?? "",
      status: json["status"]?.toString() ?? "",
      receiptNo: json["receiptNo"]?.toString() ?? "",
      remarks: json["remarks"]?.toString() ?? "",
      createdAt:
          DateTime.tryParse(json["createdAt"]?.toString() ?? "") ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "amount": amount,
      "paymentMethod": paymentMethod,
      "paymentType": paymentType,
      "status": status,
      "receiptNo": receiptNo,
      "remarks": remarks,
      "createdAt": createdAt.toIso8601String(),
    };
  }
}
