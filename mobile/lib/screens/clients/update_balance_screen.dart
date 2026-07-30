import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/client_model.dart';
import '../../../services/client_service.dart';

class UpdateBalanceScreen extends StatefulWidget {
  final ClientModel client;

  const UpdateBalanceScreen({super.key, required this.client});

  @override
  State<UpdateBalanceScreen> createState() => _UpdateBalanceScreenState();
}

class _UpdateBalanceScreenState extends State<UpdateBalanceScreen> {
  final amountController = TextEditingController();
  String paymentMethod = "Cash";

  final remarksController = TextEditingController();

  bool loading = false;

  final ClientService clientService = ClientService();

  Future<void> updateBalance() async {
    try {
      setState(() {
        loading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("Login expired");
      }

      final amount = double.tryParse(amountController.text.trim());

      if (amount == null || amount <= 0) {
        throw Exception("Enter a valid amount");
      }

      final updated = await clientService.updateBalance(
        token,
        widget.client.id,
        amount,
        paymentMethod,
        remarksController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pop(context, updated);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Balance")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text("Total Fees"),
                trailing: Text(
                  "₹${widget.client.totalFees.toStringAsFixed(0)}",
                ),
              ),
            ),

            Card(
              child: ListTile(
                title: const Text("Amount Paid"),
                trailing: Text(
                  "₹${widget.client.amountPaid.toStringAsFixed(0)}",
                ),
              ),
            ),

            Card(
              child: ListTile(
                title: const Text("Balance Due"),
                trailing: Text(
                  "₹${widget.client.balanceDue.toStringAsFixed(0)}",
                ),
              ),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: "Receive Amount",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: paymentMethod,
              decoration: const InputDecoration(
                labelText: "Payment Method",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "Cash", child: Text("Cash")),
                DropdownMenuItem(value: "UPI", child: Text("UPI")),
                DropdownMenuItem(value: "Card", child: Text("Card")),
                DropdownMenuItem(value: "Bank", child: Text("Bank")),
              ],
              onChanged: (value) {
                setState(() {
                  paymentMethod = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            TextField(
              controller: remarksController,
              decoration: const InputDecoration(
                labelText: "Remarks",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: loading ? null : updateBalance,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("UPDATE PAYMENT"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
