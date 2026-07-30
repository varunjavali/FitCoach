import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/client_model.dart';
import '../../services/client_service.dart';
import '../../services/payment_service.dart';

class AddPaymentScreen extends StatefulWidget {
  const AddPaymentScreen({super.key});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  final ClientService _clientService = ClientService();

  final PaymentService _paymentService = PaymentService();

  final TextEditingController amountController = TextEditingController();

  final TextEditingController remarksController = TextEditingController();

  List<ClientModel> clients = [];

  ClientModel? selectedClient;

  bool loading = true;

  bool saving = false;

  String paymentMethod = "Cash";

  String paymentType = "Membership";

  final List<String> paymentMethods = ["Cash", "UPI", "Card", "Bank Transfer"];

  final List<String> paymentTypes = [
    "Membership",
    "Renewal",
    "Balance",
    "Refund",
  ];

  final Map<String, IconData> paymentMethodIcons = const {
    "Cash": Icons.payments_outlined,
    "UPI": Icons.qr_code_scanner_outlined,
    "Card": Icons.credit_card_outlined,
    "Bank Transfer": Icons.account_balance_outlined,
  };

  final Map<String, IconData> paymentTypeIcons = const {
    "Membership": Icons.card_membership_outlined,
    "Renewal": Icons.autorenew,
    "Balance": Icons.account_balance_wallet_outlined,
    "Refund": Icons.replay_circle_filled_outlined,
  };

  @override
  void initState() {
    super.initState();
    loadClients();
  }

  Future<void> loadClients() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("Login expired");
      }

      final data = await _clientService.getClients(token);

      setState(() {
        clients = data;
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

  Future<void> savePayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a client")),
      );

      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("Login expired");
      }

      await _paymentService.addPayment(
        token: token,
        clientId: selectedClient!.id,
        amount: double.parse(amountController.text.trim()),
        paymentMethod: paymentMethod,
        paymentType: paymentType,
        remarks: remarksController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment added successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  InputDecoration fieldDecoration(String label, {Widget? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.indigo, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget buildClientCard() {
    if (selectedClient == null) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.indigo.withOpacity(0.1),
                child: const Icon(Icons.person, color: Colors.indigo),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedClient!.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selectedClient!.phone,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  selectedClient!.membershipBadge,
                  style: const TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 14),

          Row(
            children: [
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

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: infoTile(
                  "Paid",
                  "₹${selectedClient!.amountPaid.toStringAsFixed(0)}",
                  valueColor: Colors.green,
                ),
              ),
              Expanded(
                child: infoTile(
                  "Balance",
                  "₹${selectedClient!.balanceDue.toStringAsFixed(0)}",
                  valueColor: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget infoTile(String title, String value, {Color? valueColor}) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15.5,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget chipSelector<T>({
    required List<T> items,
    required T selected,
    required String Function(T) label,
    required IconData Function(T) icon,
    required ValueChanged<T> onSelected,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) {
        final isSelected = item == selected;

        return GestureDetector(
          onTap: () => onSelected(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.indigo : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.indigo : Colors.grey.shade200,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon(item),
                  size: 17,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
                const SizedBox(width: 7),
                Text(
                  label(item),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Receive Payment",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),

                children: [
                  sectionLabel("Client"),

                  DropdownButtonFormField<ClientModel>(
                    value: selectedClient,
                    decoration: fieldDecoration(
                      "Select Client",
                      prefixIcon: const Icon(Icons.person_search_outlined),
                    ),
                    items: clients.map((client) {
                      return DropdownMenuItem(
                        value: client,
                        child: Text(client.name),
                      );
                    }).toList(),
                    onChanged: (client) {
                      setState(() {
                        selectedClient = client;
                      });
                    },
                  ),

                  buildClientCard(),

                  const SizedBox(height: 24),

                  sectionLabel("Amount"),

                  TextFormField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: fieldDecoration(
                      "Enter amount",
                      prefixIcon: const Icon(Icons.currency_rupee),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Enter amount";
                      }

                      final amount = double.tryParse(value);

                      if (amount == null || amount <= 0) {
                        return "Enter valid amount";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  sectionLabel("Payment Method"),

                  chipSelector<String>(
                    items: paymentMethods,
                    selected: paymentMethod,
                    label: (m) => m,
                    icon: (m) =>
                        paymentMethodIcons[m] ?? Icons.wallet_outlined,
                    onSelected: (m) {
                      setState(() => paymentMethod = m);
                    },
                  ),

                  const SizedBox(height: 24),

                  sectionLabel("Payment Type"),

                  chipSelector<String>(
                    items: paymentTypes,
                    selected: paymentType,
                    label: (t) => t,
                    icon: (t) => paymentTypeIcons[t] ?? Icons.category_outlined,
                    onSelected: (t) {
                      setState(() => paymentType = t);
                    },
                  ),

                  const SizedBox(height: 24),

                  sectionLabel("Remarks"),

                  TextFormField(
                    controller: remarksController,
                    maxLines: 4,
                    decoration: fieldDecoration("Optional notes"),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: saving ? null : savePayment,
                      icon: saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.payments),
                      label: Text(
                        saving ? "Saving..." : "Receive Payment",
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
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