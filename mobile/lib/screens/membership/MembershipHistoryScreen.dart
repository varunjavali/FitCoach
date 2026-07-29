import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/client_model.dart';
import '../../models/membership_model.dart';
import '../../services/membership_service.dart';

class MembershipHistoryScreen extends StatefulWidget {
  final ClientModel client;

  const MembershipHistoryScreen({
    super.key,
    required this.client,
  });

  @override
  State<MembershipHistoryScreen> createState() =>
      _MembershipHistoryScreenState();
}

class _MembershipHistoryScreenState
    extends State<MembershipHistoryScreen> {
  final MembershipService _service = MembershipService();

  List<MembershipModel> memberships = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      memberships = await _service.getHistory(
        token,
        widget.client.id,
      );
    } catch (e) {
      debugPrint(e.toString());
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  Color statusColor(String status) {
    switch (status) {
      case "Active":
        return Colors.green;
      case "Expired":
        return Colors.orange;
      case "Cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.client.name} Memberships"),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : memberships.isEmpty
              ? const Center(
                  child: Text("No membership history found"),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: memberships.length,
                  itemBuilder: (_, index) {
                    final m = memberships[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                Text(
                                  m.badge,
                                  style:
                                      const TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                Chip(
                                  label:
                                      Text(m.status),
                                  backgroundColor:
                                      statusColor(
                                        m.status,
                                      ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Text(
                                "Duration : ${m.durationMonths} Month(s)"),

                            Text(
                                "Fees : ₹${m.totalFees.toStringAsFixed(0)}"),

                            Text(
                                "Paid : ₹${m.amountPaid.toStringAsFixed(0)}"),

                            Text(
                                "Balance : ₹${m.balanceDue.toStringAsFixed(0)}"),

                            const SizedBox(height: 10),

                            Text(
                                "Start : ${formatDate(m.startDate)}"),

                            Text(
                                "End : ${formatDate(m.endDate)}"),

                            if (m.remarks.isNotEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.only(
                                        top: 8),
                                child: Text(
                                  "Remarks : ${m.remarks}",
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}