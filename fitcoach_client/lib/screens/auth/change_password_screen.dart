import 'package:fitcoach_client/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

//import '../../services/auth_service.dart';
import '../dashboard/dashboard_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final AuthService authService = AuthService();

  bool loading = false;

  bool hideCurrent = true;
  bool hideNew = true;
  bool hideConfirm = true;

  Future<void> changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        loading = true;
      });

      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("clientToken");

      if (token == null) {
        throw Exception("Session expired. Please login again.");
      }

      final response = await authService.changePassword(
        token,
        currentPasswordController.text.trim(),
        newPasswordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"]),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Widget passwordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "$label is required";
          }

          if (label == "New Password" && value.length < 6) {
            return "Password must contain at least 6 characters";
          }

          if (label == "Confirm Password") {
            if (value != newPasswordController.text) {
              return "Passwords do not match";
            }
          }

          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: Icon(
              obscure
                  ? Icons.visibility
                  : Icons.visibility_off,
            ),
            onPressed: onToggle,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),

                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.lock_reset,
                    size: 55,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  "Create New Password",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "For your account security, please change your temporary password before continuing.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 35),

                passwordField(
                  label: "Current Password",
                  controller: currentPasswordController,
                  obscure: hideCurrent,
                  onToggle: () {
                    setState(() {
                      hideCurrent = !hideCurrent;
                    });
                  },
                ),

                passwordField(
                  label: "New Password",
                  controller: newPasswordController,
                  obscure: hideNew,
                  onToggle: () {
                    setState(() {
                      hideNew = !hideNew;
                    });
                  },
                ),

                passwordField(
                  label: "Confirm Password",
                  controller: confirmPasswordController,
                  obscure: hideConfirm,
                  onToggle: () {
                    setState(() {
                      hideConfirm = !hideConfirm;
                    });
                  },
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: loading ? null : changePassword,
                    child: loading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            "SAVE PASSWORD",
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
        ),
      ),
    );
  }
}