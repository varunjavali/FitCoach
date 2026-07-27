import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/dashboard_model.dart';
import '../../services/dashboard_service.dart';
import 'progress_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DashboardModel? dashboard;

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("clientToken");

      if (token == null) {
        setState(() {
          loading = false;
          error = "Login expired";
        });
        return;
      }

      final data = await DashboardService().getDashboard(token);

      setState(() {
        dashboard = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  double get bmi {
    if (dashboard == null) return 0;

    final h = dashboard!.client.height / 100;

    if (h == 0) return 0;

    return dashboard!.client.weight / (h * h);
  }

  Widget dashboardCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withOpacity(.15),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget statCard(
    String title,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 25,
          ),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error != null && error!.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Fitness Equation"),
        ),
        body: Center(
          child: Text(
            error!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Fitness Equation"),
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: loadDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [
                      Colors.green,
                      Colors.teal,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome Back 👋",
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      dashboard!.client.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      dashboard!.client.goal,
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  statCard(
                    "Weight",
                    "${dashboard!.client.weight} kg",
                    Colors.blue,
                  ),

                  const SizedBox(width: 12),

                  statCard(
                    "BMI",
                    bmi.toStringAsFixed(1),
                    Colors.orange,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  statCard(
                    "Amount Paid",
                    "₹${dashboard!.client.amountPaid.toStringAsFixed(0)}",
                    Colors.green,
                  ),

                  const SizedBox(width: 12),

                  statCard(
                    "Balance Due",
                    "₹${dashboard!.client.balanceDue.toStringAsFixed(0)}",
                    dashboard!.client.balanceDue > 0
                        ? Colors.redAccent
                        : Colors.grey,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              dashboardCard(
                title: "My Progress",
                subtitle: "Weight trend, photos & history",
                icon: Icons.show_chart,
                color: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProgressScreen(),
                    ),
                  );
                },
              ),

              dashboardCard(
                title: "Membership",
                subtitle: dashboard!.membership == null
                    ? "No Membership"
                    : dashboard!.membership!.plan,
                icon: Icons.workspace_premium,
                color: Colors.amber,
              ),

              dashboardCard(
                title: "Goal",
                subtitle: dashboard!.client.goal,
                icon: Icons.flag,
                color: Colors.green,
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}