import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/payment_model.dart';
import '../../services/payment_service.dart';

class PaymentDetailScreen extends StatefulWidget {
  final String paymentId;

  const PaymentDetailScreen({
    super.key,
    required this.paymentId,
  });

  @override
  State<PaymentDetailScreen> createState() =>
      _PaymentDetailScreenState();
}

class _PaymentDetailScreenState
    extends State<PaymentDetailScreen> {
  final PaymentService _paymentService =
      PaymentService();

  PaymentModel? payment;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadPayment();
  }

  Future<void> loadPayment() async {
    try {
      final prefs =
          await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("Login expired");
      }

      final result =
          await _paymentService.getPayment(
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<void> deletePayment() async {
    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Delete Payment",
        ),
        content: const Text(
          "Are you sure you want to delete this payment?",
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final prefs =
          await SharedPreferences.getInstance();

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
          content: Text(
            "Payment deleted successfully",
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
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

  Widget detailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.indigo,
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
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

  Widget receiptCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [

            const Icon(
              Icons.receipt_long,
              size: 55,
              color: Colors.indigo,
            ),

            const SizedBox(height: 12),

            Text(
              payment!.receiptNo,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
                        const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: statusColor(payment!.status)
                    .withOpacity(0.15),
                borderRadius:
                    BorderRadius.circular(30),
              ),
              child: Text(
                payment!.status,
                style: TextStyle(
                  color: statusColor(payment!.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (payment == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Payment Details"),
        ),
        body: const Center(
          child: Text(
            "Payment not found",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: deletePayment,
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            receiptCard(),

            const SizedBox(height: 20),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [

                    detailRow(
                      Icons.person,
                      "Client",
                      payment!.clientName,
                    ),

                    const Divider(),

                    detailRow(
                      Icons.phone,
                      "Phone",
                      payment!.clientPhone,
                    ),

                    const Divider(),

                    detailRow(
                      Icons.email,
                      "Email",
                      payment!.clientEmail,
                    ),

                    const Divider(),

                    detailRow(
                      Icons.currency_rupee,
                      "Amount",
                      "₹${payment!.amount.toStringAsFixed(2)}",
                    ),
                                        const Divider(),

                    detailRow(
                      Icons.account_balance_wallet,
                      "Payment Method",
                      payment!.paymentMethod,
                    ),

                    const Divider(),

                    detailRow(
                      Icons.category,
                      "Payment Type",
                      payment!.paymentType,
                    ),

                    const Divider(),

                    detailRow(
                      Icons.note,
                      "Remarks",
                      payment!.remarks.isEmpty
                          ? "No remarks"
                          : payment!.remarks,
                    ),

                    const Divider(),

                    detailRow(
                      Icons.calendar_today,
                      "Payment Date",
                      DateFormat(
                        "dd MMM yyyy",
                      ).format(
                        payment!.createdAt,
                      ),
                    ),

                    const Divider(),

                    detailRow(
                      Icons.access_time,
                      "Payment Time",
                      DateFormat(
                        "hh:mm a",
                      ).format(
                        payment!.createdAt,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Receipt printing will be available soon.",
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.print,
                ),
                label: const Text(
                  "Print Receipt",
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: deletePayment,
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                label: const Text(
                  "Delete Payment",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}