import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/dashboard_model.dart';
import '../../services/dashboard_service.dart';
import '../auth/change_password_screen.dart';
import '../auth/login_screen.dart';
import '../payment/payment_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  DashboardModel? dashboard;

  bool loading = true;
  String? error;

  //---------------------------------------------------------
  // Theme constants — shared with LoginScreen / ChatScreen
  //---------------------------------------------------------

  static const _bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xff0F2027), Color(0xff203A43), Color(0xff2C5364)],
  );

  static final _accent = Colors.greenAccent.shade400;

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
      barrierColor: Colors.black.withOpacity(.55),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(.16),
                    Colors.white.withOpacity(.06),
                  ],
                ),
                border: Border.all(color: Colors.white.withOpacity(.25)),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Logout",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Are you sure you want to logout?",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.poppins(color: Colors.white70),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          "Logout",
                          style: GoogleFonts.poppins(
                            color: Colors.redAccent.shade100,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (confirmed != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  String formatDate(DateTime? date) {
    if (date == null) return "-";
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  //---------------------------------------------------------
  // Themed building blocks
  //---------------------------------------------------------

  Widget _glassCard({required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
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
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(.18)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _accent.withOpacity(.15),
        ),
        child: Icon(icon, color: _accent, size: 20),
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(color: Colors.white60, fontSize: 13),
      ),
      subtitle: Text(
        value,
        style: GoogleFonts.poppins(
          color: Colors.white,
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
    Color color = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _glassCard(
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text(
            label,
            style: GoogleFonts.poppins(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 15,
            color: color.withOpacity(.7),
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //-------------------------------------------------
    // Loading state
    //-------------------------------------------------

    if (loading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: _bgGradient),
          child: Center(child: CircularProgressIndicator(color: _accent)),
        ),
      );
    }

    //-------------------------------------------------
    // Error state
    //-------------------------------------------------

    if (error != null) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _glassAppBar("Profile"),
        body: Container(
          decoration: const BoxDecoration(gradient: _bgGradient),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _glassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                        size: 36,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        error!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final client = dashboard!.client;

    //-------------------------------------------------
    // Main content
    //-------------------------------------------------

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _glassAppBar("Profile"),
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
              onRefresh: loadProfile,
              color: _accent,
              backgroundColor: const Color(0xff203A43),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(18, kToolbarHeight + 10, 18, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    //-------------------------------------------------
                    // Avatar + name
                    //-------------------------------------------------
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _accent.withOpacity(.6),
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.white.withOpacity(.12),
                              child: Text(
                                client.name.isNotEmpty
                                    ? client.name[0].toUpperCase()
                                    : "?",
                                style: GoogleFonts.poppins(
                                  fontSize: 36,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            client.name,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            client.email,
                            style: GoogleFonts.poppins(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    //-------------------------------------------------
                    // Info card
                    //-------------------------------------------------
                    _glassCard(
                      child: Column(
                        children: [
                          infoTile(
                            icon: Icons.phone,
                            label: "Phone",
                            value: client.phone.isEmpty ? "-" : client.phone,
                          ),
                          Divider(
                            height: 1,
                            color: Colors.white.withOpacity(.12),
                          ),
                          infoTile(
                            icon: Icons.cake,
                            label: "Age",
                            value: client.age == 0 ? "-" : "${client.age} yrs",
                          ),
                          Divider(
                            height: 1,
                            color: Colors.white.withOpacity(.12),
                          ),
                          infoTile(
                            icon: Icons.wc,
                            label: "Gender",
                            value: client.gender.isEmpty ? "-" : client.gender,
                          ),
                          Divider(
                            height: 1,
                            color: Colors.white.withOpacity(.12),
                          ),
                          infoTile(
                            icon: Icons.height,
                            label: "Height",
                            value: "${client.height} cm",
                          ),
                          Divider(
                            height: 1,
                            color: Colors.white.withOpacity(.12),
                          ),
                          infoTile(
                            icon: Icons.monitor_weight,
                            label: "Weight",
                            value: "${client.weight} kg",
                          ),
                          Divider(
                            height: 1,
                            color: Colors.white.withOpacity(.12),
                          ),
                          infoTile(
                            icon: Icons.flag,
                            label: "Goal",
                            value: client.goal.isEmpty ? "-" : client.goal,
                          ),
                          infoTile(
                            icon: Icons.currency_rupee,
                            label: "Total Fees",
                            value: "₹${client.totalFees.toStringAsFixed(0)}",
                          ),

                          Divider(
                            height: 1,
                            color: Colors.white.withOpacity(.12),
                          ),

                          infoTile(
                            icon: Icons.check_circle,
                            label: "Amount Paid",
                            value: "₹${client.amountPaid.toStringAsFixed(0)}",
                          ),

                          Divider(
                            height: 1,
                            color: Colors.white.withOpacity(.12),
                          ),

                          infoTile(
                            icon: Icons.account_balance_wallet,
                            label: "Balance Due",
                            value: "₹${client.balanceDue.toStringAsFixed(0)}",
                          ),
                          Divider(
                            height: 1,
                            color: Colors.white.withOpacity(.12),
                          ),
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
                      icon: Icons.receipt_long,
                      label: "Payment History",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PaymentHistoryScreen(),
                          ),
                        );
                      },
                    ),
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
                      color: Colors.redAccent.shade100,
                      onTap: logout,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _glassAppBar(String title) {
    return PreferredSize(
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
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
