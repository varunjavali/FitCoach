import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/client_model.dart';
import '../../services/client_service.dart';

class EditClientScreen extends StatefulWidget {
  final ClientModel client;

  const EditClientScreen({super.key, required this.client});

  @override
  State<EditClientScreen> createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  final _formKey = GlobalKey<FormState>();

  late final nameController =
      TextEditingController(text: widget.client.name);
  late final emailController =
      TextEditingController(text: widget.client.email);
  late final phoneController =
      TextEditingController(text: widget.client.phone);
  late final ageController = TextEditingController(
    text: widget.client.age?.toString() ?? "",
  );
  late final heightController = TextEditingController(
    text: widget.client.height?.toString() ?? "",
  );
  late final weightController = TextEditingController(
    text: widget.client.weight?.toString() ?? "",
  );
  late final goalController =
      TextEditingController(text: widget.client.goal ?? "");
  late final medicalController =
      TextEditingController(text: widget.client.medicalHistory ?? "");
  late final notesController =
      TextEditingController(text: widget.client.notes ?? "");
  late final amountPaidController = TextEditingController(
    text: widget.client.amountPaid.toStringAsFixed(0),
  );
  late final balanceDueController = TextEditingController(
    text: widget.client.balanceDue.toStringAsFixed(0),
  );

  late String gender = widget.client.gender ?? "Male";

  bool loading = false;

  final ClientService clientService = ClientService();

  Future<void> saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        loading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("Login expired");
      }

      final updated = ClientModel(
        id: widget.client.id,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        age: ageController.text.isEmpty
            ? null
            : int.parse(ageController.text),
        gender: gender,
        height: heightController.text.isEmpty
            ? null
            : double.parse(heightController.text),
        weight: weightController.text.isEmpty
            ? null
            : double.parse(weightController.text),
        goal: goalController.text.trim(),
        medicalHistory: medicalController.text.trim(),
        notes: notesController.text.trim(),
        amountPaid: double.tryParse(amountPaidController.text.trim()) ?? 0,
        balanceDue: double.tryParse(balanceDueController.text.trim()) ?? 0,
      );

      await clientService.updateClient(token, widget.client.id, updated);

      if (!mounted) return;

      Navigator.pop(context, updated);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget textField(
    TextEditingController controller,
    String label,
    TextInputType keyboard,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: (value) {
          if (label == "Name" || label == "Email" || label == "Phone") {
            if (value == null || value.trim().isEmpty) {
              return "$label is required";
            }
          }

          if (label == "Email" &&
              value != null &&
              value.isNotEmpty &&
              !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return "Enter a valid email";
          }

          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    goalController.dispose();
    medicalController.dispose();
    notesController.dispose();
    amountPaidController.dispose();
    balanceDueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Client"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            textField(nameController, "Name", TextInputType.name),
            textField(emailController, "Email", TextInputType.emailAddress),
            textField(phoneController, "Phone", TextInputType.phone),
            textField(ageController, "Age", TextInputType.number),

            DropdownButtonFormField<String>(
              value: gender,
              decoration: const InputDecoration(
                labelText: "Gender",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "Male", child: Text("Male")),
                DropdownMenuItem(value: "Female", child: Text("Female")),
                DropdownMenuItem(value: "Other", child: Text("Other")),
              ],
              onChanged: (value) {
                setState(() {
                  gender = value!;
                });
              },
            ),

            const SizedBox(height: 15),

            textField(heightController, "Height (cm)", TextInputType.number),
            textField(weightController, "Weight (kg)", TextInputType.number),
            textField(goalController, "Goal", TextInputType.text),
            textField(
              medicalController,
              "Medical History",
              TextInputType.multiline,
            ),
            textField(notesController, "Notes", TextInputType.multiline),

            const SizedBox(height: 10),

            const Text(
              "Payment",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: amountPaidController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: "Amount Paid (₹)",
                      prefixIcon: const Icon(
                        Icons.payments_outlined,
                        color: Colors.green,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: balanceDueController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: "Balance to be Paid (₹)",
                      prefixIcon: const Icon(
                        Icons.hourglass_empty,
                        color: Colors.orange,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: loading ? null : saveChanges,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "SAVE CHANGES",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}