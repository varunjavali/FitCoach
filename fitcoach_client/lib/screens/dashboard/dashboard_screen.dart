import 'dart:ui';

import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'workout_screen.dart';
import 'diet_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';
import '../chat/client_chat_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    WorkoutScreen(),
    DietScreen(),
   // ProgressScreen(),
    ClientChatScreen(),
    ProfileScreen(),
  ];

  static final _accent = Colors.greenAccent.shade400;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: pages[currentIndex],

      //-------------------------------------------------
      // Glass Bottom Navigation Bar
      //-------------------------------------------------

      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xff0F2027).withOpacity(.55),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(.12)),
              ),
            ),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: Colors.transparent,
                elevation: 0,
                indicatorColor: _accent.withOpacity(.20),
                labelTextStyle: WidgetStateProperty.resolveWith(
                  (states) => TextStyle(
                    fontSize: 12,
                    fontWeight: states.contains(WidgetState.selected)
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: states.contains(WidgetState.selected)
                        ? _accent
                        : Colors.white54,
                  ),
                ),
                iconTheme: WidgetStateProperty.resolveWith(
                  (states) => IconThemeData(
                    color: states.contains(WidgetState.selected)
                        ? _accent
                        : Colors.white54,
                  ),
                ),
              ),
              child: NavigationBar(
                selectedIndex: currentIndex,

                onDestinationSelected: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },

                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home),
                    label: "Home",
                  ),

                  NavigationDestination(
                    icon: Icon(Icons.fitness_center),
                    label: "Workout",
                  ),

                  NavigationDestination(
                    icon: Icon(Icons.restaurant),
                    label: "Diet",
                  ),

                  // NavigationDestination(
                  //   icon: Icon(Icons.show_chart),
                  //   label: "Progress",
                  // ),

                  NavigationDestination(
                    icon: Icon(Icons.chat),
                    label: "Chat",
                  ),

                  NavigationDestination(
                    icon: Icon(Icons.person),
                    label: "Profile",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}