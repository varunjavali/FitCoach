import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/client_model.dart';
import '../../services/client_service.dart';
import '../../services/payment_service.dart';

class AddPaymentScreen extends StatefulWidget {
  const AddPaymentScreen({super.key});

  @override
  State<AddPaymentScreen> createState() =>
      _AddPaymentScreenState();
}

class _AddPaymentScreenState
    extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  final ClientService _clientService =
      ClientService();

  final PaymentService _paymentService =
      PaymentService();

  final TextEditingController amountController =
      TextEditingController();

  final TextEditingController remarksController =
      TextEditingController();

  List<ClientModel> clients = [];

  ClientModel? selectedClient;

  bool loading = true;

  bool saving = false;

  String paymentMethod = "Cash";

  String paymentType = "Membership";

  final List<String> paymentMethods = [
    "Cash",
    "UPI",
    "Card",
    "Bank Transfer",
  ];

  final List<String> paymentTypes = [
    "Membership",
    "Renewal",
    "Balance",
    "Refund",
  ];

  @override
  void initState() {
    super.initState();
    loadClients();
  }

  Future<void> loadClients() async {
    try {
      final prefs =
          await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("Login expired");
      }

      final data =
          await _clientService.getClients(token);

      setState(() {
        clients = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<void> savePayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a client"),
        ),
      );

      return;
          }

    setState(() {
      saving = true;
    });

    try {
      final prefs =
          await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("Login expired");
      }

      await _paymentService.addPayment(
        token: token,
        clientId: selectedClient!.id,
        amount:
            double.parse(amountController.text.trim()),
        paymentMethod: paymentMethod,
        paymentType: paymentType,
        remarks: remarksController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Payment added successfully",
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
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  Widget buildClientCard() {
    if (selectedClient == null) {
      return const SizedBox();
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(top: 15),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(
                selectedClient!.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(
                selectedClient!.phone,
              ),
            ),

            const Divider(),

            Row(
              children: [

                Expanded(
                  child: infoTile(
                    "Membership",
                    selectedClient!.membershipBadge,
                  ),
                ),

                Expanded(
                  child: infoTile(
                    "Duration",
                    "${selectedClient!.membershipDuration} Month(s)",
                  ),
                ),
                                Expanded(
                  child: infoTile(
                    "Total Fees",
                    "₹${selectedClient!.totalFees.toStringAsFixed(0)}",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [

                Expanded(
                  child: infoTile(
                    "Paid",
                    "₹${selectedClient!.amountPaid.toStringAsFixed(0)}",
                  ),
                ),

                Expanded(
                  child: infoTile(
                    "Balance",
                    "₹${selectedClient!.balanceDue.toStringAsFixed(0)}",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget infoTile(
    String title,
    String value,
  ) {
    return Column(
      children: [

        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Receive Payment"),
      ),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding:
                    const EdgeInsets.all(16),

                children: [

                  DropdownButtonFormField<ClientModel>(
                    value: selectedClient,
                    decoration: const InputDecoration(
                      labelText: "Select Client",
                      border: OutlineInputBorder(),
                    ),

                    items: clients.map((client) {

                      return DropdownMenuItem(
                        value: client,
                        child: Text(
                          client.name,
                        ),
                      );

                    }).toList(),

                    onChanged: (client) {

                      setState(() {
                        selectedClient = client;
                      });

                    },
                  ),

                  buildClientCard(),

                  const SizedBox(height: 20),
                                    TextFormField(
                    controller: amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Amount",
                      prefixIcon: Icon(Icons.currency_rupee),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return "Enter amount";
                      }

                      final amount =
                          double.tryParse(value);

                      if (amount == null ||
                          amount <= 0) {
                        return "Enter valid amount";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  DropdownButtonFormField<String>(
                    value: paymentMethod,
                    decoration: const InputDecoration(
                      labelText: "Payment Method",
                      border: OutlineInputBorder(),
                    ),
                    items: paymentMethods
                        .map(
                          (method) =>
                              DropdownMenuItem(
                            value: method,
                            child: Text(method),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        paymentMethod = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  DropdownButtonFormField<String>(
                    value: paymentType,
                    decoration: const InputDecoration(
                      labelText: "Payment Type",
                      border: OutlineInputBorder(),
                    ),
                    items: paymentTypes
                        .map(
                          (type) =>
                              DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        paymentType = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: remarksController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: "Remarks",
                      hintText: "Optional",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed:
                          saving ? null : savePayment,
                      icon: saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.payments,
                            ),
                      label: Text(
                        saving
                            ? "Saving..."
                            : "Receive Payment",
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