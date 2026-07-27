import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/login_screen.dart';
import '../dashboard/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  //---------------------------------------------------------
  // Theme constants — shared across the app
  //---------------------------------------------------------

  static const _bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xff0F2027),
      Color(0xff203A43),
      Color(0xff2C5364),
    ],
  );

  static final _accent = Colors.greenAccent.shade400;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {

    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("clientToken");

    if (!mounted) return;

    if (token != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          //-------------------------------------------------
          // Background gradient
          //-------------------------------------------------

          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(gradient: _bgGradient),
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
          // Center Content
          //-------------------------------------------------

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(.10),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: _accent,
                    size: 50,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 700.ms)
                    .scale(
                      begin: const Offset(.7, .7),
                      end: const Offset(1, 1),
                    ),

                const SizedBox(height: 30),

                Text(
                  "FitCoach",
                  style: GoogleFonts.poppins(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: .4, end: 0),

                const SizedBox(height: 8),

                Text(
                  "Your Personal Fitness Partner",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 45),

                SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    color: _accent,
                    strokeWidth: 2.5,
                  ),
                ).animate().fadeIn(delay: 700.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}