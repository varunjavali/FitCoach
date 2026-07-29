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

  Widget actionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  void comingSoon(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Coming Soon")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Client Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 45,
                      child: Icon(Icons.person, size: 45),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      client.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(client.email),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(child: infoTile("Phone", client.phone)),

                        Expanded(
                          child: infoTile("Age", client.age?.toString() ?? "-"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: infoTile("Gender", client.gender ?? "-"),
                        ),

                        Expanded(child: infoTile("Goal", client.goal ?? "-")),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: infoTile(
                            "Height",
                            client.height == null ? "-" : "${client.height} cm",
                          ),
                        ),

                        Expanded(
                          child: infoTile(
                            "Weight",
                            client.weight == null ? "-" : "${client.weight} kg",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: infoTile(
                            "Total Fees",
                            "₹${client.totalFees.toStringAsFixed(0)}",
                            valueColor: Colors.blue,
                          ),
                        ),
                        Expanded(
                          child: infoTile(
                            "Amount Paid",
                            "₹${client.amountPaid.toStringAsFixed(0)}",
                            valueColor: Colors.green,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: infoTile(
                            "Balance Due",
                            "₹${client.balanceDue.toStringAsFixed(0)}",
                            valueColor: client.balanceDue > 0
                                ? Colors.orange
                                : Colors.green,
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),
            actionCard(
              context: context,
              icon: Icons.fitness_center,
              title: "chat",
              subtitle: "Chat",
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

            actionCard(
              context: context,
              icon: Icons.fitness_center,
              title: "Workout",
              subtitle: "Assign / View Workout",
              color: Colors.red,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ClientWorkoutListScreen(client: client),
                  ),
                );
              },
            ),

            actionCard(
              context: context,
              icon: Icons.restaurant,
              title: "Diet",
              subtitle: "Assign Diet Plan",
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ClientDietListScreen(client: client),
                  ),
                );
              },
            ),

            actionCard(
              context: context,
              icon: Icons.show_chart,
              title: "Progress",
              subtitle: "Weight & BMI Progress",
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ClientProgressListScreen(client: client),
                  ),
                );
              },
            ),
            actionCard(
              context: context,
              icon: Icons.card_membership,
              title: "Renew Membership",
              subtitle: "Renew or Upgrade Membership",
              color: Colors.blue,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RenewMembershipScreen(client: client),
                  ),
                );

                if (result == true) {
                  // Refresh client details after renewal
                  setState(() {});
                }
              },
            ),
            actionCard(
              context: context,
              icon: Icons.history,
              title: "Membership History",
              subtitle: "View all membership renewals",
              color: Colors.deepOrange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MembershipHistoryScreen(client: client),
                  ),
                );
              },
            ),
            actionCard(
              context: context,
              icon: Icons.account_balance_wallet,
              title: "Update Balance",
              subtitle: "Receive Payment & Update Balance",
              color: Colors.indigo,
              onTap: () async {
                final updated = await Navigator.push<ClientModel>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UpdateBalanceScreen(client: client),
                  ),
                );

                if (updated != null) {
                  setState(() {
                    client = updated;
                  });
                }
              },
            ),

            actionCard(
              context: context,
              icon: Icons.bar_chart,
              title: "Reports",
              subtitle: "Client Reports",
              color: Colors.deepPurple,
              onTap: () {
                comingSoon(context);
              },
            ),

            actionCard(
              context: context,
              icon: Icons.edit,
              title: "Edit Client",
              subtitle: "Update Client Information & Payments",
              color: Colors.teal,
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
      ),
    );
  }

  Widget infoTile(String title, String value, {Color? valueColor}) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, color: valueColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
