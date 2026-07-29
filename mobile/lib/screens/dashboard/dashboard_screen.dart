import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/client_model.dart';
import '../../services/client_service.dart';
import '../../services/dashboard_service.dart';
import '../clients/client_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String trainerName = "";

  int totalClients = 0;
  int activeMembers = 0;
  int expiredMembers = 0;
  int expiringSoon = 0;
  int totalTransactions = 0;

  double monthlyRevenue = 0;
  double todayCollection = 0;
  double totalRevenue = 0;
  double pendingBalance = 0;

  bool isLoading = true;

  final DashboardService dashboardService = DashboardService();

  final ClientService clientService = ClientService();

  //---------------------------------------------------------
  // Theme constants — shared across the app
  //---------------------------------------------------------

  static const _bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xff0F2027), Color(0xff203A43), Color(0xff2C5364)],
  );

  static final Color _accent = Colors.greenAccent.shade400;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) return;

      final data = await dashboardService.getDashboard(token);
      debugPrint("Dashboard API: $data");

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
        SnackBar(
          content: Text("Failed to load dashboard"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
  }

  //---------------------------------------------------------
  // Themed building blocks
  //---------------------------------------------------------

  Widget _glassCard({required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(.12),
                Colors.white.withOpacity(.05),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(.18)),
          ),
          child: child,
        ),
      ),
    );
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
      borderRadius: BorderRadius.circular(18),
      child: _glassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Small, clear icon circle — sized to read as a label,
            // not dominate the card.
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(.16),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 12.5, color: Colors.white60),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget quickButton(IconData icon, String title, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.10),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(.18)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: _accent),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
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
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
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
                "FitCoach",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: logout,
                ),
              ],
            ),
          ),
        ),
      ),
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
            child: RefreshIndicator(
              onRefresh: loadDashboard,
              color: _accent,
              backgroundColor: const Color(0xff203A43),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, kToolbarHeight + 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome, $trainerName 👋",
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      "Have a productive day!",
                      style: GoogleFonts.poppins(
                        color: Colors.white60,
                        fontSize: 14.5,
                      ),
                    ),

                    const SizedBox(height: 28),

                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.0,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        dashboardCard(
                          title: "Clients",
                          value: totalClients.toString(),
                          icon: Icons.people,
                          color: Colors.lightBlueAccent,
                        ),

                        dashboardCard(
                          title: "Active",
                          value: activeMembers.toString(),
                          icon: Icons.verified,
                          color: Colors.green,
                        ),

                        dashboardCard(
                          title: "Expired",
                          value: expiredMembers.toString(),
                          icon: Icons.warning,
                          color: Colors.redAccent,
                        ),

                        dashboardCard(
                          title: "Expiring Soon",
                          value: expiringSoon.toString(),
                          icon: Icons.schedule,
                          color: Colors.orange,
                        ),

                        dashboardCard(
                          title: "Monthly Revenue",
                          value: "₹${(monthlyRevenue).toStringAsFixed(0)}",
                          icon: Icons.currency_rupee,
                          color: Colors.teal,
                        ),

                        dashboardCard(
                          title: "Today's Collection",
                          value: "₹${todayCollection.toStringAsFixed(0)}",
                          icon: Icons.today,
                          color: Colors.greenAccent,
                        ),

                        dashboardCard(
                          title: "Total Revenue",
                          value: "₹${totalRevenue.toStringAsFixed(0)}",
                          icon: Icons.account_balance,
                          color: Colors.cyan,
                        ),

                        dashboardCard(
                          title: "Transactions",
                          value: totalTransactions.toString(),
                          icon: Icons.receipt_long,
                          color: Colors.amber,
                        ),

                        dashboardCard(
                          title: "Pending Balance",
                          value: "₹${pendingBalance.toStringAsFixed(0)}",
                          icon: Icons.account_balance_wallet,
                          color: Colors.deepPurpleAccent,
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    Text(
                      "Quick Actions",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        quickButton(
                          Icons.person_add,
                          "Add Client",
                          openClients,
                        ),

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
          ),
        ],
      ),
    );
  }
}
