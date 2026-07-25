import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/dashboard_model.dart';
import '../../services/dashboard_service.dart';
import '../auth/change_password_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  DashboardModel? dashboard;

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("clientToken");

      if (token == null) {
        throw Exception("Please login again");
      }

      final data = await DashboardService().getDashboard(token);

      setState(() {
        dashboard = data;
        loading = false;
        error = null;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  Future<void> logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  String formatDate(DateTime? date) {
    if (date == null) return "-";
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  Widget infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.green.withOpacity(.15),
        child: Icon(icon, color: Colors.green),
      ),
      title: Text(
        label,
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget actionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.black87,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
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

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Profile")),
        body: Center(
          child: Text(
            error!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    final client = dashboard!.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: RefreshIndicator(
        onRefresh: loadProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.green,
                      child: Text(
                        client.name.isNotEmpty
                            ? client.name[0].toUpperCase()
                            : "?",
                        style: const TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      client.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      client.email,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Card(
                child: Column(
                  children: [
                    infoTile(
                      icon: Icons.phone,
                      label: "Phone",
                      value: client.phone.isEmpty ? "-" : client.phone,
                    ),
                    const Divider(height: 1),
                    infoTile(
                      icon: Icons.cake,
                      label: "Age",
                      value: client.age == 0 ? "-" : "${client.age} yrs",
                    ),
                    const Divider(height: 1),
                    infoTile(
                      icon: Icons.wc,
                      label: "Gender",
                      value: client.gender.isEmpty ? "-" : client.gender,
                    ),
                    const Divider(height: 1),
                    infoTile(
                      icon: Icons.height,
                      label: "Height",
                      value: "${client.height} cm",
                    ),
                    const Divider(height: 1),
                    infoTile(
                      icon: Icons.monitor_weight,
                      label: "Weight",
                      value: "${client.weight} kg",
                    ),
                    const Divider(height: 1),
                    infoTile(
                      icon: Icons.flag,
                      label: "Goal",
                      value: client.goal.isEmpty ? "-" : client.goal,
                    ),
                    const Divider(height: 1),
                    infoTile(
                      icon: Icons.event,
                      label: "Member Since",
                      value: formatDate(client.joiningDate),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              actionTile(
                icon: Icons.lock_reset,
                label: "Change Password",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  );
                },
              ),

              actionTile(
                icon: Icons.logout,
                label: "Logout",
                color: Colors.red,
                onTap: logout,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}