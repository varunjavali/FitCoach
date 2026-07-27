import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService authService = AuthService();

  bool obscure = true;
  bool loading = false;

  //---------------------------------------------------------
  // Theme constants — shared across the app
  //---------------------------------------------------------

  static final _accent = Colors.greenAccent.shade400;

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    try {
      setState(() {
        loading = true;
      });

      final response = await authService.login(
        
        emailController.text.trim(),
        passwordController.text.trim(),
        
      );
      print(response);

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString("token", response["token"]);
      await prefs.setString("trainerName", response["trainer"]["name"]);
      await prefs.setString("trainerId", response["trainer"]["_id"]);
      print("Saved Trainer ID: ${prefs.getString("trainerId")}");

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"]),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(context, "/dashboard");
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst("Exception: ", ""),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [

          //-------------------------------------------------
          // Animated Background Gradient
          //-------------------------------------------------

          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xff0F2027),
                  Color(0xff203A43),
                  Color(0xff2C5364),
                ],
              ),
            ),
          ),

          //-------------------------------------------------
          // Floating Decorative Circles
          //-------------------------------------------------

          Positioned(
            top: -100,
            left: -70,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ).animate().scale(duration: 1500.ms),
          ),

          Positioned(
            bottom: -120,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ).animate().fadeIn(),
          ),

          //-------------------------------------------------
          // Center Login Card
          //-------------------------------------------------

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: GlassmorphicContainer(
                width: size.width > 500 ? 420 : double.infinity,
                // Responsive height so short viewports never overflow.
                height: size.height > 680 ? 600 : size.height * 0.9,
                borderRadius: 30,
                blur: 20,
                alignment: Alignment.center,
                border: 1.5,
                linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(.18),
                    Colors.white.withOpacity(.08),
                  ],
                ),
                borderGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(.40),
                    Colors.white.withOpacity(.15),
                  ],
                ),
                // Own scroll view so content that's ever taller than
                // the card scrolls instead of overflowing.
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      //-------------------------------------------------
                      // Logo
                      //-------------------------------------------------

                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(.10),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Icon(
                          Icons.fitness_center,
                          size: 46,
                          color: _accent,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 700.ms)
                          .scale(
                            begin: const Offset(.7, .7),
                            end: const Offset(1, 1),
                          ),

                      const SizedBox(height: 20),

                      //-------------------------------------------------
                      // App Name
                      //-------------------------------------------------

                      Text(
                        "FitCoach",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: .5, end: 0),

                      const SizedBox(height: 8),

                      Text(
                        "Trainer Login",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 35),

                      //-------------------------------------------------
                      // Email TextField
                      //-------------------------------------------------

                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Colors.white,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(.10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: _accent,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 500.ms).slideX(begin: -.2),

                      const SizedBox(height: 20),

                      //-------------------------------------------------
                      // Password TextField
                      //-------------------------------------------------

                      TextField(
                        controller: passwordController,
                        obscureText: obscure,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Colors.white,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscure = !obscure;
                              });
                            },
                            icon: Icon(
                              obscure ? Icons.visibility : Icons.visibility_off,
                              color: Colors.white,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(.10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: _accent,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 700.ms).slideX(begin: .2),

                      const SizedBox(height: 30),

                      //-------------------------------------------------
                      // Login Button
                      //-------------------------------------------------

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: loading ? null : login,
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
                                  "LOGIN",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                        ),
                      ).animate().fadeIn(delay: 900.ms).scale(),

                      const SizedBox(height: 15),

                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Registration screen coming next...",
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "Create Account",
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}