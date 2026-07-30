import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/payment_model.dart';
import '../../services/payment_service.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final PaymentService _paymentService = PaymentService();

  List<PaymentModel> payments = [];

  double totalFees = 0;
  double amountPaid = 0;
  double balanceDue = 0;

  bool loading = true;
  String? error;

  static const _bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xff0F2027), Color(0xff203A43), Color(0xff2C5364)],
  );

  static final _accent = Colors.greenAccent.shade400;

  @override
  void initState() {
    super.initState();
    loadPayments();
  }

  Future<void> loadPayments() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("clientToken");

      if (token == null) {
        throw Exception("Please login again");
      }

      final data = await _paymentService.getPaymentHistory(token);

      final summary = data["summary"];

      setState(() {
        totalFees = (summary["totalFees"] ?? 0).toDouble();
        amountPaid = (summary["amountPaid"] ?? 0).toDouble();
        balanceDue = (summary["balanceDue"] ?? 0).toDouble();

        payments = data["payments"];

        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  String formatDate(DateTime date) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  Widget glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(.18)),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(.12),
                Colors.white.withOpacity(.05),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget summaryTile(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(.18),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget glassAppBar() {
    return AppBar(
      backgroundColor: Colors.white.withOpacity(.08),
      elevation: 0,
      title: Text(
        "Payment History",
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: _bgGradient),
          child: Center(child: CircularProgressIndicator(color: _accent)),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: glassAppBar(),
        body: Center(
          child: Text(error!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: glassAppBar(),
      body: Container(
        decoration: const BoxDecoration(gradient: _bgGradient),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: loadPayments,
            color: _accent,
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                glassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Payment Summary",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          summaryTile(
                            "Fees",
                            "₹${totalFees.toStringAsFixed(0)}",
                            Icons.currency_rupee,
                            Colors.blueAccent,
                          ),

                          summaryTile(
                            "Paid",
                            "₹${amountPaid.toStringAsFixed(0)}",
                            Icons.check_circle,
                            Colors.greenAccent,
                          ),

                          summaryTile(
                            "Balance",
                            "₹${balanceDue.toStringAsFixed(0)}",
                            Icons.account_balance_wallet,
                            Colors.orangeAccent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                Text(
                  "Payment History",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 15),

                if (payments.isEmpty)
                  glassCard(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Text(
                          "No payment history found.",
                          style: GoogleFonts.poppins(color: Colors.white70),
                        ),
                      ),
                    ),
                  )
                else
                  ...payments.map((payment) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: glassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  payment.status == "Success"
                                      ? Icons.check_circle
                                      : Icons.pending,
                                  color: payment.status == "Success"
                                      ? Colors.greenAccent
                                      : Colors.orangeAccent,
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Text(
                                    payment.status,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                Text(
                                  "₹${payment.amount.toStringAsFixed(0)}",
                                  style: GoogleFonts.poppins(
                                    color: Colors.greenAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            const SizedBox(height: 18),

                            Text(
                              "Receipt No : ${payment.receiptNo}",
                              style: GoogleFonts.poppins(color: Colors.white70),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "Date : ${formatDate(payment.createdAt)}",
                              style: GoogleFonts.poppins(color: Colors.white70),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "Method : ${payment.paymentMethod}",
                              style: GoogleFonts.poppins(color: Colors.white70),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "Type : ${payment.paymentType}",
                              style: GoogleFonts.poppins(color: Colors.white70),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "Status : ${payment.status}",
                              style: GoogleFonts.poppins(color: Colors.white70),
                            ),

                            if (payment.remarks.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                "Remarks : ${payment.remarks}",
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
