import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/payment_model.dart';
import '../../services/payment_service.dart';

class PaymentDetailScreen extends StatefulWidget {
  final String paymentId;

  const PaymentDetailScreen({super.key, required this.paymentId});

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  final PaymentService _paymentService = PaymentService();

  PaymentModel? payment;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadPayment();
  }

  Future<void> loadPayment() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("Login expired");
      }

      final result = await _paymentService.getPayment(
        token,
        widget.paymentId,
      );

      setState(() {
        payment = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> deletePayment() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Payment"),
        content: const Text(
          "Are you sure you want to delete this payment? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("Login expired");
      }
      await _paymentService.deletePayment(
        token: token,
        paymentId: widget.paymentId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment deleted successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case "Success":
        return Colors.green;

      case "Cancelled":
        return Colors.red;

      case "Refunded":
        return Colors.orange;

      default:
        return Colors.grey;
    }
  }

  IconData statusIcon(String status) {
    switch (status) {
      case "Success":
        return Icons.check_circle_rounded;
      case "Cancelled":
        return Icons.cancel_rounded;
      case "Refunded":
        return Icons.replay_circle_filled_rounded;
      default:
        return Icons.hourglass_bottom_rounded;
    }
  }

  IconData methodIcon(String method) {
    switch (method.toLowerCase()) {
      case "cash":
        return Icons.payments_outlined;
      case "card":
        return Icons.credit_card_outlined;
      case "upi":
        return Icons.qr_code_scanner_outlined;
      case "bank transfer":
      case "bank":
        return Icons.account_balance_outlined;
      default:
        return Icons.wallet_outlined;
    }
  }

  Widget detailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.indigo, size: 20),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget sectionCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: List.generate(children.length * 2 - 1, (i) {
          if (i.isEven) return children[i ~/ 2];
          return Divider(height: 1, color: Colors.grey.shade100);
        }),
      ),
    );
  }

  Widget receiptHeader() {
    final color = statusColor(payment!.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade600, Colors.indigo.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long,
              size: 40,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            "₹${payment!.amount.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            "Receipt #${payment!.receiptNo}",
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 13.5,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon(payment!.status), color: color, size: 17),
                const SizedBox(width: 6),
                Text(
                  payment!.status,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (payment == null) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text("Payment Details"),
          backgroundColor: Colors.grey.shade50,
          elevation: 0,
          foregroundColor: Colors.black87,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 60,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 12),
              Text(
                "Payment not found",
                style: TextStyle(fontSize: 17, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Payment Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: deletePayment,
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            receiptHeader(),

            const SizedBox(height: 22),

            Text(
              "Client Information",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade500,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 10),

            sectionCard(
              children: [
                detailRow(Icons.person_outline, "Client", payment!.clientName),
                detailRow(Icons.phone_outlined, "Phone", payment!.clientPhone),
                detailRow(Icons.email_outlined, "Email", payment!.clientEmail),
              ],
            ),

            const SizedBox(height: 22),

            Text(
              "Payment Information",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade500,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 10),

            sectionCard(
              children: [
                detailRow(
                  methodIcon(payment!.paymentMethod),
                  "Payment Method",
                  payment!.paymentMethod,
                ),
                detailRow(
                  Icons.category_outlined,
                  "Payment Type",
                  payment!.paymentType,
                ),
                detailRow(
                  Icons.calendar_today_outlined,
                  "Payment Date",
                  DateFormat("dd MMM yyyy").format(payment!.createdAt),
                ),
                detailRow(
                  Icons.access_time_outlined,
                  "Payment Time",
                  DateFormat("hh:mm a").format(payment!.createdAt),
                ),
                detailRow(
                  Icons.note_outlined,
                  "Remarks",
                  payment!.remarks.isEmpty ? "No remarks" : payment!.remarks,
                ),
              ],
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Receipt printing will be available soon.",
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.print_outlined),
                label: const Text("Print Receipt"),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: deletePayment,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text(
                  "Delete Payment",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}