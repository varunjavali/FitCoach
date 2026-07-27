import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final totalFeesController = TextEditingController();
  final amountPaidController = TextEditingController();

  String gender = "Male";

  bool loading = false;

  final ClientService clientService = ClientService();

  //---------------------------------------------------------
  // Theme constants — shared across the app
  //---------------------------------------------------------

  static const _bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xff0F2027), Color(0xff203A43), Color(0xff2C5364)],
  );

  static final _accent = Colors.greenAccent.shade400;

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

      final totalFees = totalFeesController.text.trim().isEmpty
          ? 0.0
          : double.parse(totalFeesController.text.trim());

      final amountPaid = amountPaidController.text.trim().isEmpty
          ? 0.0
          : double.parse(amountPaidController.text.trim());

      if (amountPaid > totalFees) {
        throw Exception("Amount Paid cannot be greater than Total Fees");
      }

      final balanceDue = totalFees - amountPaid;

      final client = ClientModel(
        id: "",
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        age: ageController.text.isEmpty ? null : int.parse(ageController.text),
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
        totalFees: totalFees,
        amountPaid: amountPaid,
        balanceDue: balanceDue,
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
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  //---------------------------------------------------------
  // Themed input decoration — shared by all fields + dropdown
  //---------------------------------------------------------

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
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
        style: const TextStyle(color: Colors.white),
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
        decoration: _decoration(label),
      ),
    );
  }

  PreferredSizeWidget _glassAppBar(String title) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: AppBar(
            backgroundColor: Colors.white.withOpacity(.08),
            elevation: 0,
            scrolledUnderElevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
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
    totalFeesController.dispose();
    amountPaidController.dispose();
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
      extendBodyBehindAppBar: true,
      appBar: _glassAppBar("Add Client"),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(gradient: _bgGradient),
          ),

          Positioned(
            top: -90,
            right: -70,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),

          Positioned(
            bottom: -110,
            left: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.fromLTRB(20, kToolbarHeight + 16, 20, 20),
                children: [
                  textField(nameController, "Name", TextInputType.name),

                  textField(
                    emailController,
                    "Email",
                    TextInputType.emailAddress,
                  ),

                  textField(phoneController, "Phone", TextInputType.phone),

                  textField(ageController, "Age", TextInputType.number),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: DropdownButtonFormField<String>(
                      value: gender,
                      dropdownColor: const Color(0xff203A43),
                      style: const TextStyle(color: Colors.white),
                      iconEnabledColor: Colors.white70,
                      decoration: _decoration("Gender"),
                      items: const [
                        DropdownMenuItem(value: "Male", child: Text("Male")),
                        DropdownMenuItem(
                          value: "Female",
                          child: Text("Female"),
                        ),
                        DropdownMenuItem(value: "Other", child: Text("Other")),
                      ],
                      onChanged: (value) {
                        setState(() {
                          gender = value!;
                        });
                      },
                    ),
                  ),

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

                  textField(goalController, "Goal", TextInputType.text),

                  textField(
                    medicalController,
                    "Medical History",
                    TextInputType.multiline,
                  ),

                  textField(notesController, "Notes", TextInputType.multiline),
                  textField(
                    totalFeesController,
                    "Total Fees",
                    TextInputType.number,
                  ),

                  textField(
                    amountPaidController,
                    "Amount Paid",
                    TextInputType.number,
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: loading ? null : saveClient,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.black,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              "SAVE CLIENT",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
