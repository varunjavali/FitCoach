import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/client_model.dart';
import '../../services/client_service.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final goalController = TextEditingController();
  final medicalController = TextEditingController();
  final notesController = TextEditingController();

  String gender = "Male";

  bool loading = false;

  final ClientService clientService = ClientService();

  Future<void> saveClient() async {
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

      final client = ClientModel(
        id: "",
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
      );

      await clientService.addClient(token, client);

      if (!mounted) return;

      Navigator.pop(context, true);
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
          if (label == "Name" ||
              label == "Email" ||
              label == "Phone") {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Client"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            textField(
              nameController,
              "Name",
              TextInputType.name,
            ),

            textField(
              emailController,
              "Email",
              TextInputType.emailAddress,
            ),

            textField(
              phoneController,
              "Phone",
              TextInputType.phone,
            ),

            textField(
              ageController,
              "Age",
              TextInputType.number,
            ),

            DropdownButtonFormField<String>(
              value: gender,
              decoration: const InputDecoration(
                labelText: "Gender",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Male",
                  child: Text("Male"),
                ),
                DropdownMenuItem(
                  value: "Female",
                  child: Text("Female"),
                ),
                DropdownMenuItem(
                  value: "Other",
                  child: Text("Other"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  gender = value!;
                });
              },
            ),

            const SizedBox(height: 15),

            textField(
              heightController,
              "Height (cm)",
              TextInputType.number,
            ),

            textField(
              weightController,
              "Weight (kg)",
              TextInputType.number,
            ),

            textField(
              goalController,
              "Goal",
              TextInputType.text,
            ),

            textField(
              medicalController,
              "Medical History",
              TextInputType.multiline,
            ),

            textField(
              notesController,
              "Notes",
              TextInputType.multiline,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: loading ? null : saveClient,
                child: loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "SAVE CLIENT",
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