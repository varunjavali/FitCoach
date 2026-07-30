import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../models/membership_model.dart';
import '../../services/membership_service.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  final MembershipService _membershipService = MembershipService();

  MembershipModel? membership;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadMembership();
  }

  Future<void> loadMembership() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("clientToken");

      if (token == null) {
        throw Exception("Login expired");
      }

      final data = await _membershipService.getCurrentMembership(token);

      setState(() {
        membership = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Color get statusColor {
    switch (membership?.status) {
      case "Active":
        return Colors.green;
      case "Expired":
        return Colors.red;
      case "Cancelled":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String formatDate(DateTime date) {
    return DateFormat("dd MMM yyyy").format(date);
  }

  Widget infoTile(
    String title,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.greenAccent),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F2027),

      appBar: AppBar(
        title: const Text("My Membership"),
        centerTitle: true,
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : membership == null
              ? const Center(
                  child: Text(
                    "No Membership Found",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadMembership,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        color: const Color(0xff203A43),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor:
                                    statusColor.withOpacity(.2),
                                child: Icon(
                                  Icons.workspace_premium,
                                  color: statusColor,
                                  size: 42,
                                ),
                              ),

                              const SizedBox(height: 15),

                              Text(
                                membership!.badge,
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Chip(
                                backgroundColor: statusColor,
                                label: Text(
                                  membership!.status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              const Divider(height: 35),

                              infoTile(
                                "Duration",
                                "${membership!.durationMonths} Month(s)",
                                Icons.calendar_month,
                              ),

                              infoTile(
                                "Start Date",
                                formatDate(
                                  membership!.startDate,
                                ),
                                Icons.play_arrow,
                              ),

                              infoTile(
                                "Expiry Date",
                                formatDate(
                                  membership!.endDate,
                                ),
                                Icons.event_busy,
                              ),

                              infoTile(
                                "Total Fees",
                                "₹${membership!.totalFees.toStringAsFixed(0)}",
                                Icons.payments,
                              ),

                              infoTile(
                                "Amount Paid",
                                "₹${membership!.amountPaid.toStringAsFixed(0)}",
                                Icons.account_balance_wallet,
                              ),

                              infoTile(
                                "Balance Due",
                                "₹${membership!.balanceDue.toStringAsFixed(0)}",
                                Icons.warning_amber,
                              ),

                              if (membership!.remarks.isNotEmpty) ...[
                                const Divider(height: 35),

                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Remarks",
                                    style: TextStyle(
                                      color: Colors.grey.shade300,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  membership!.remarks,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}