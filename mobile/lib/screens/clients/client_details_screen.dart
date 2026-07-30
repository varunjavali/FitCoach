import 'package:fit_coach/screens/chat/trainer_chat_screen.dart'
    show TrainerChatScreen;
import 'package:fit_coach/screens/diet/client_diet_list_screen.dart'
    show ClientDietListScreen;
import 'package:fit_coach/screens/membership/RenewMembershipScreen.dart'
    show RenewMembershipScreen;
import 'package:fit_coach/screens/progress/client_progress_list_screen.dart'
    show ClientProgressListScreen;
import 'package:flutter/material.dart';
import 'package:fit_coach/screens/clients/update_balance_screen.dart';

import '../../models/client_model.dart';
import '../membership/MembershipHistoryScreen.dart'
    show MembershipHistoryScreen;
import '../workouts/client_workout_list_screen.dart';
import 'edit_client_screen.dart';

class ClientDetailsScreen extends StatefulWidget {
  final ClientModel client;

  const ClientDetailsScreen({super.key, required this.client});

  @override
  State<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen> {
  late ClientModel client = widget.client;

  //----------------------------------------------------
  // Theme — matches dashboard_screen.dart
  //----------------------------------------------------

  static const _primaryGreen = Color(0xff1FA35C);
  static const _tealAccent = Color(0xff17A2A0);

  //----------------------------------------------------
  // Small stat card (icon + big value + label)
  //----------------------------------------------------

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
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
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(.12),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 3),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 11.5),
            ),
          ],
        ),
      ),
    );
  }

  //----------------------------------------------------
  // Compact info row (used inside "Personal Info" card)
  //----------------------------------------------------

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _tealAccent.withOpacity(.10),
            ),
            child: Icon(icon, size: 16, color: _tealAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13.5),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  //----------------------------------------------------
  // Action grid card (icon + label), matches dashboard's
  // Quick Actions style
  //----------------------------------------------------

  Widget _actionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
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
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        title: const Text("Client Details"),
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
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          //----------------------------------------------------
          // Gradient profile header
          //----------------------------------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 34),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_primaryGreen, _tealAccent],
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(.18),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      client.name.isNotEmpty
                          ? client.name[0].toUpperCase()
                          : "?",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  client.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  client.email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          //----------------------------------------------------
          // Payment stat cards, overlapping the header
          //----------------------------------------------------
          Transform.translate(
            offset: const Offset(0, -22),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _statCard(
                    title: "Total Fees",
                    value: "₹${client.totalFees.toStringAsFixed(0)}",
                    icon: Icons.currency_rupee,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 10),
                  _statCard(
                    title: "Paid",
                    value: "₹${client.amountPaid.toStringAsFixed(0)}",
                    icon: Icons.check_circle,
                    color: _primaryGreen,
                  ),
                  const SizedBox(width: 10),
                  _statCard(
                    title: "Balance",
                    value: "₹${client.balanceDue.toStringAsFixed(0)}",
                    icon: Icons.hourglass_empty,
                    color: client.balanceDue > 0 ? Colors.orange : Colors.grey,
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
                  offset: const Offset(0, -8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 6,
                    ),
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
                    child: Column(
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: const [
                            Text(
                              "Personal Info",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 18),
                        _InfoGrid(client: client, infoRow: _infoRow),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Manage Client",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
                    _actionCard(
                      icon: Icons.chat,
                      title: "Chat",
                      color: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TrainerChatScreen(client: client),
                          ),
                        );
                      },
                    ),
                    _actionCard(
                      icon: Icons.fitness_center,
                      title: "Workout",
                      color: Colors.deepOrange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ClientWorkoutListScreen(client: client),
                          ),
                        );
                      },
                    ),
                    _actionCard(
                      icon: Icons.restaurant,
                      title: "Diet",
                      color: Colors.teal,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ClientDietListScreen(client: client),
                          ),
                        );
                      },
                    ),
                    _actionCard(
                      icon: Icons.show_chart,
                      title: "Progress",
                      color: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ClientProgressListScreen(client: client),
                          ),
                        );
                      },
                    ),
                    _actionCard(
                      icon: Icons.card_membership,
                      title: "Renew\nMembership",
                      color: Colors.blue,
                      onTap: () async {
                        final updatedClient = await Navigator.push<ClientModel>(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RenewMembershipScreen(client: client),
                          ),
                        );

                        if (updatedClient != null) {
                          setState(() {
                            client = updatedClient;
                          });
                        }
                      },
                    ),
                    _actionCard(
                      icon: Icons.history,
                      title: "Membership\nHistory",
                      color: Colors.deepOrange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MembershipHistoryScreen(client: client),
                          ),
                        );
                      },
                    ),
                    _actionCard(
                      icon: Icons.account_balance_wallet,
                      title: "Update\nBalance",
                      color: Colors.indigo,
                      onTap: () async {
                        final updated = await Navigator.push<ClientModel>(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                UpdateBalanceScreen(client: client),
                          ),
                        );

                        if (updated != null) {
                          setState(() {
                            client = updated;
                          });
                        }
                      },
                    ),
                    _actionCard(
                      icon: Icons.bar_chart,
                      title: "Reports",
                      color: Colors.deepPurple,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Coming Soon")),
                        );
                      },
                    ),
                    _actionCard(
                      icon: Icons.edit,
                      title: "Edit Client",
                      color: _tealAccent,
                      onTap: () async {
                        final updated = await Navigator.push<ClientModel>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditClientScreen(client: client),
                          ),
                        );

                        if (updated != null) {
                          setState(() {
                            client = updated;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//----------------------------------------------------
// Personal info rows, split out so _infoRow can stay
// a normal instance method above
//----------------------------------------------------

class _InfoGrid extends StatelessWidget {
  final ClientModel client;
  final Widget Function(IconData, String, String) infoRow;

  const _InfoGrid({required this.client, required this.infoRow});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        infoRow(Icons.phone, "Phone", client.phone),
        infoRow(Icons.cake, "Age", client.age?.toString() ?? "-"),
        infoRow(Icons.wc, "Gender", client.gender ?? "-"),
        infoRow(Icons.flag, "Goal", client.goal ?? "-"),
        infoRow(
          Icons.height,
          "Height",
          client.height == null ? "-" : "${client.height} cm",
        ),
        infoRow(
          Icons.monitor_weight,
          "Weight",
          client.weight == null ? "-" : "${client.weight} kg",
        ),
      ],
    );
  }
}