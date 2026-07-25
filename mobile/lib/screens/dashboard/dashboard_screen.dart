import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/client_model.dart';
import '../../services/client_service.dart';
import '../clients/client_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String trainerName = "";
  int clientCount = 0;

  final ClientService clientService = ClientService();

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      trainerName = prefs.getString("trainerName") ?? "Trainer";

      final token = prefs.getString("token");

      if (token != null) {
        final List<ClientModel> clients = await clientService.getClients(token);

        clientCount = clients.length;
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
  }

  Widget dashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  Widget quickButton(IconData icon, String title, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(title),
    );
  }

  Future<void> openClients() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ClientListScreen()),
    );

    loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FitCoach"),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: logout),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome, $trainerName 👋",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                "Have a productive day!",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),

              const SizedBox(height: 30),

              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.15,
                children: [
                  dashboardCard(
                    title: "Clients",
                    value: clientCount.toString(),
                    icon: Icons.people,
                    color: Colors.blue,
                    onTap: openClients,
                  ),

                  dashboardCard(
                    title: "Revenue",
                    value: "₹0",
                    icon: Icons.currency_rupee,
                    color: Colors.green,
                  ),

                  dashboardCard(
                    title: "Active Clients",
                    value: clientCount.toString(),
                    icon: Icons.people_alt,
                    color: Colors.deepPurple,
                  ),

                  dashboardCard(
                    title: "Diet Plans",
                    value: "-",
                    icon: Icons.restaurant_menu,
                    color: Colors.orange,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                "Quick Actions",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  quickButton(Icons.person_add, "Add Client", openClients),

                  quickButton(Icons.people, "Clients", openClients),

                  quickButton(Icons.payment, "Payments", () {}),

                  quickButton(Icons.restaurant, "Diet", () {}),

                  quickButton(Icons.bar_chart, "Reports", () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
