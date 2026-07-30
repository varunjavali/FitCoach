import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/dashboard_service.dart';
import '../../services/client_service.dart';

import '../clients/client_list_screen.dart';
import '../payments/payment_list_screen.dart';
import '../progress/progress_client_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  //----------------------------------------------------
  // Trainer
  //----------------------------------------------------

  String trainerName = "";

  //----------------------------------------------------
  // Dashboard Counts
  //----------------------------------------------------

  int totalClients = 0;
  int activeMembers = 0;
  int expiredMembers = 0;
  int expiringSoon = 0;
  int totalTransactions = 0;

  //----------------------------------------------------
  // Revenue
  //----------------------------------------------------

  double todayCollection = 0;
  double monthlyRevenue = 0;
  double totalRevenue = 0;
  double pendingBalance = 0;

  //----------------------------------------------------
  // Loading
  //----------------------------------------------------

  bool isLoading = true;

  //----------------------------------------------------
  // Services
  //----------------------------------------------------

  final DashboardService dashboardService = DashboardService();
  final ClientService clientService = ClientService();

  //----------------------------------------------------
  // Theme
  //----------------------------------------------------

  static const _primaryGreen = Color(0xff1FA35C);
  static const _tealAccent = Color(0xff17A2A0);

  //----------------------------------------------------
  // Init
  //----------------------------------------------------

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  //----------------------------------------------------
  // Dashboard API
  //----------------------------------------------------

  Future<void> loadDashboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) return;

      final data = await dashboardService.getDashboard(token);

      if (!mounted) return;

      setState(() {
        trainerName = data["trainerName"] ?? "Trainer";
        totalClients = data["totalClients"] ?? 0;
        activeMembers = data["activeMembers"] ?? 0;
        expiredMembers = data["expiredMembers"] ?? 0;
        expiringSoon = data["expiringSoon"] ?? 0;

        todayCollection = (data["todayCollection"] as num?)?.toDouble() ?? 0.0;
        monthlyRevenue = (data["monthlyRevenue"] as num?)?.toDouble() ?? 0.0;
        totalRevenue = (data["totalRevenue"] as num?)?.toDouble() ?? 0.0;
        pendingBalance = (data["pendingBalance"] as num?)?.toDouble() ?? 0.0;

        totalTransactions = data["totalTransactions"] ?? 0;

        isLoading = false;
      });
    } catch (e) {
      debugPrint("Dashboard Error: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to load dashboard"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  //----------------------------------------------------
  // Logout
  //----------------------------------------------------

  Future<void> logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
  }

  //----------------------------------------------------
  // Open Client Screen
  //----------------------------------------------------

  Future<void> openClients() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ClientListScreen()),
    );

    loadDashboard();
  }

  //----------------------------------------------------
  // Stat Card (icon + big number + label)
  //----------------------------------------------------

  Widget statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(.12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 12.5),
            ),
          ],
        ),
      ),
    );
  }

  //----------------------------------------------------
  // Quick Action Card (icon + label, tappable)
  //----------------------------------------------------

  Widget actionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = _primaryGreen,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(.12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  //----------------------------------------------------
  // Statistics Row (for the bottom sheet)
  //----------------------------------------------------

  Widget statisticTile(String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(.12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }

  //----------------------------------------------------
  // Statistics Bottom Sheet
  //----------------------------------------------------

  void showStatistics() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 26),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Dashboard Statistics",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 16),

                statisticTile(
                  "Today's Collection",
                  "₹${todayCollection.toStringAsFixed(0)}",
                  Icons.today,
                  _primaryGreen,
                ),
                statisticTile(
                  "Monthly Revenue",
                  "₹${monthlyRevenue.toStringAsFixed(0)}",
                  Icons.calendar_month,
                  Colors.blue,
                ),
                statisticTile(
                  "Total Revenue",
                  "₹${totalRevenue.toStringAsFixed(0)}",
                  Icons.account_balance_wallet,
                  _tealAccent,
                ),
                statisticTile(
                  "Pending Balance",
                  "₹${pendingBalance.toStringAsFixed(0)}",
                  Icons.hourglass_empty,
                  Colors.orange,
                ),
                statisticTile(
                  "Transactions",
                  totalTransactions.toString(),
                  Icons.receipt_long,
                  Colors.deepPurple,
                ),
                statisticTile(
                  "Expired Members",
                  expiredMembers.toString(),
                  Icons.event_busy,
                  Colors.red,
                ),
                statisticTile(
                  "Expiring Soon",
                  expiringSoon.toString(),
                  Icons.schedule,
                  Colors.amber.shade800,
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Close",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //----------------------------------------------------
  // Build UI
  //----------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        title: const Text("Fitness Equation"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_primaryGreen, _tealAccent],
            ),
          ),
        ),
        actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadDashboard,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            //----------------------------------------------------
            // Gradient welcome header
            //----------------------------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_primaryGreen, _tealAccent],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back 👋",
                    style: TextStyle(
                      color: Colors.white.withOpacity(.85),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trainerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            //----------------------------------------------------
            // Stat cards, overlapping the header slightly
            //----------------------------------------------------
            Transform.translate(
              offset: const Offset(0, -22),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    statCard(
                      title: "Total Clients",
                      value: totalClients.toString(),
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    statCard(
                      title: "Active Members",
                      value: activeMembers.toString(),
                      icon: Icons.verified,
                      color: _primaryGreen,
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.translate(
                    offset: const Offset(0, -10),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: showStatistics,
                        icon: const Icon(Icons.bar_chart),
                        label: const Text(
                          "View Statistics",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _tealAccent,
                          backgroundColor: Colors.white,
                          side: BorderSide(color: _tealAccent.withOpacity(.4)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Quick Actions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 14),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.95,
                    children: [
                      actionButton(
                        icon: Icons.person_add,
                        title: "Add Client",
                        onTap: openClients,
                        color: Colors.blue,
                      ),
                      actionButton(
                        icon: Icons.people,
                        title: "Clients",
                        onTap: openClients,
                        color: _primaryGreen,
                      ),
                      actionButton(
                        icon: Icons.payment,
                        title: "Payments",
                        color: Colors.indigo,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PaymentListScreen(),
                            ),
                          );
                        },
                      ),
                      actionButton(
                        icon: Icons.fitness_center,
                        title: "Workout",
                        onTap: () {},
                        color: Colors.deepOrange,
                      ),
                      actionButton(
                        icon: Icons.restaurant,
                        title: "Diet",
                        onTap: () {},
                        color: Colors.teal,
                      ),
                      actionButton(
                        icon: Icons.show_chart,
                        title: "Progress",
                        color: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProgressClientListScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
