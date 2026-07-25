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
    ProgressScreen(),
    ClientChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: NavigationBar(
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

          NavigationDestination(
            icon: Icon(Icons.show_chart),
            label: "Progress",
          ),

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
    );
  }
}