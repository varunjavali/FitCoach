class PaymentModel {
  final String id;

  final String trainerId;

  final String clientId;

  final String clientName;

  final String clientPhone;

  final String clientEmail;

  final String receiptNo;

  final double amount;

  final String paymentMethod;

  final String paymentType;

  final String status;

  final String remarks;

  final DateTime createdAt;

  final DateTime updatedAt;

  PaymentModel({
    required this.id,
    required this.trainerId,
    required this.clientId,
    required this.clientName,
    required this.clientPhone,
    required this.clientEmail,
    required this.receiptNo,
    required this.amount,
    required this.paymentMethod,
    required this.paymentType,
    required this.status,
    required this.remarks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    final client = json["client"] ?? {};

    return PaymentModel(
      id: json["_id"] ?? "",

      trainerId: json["trainer"]?.toString() ?? "",

      clientId: client["_id"] ?? "",

      clientName: client["name"] ?? "",

      clientPhone: client["phone"] ?? "",

      clientEmail: client["email"] ?? "",

      receiptNo: json["receiptNo"] ?? "",

      amount: (json["amount"] as num?)?.toDouble() ?? 0.0,

      paymentMethod: json["paymentMethod"] ?? "",

      paymentType: json["paymentType"] ?? "",

      status: json["status"] ?? "",

      remarks: json["remarks"] ?? "",

      createdAt: DateTime.parse(json["createdAt"]),

      updatedAt: DateTime.parse(json["updatedAt"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "trainer": trainerId,
      "client": clientId,
      "receiptNo": receiptNo,
      "amount": amount,
      "paymentMethod": paymentMethod,
      "paymentType": paymentType,
      "status": status,
      "remarks": remarks,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }

  PaymentModel copyWith({
    String? id,
    String? trainerId,
    String? clientId,
    String? clientName,
    String? clientPhone,
    String? clientEmail,
    String? receiptNo,
    double? amount,
    String? paymentMethod,
    String? paymentType,
    String? status,
    String? remarks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      trainerId: trainerId ?? this.trainerId,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      clientEmail: clientEmail ?? this.clientEmail,
      receiptNo: receiptNo ?? this.receiptNo,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentType: paymentType ?? this.paymentType,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}