import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/payment_model.dart';
import '../../services/payment_service.dart';
import 'add_payment_screen.dart';
import 'payment_detail_screen.dart';

class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({super.key});

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  final PaymentService _paymentService = PaymentService();

  List<PaymentModel> _payments = [];
  List<PaymentModel> _filteredPayments = [];

  bool _loading = true;

  final TextEditingController _searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    loadPayments();

    _searchController.addListener(() {
      filterPayments(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadPayments() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("Login expired");
      }

      final payments =
          await _paymentService.getPayments(token);

      setState(() {
        _payments = payments;
        _filteredPayments = payments;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  void filterPayments(String keyword) {
    if (keyword.trim().isEmpty) {
      setState(() {
        _filteredPayments = _payments;
      });
      return;
    }

    setState(() {
      _filteredPayments = _payments.where((payment) {
        return payment.clientName
            .toLowerCase()
            .contains(keyword.toLowerCase());
      }).toList();
    });
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

  Future<void> deletePayment(String paymentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Payment"),
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

      if (token == null) return;

      await _paymentService.deletePayment(
        token: token,
        paymentId: paymentId,
      );

      loadPayments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Widget paymentCard(PaymentModel payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      child: ListTile(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentDetailScreen(
                paymentId: payment.id,
              ),
            ),
          );

          loadPayments();
        },
        leading: CircleAvatar(
          backgroundColor:
              Colors.indigo.withOpacity(.1),
          child: const Icon(
            Icons.payments,
            color: Colors.indigo,
          ),
        ),
        title: Text(
          payment.clientName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(payment.receiptNo),
            Text(payment.paymentMethod),
            Text(payment.paymentType),
            Text(
              "₹${payment.amount.toStringAsFixed(2)}",
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: statusColor(
                  payment.status,
                ).withOpacity(.15),
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Text(
                payment.status,
                style: TextStyle(
                  color: statusColor(
                    payment.status,
                  ),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
            PopupMenuButton(
              onSelected: (value) {
                if (value == "delete") {
                  deletePayment(payment.id);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: "delete",
                  child: Text("Delete"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payments"),
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () async {
          final result =
              await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AddPaymentScreen(),
            ),
          );

          if (result == true) {
            loadPayments();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Payment"),
      ),

      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadPayments,
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.all(15),
                    child: TextField(
                      controller:
                          _searchController,
                      decoration:
                          InputDecoration(
                        hintText:
                            "Search Client",
                        prefixIcon:
                            const Icon(
                                Icons.search),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(12),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child:
                        _filteredPayments
                                .isEmpty
                            ? const Center(
                                child: Text(
                                  "No Payments Found",
                                  style:
                                      TextStyle(
                                    fontSize:
                                        18,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding:
                                    const EdgeInsets
                                        .fromLTRB(
                                        15,
                                        0,
                                        15,
                                        80),
                                itemCount:
                                    _filteredPayments
                                        .length,
                                itemBuilder:
                                    (_, index) {
                                  return paymentCard(
                                    _filteredPayments[
                                        index],
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
    );
  }
}