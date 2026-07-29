import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/client_model.dart';
import '../../models/membership_model.dart';
import '../../services/membership_service.dart';

class RenewMembershipScreen extends StatefulWidget {
  final ClientModel client;

  const RenewMembershipScreen({
    super.key,
    required this.client,
  });

  @override
  State<RenewMembershipScreen> createState() =>
      _RenewMembershipScreenState();
}

class _RenewMembershipScreenState
    extends State<RenewMembershipScreen> {
  final _formKey = GlobalKey<FormState>();

  final MembershipService _membershipService =
      MembershipService();

  final TextEditingController totalFeesController =
      TextEditingController();

  final TextEditingController amountPaidController =
      TextEditingController();

  final TextEditingController remarksController =
      TextEditingController();

  final List<String> badges = [
    "Basic",
    "Silver",
    "Gold",
    "Premium"
  ];

  final List<int> durations = [1, 3, 6, 12];

  String selectedBadge = "Basic";
  int selectedDuration = 1;

  double balance = 0;

  bool loading = false;

  void calculateBalance() {
    final total =
        double.tryParse(totalFeesController.text) ?? 0;

    final paid =
        double.tryParse(amountPaidController.text) ?? 0;

    setState(() {
      balance = total - paid;

      if (balance < 0) {
        balance = 0;
      }
    });
  }

  Future<void> renewMembership() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    try {
      final prefs =
          await SharedPreferences.getInstance();

      final token = prefs.getString("token") ?? "";

      final membership = MembershipModel(
        id: "",
        clientId: widget.client.id,
        trainerId: "",
        badge: selectedBadge,
        durationMonths: selectedDuration,
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        totalFees:
            double.parse(totalFeesController.text),
        amountPaid:
            double.parse(amountPaidController.text),
        balanceDue: balance,
        status: "Active",
        remarks: remarksController.text,
      );

      await _membershipService.renewMembership(
        token: token,
        clientId: widget.client.id,
        membership: membership,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Membership renewed successfully"),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Renew Membership"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: selectedBadge,
              decoration: const InputDecoration(
                labelText: "Membership Badge",
              ),
              items: badges
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedBadge = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<int>(
              value: selectedDuration,
              decoration: const InputDecoration(
                labelText: "Duration",
              ),
              items: durations
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text("$e Month"),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedDuration = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: totalFeesController,
              keyboardType:
                  TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Total Fees",
              ),
              onChanged: (_) => calculateBalance(),
              validator: (value) {
                if (value == null ||
                    value.isEmpty) {
                  return "Enter total fees";
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: amountPaidController,
              keyboardType:
                  TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Amount Paid",
              ),
              onChanged: (_) => calculateBalance(),
              validator: (value) {
                if (value == null ||
                    value.isEmpty) {
                  return "Enter amount paid";
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            Text(
              "Balance Due: ₹${balance.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: remarksController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Remarks",
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed:
                    loading ? null : renewMembership,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text(
                        "Renew Membership",
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}