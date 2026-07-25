import 'package:fit_coach/screens/diet/diet_detail_screen.dart' show DietDetailScreen;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/client_model.dart';
import '../../models/diet_model.dart';
import '../../services/diet_service.dart';
import 'add_diet_screen.dart';


class ClientDietListScreen extends StatefulWidget {
  final ClientModel client;

  const ClientDietListScreen({
    super.key,
    required this.client,
  });

  @override
  State<ClientDietListScreen> createState() =>
      _ClientDietListScreenState();
}

class _ClientDietListScreenState
    extends State<ClientDietListScreen> {
  final DietService dietService = DietService();

  List<DietModel> diets = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadDiets();
  }

  Future<void> loadDiets() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("Login expired");
      }

      final data = await dietService.getClientDiets(
        token,
        widget.client.id,
      );

      setState(() {
        diets = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<void> deleteDiet(String dietId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Diet"),
        content: const Text(
          "Are you sure you want to delete this diet?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("Login expired");
      }

      await dietService.deleteDiet(token, dietId);

      await loadDiets();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Diet deleted successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Widget dietCard(DietModel diet) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.restaurant_menu),
        ),
        title: Text(
          diet.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text("Day : ${diet.day}"),
            Text("${diet.meals.length} Meals"),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == "edit") {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AddDietScreen(diet: diet),
                ),
              );

              if (result == true) {
                await loadDiets();
              }
            }

            if (value == "delete") {
              await deleteDiet(diet.id);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: "edit",
              child: Text("Edit"),
            ),
            PopupMenuItem(
              value: "delete",
              child: Text("Delete"),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  DietDetailScreen(diet: diet),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.client.name}'s Diet Plans"),
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AddDietScreen(),
            ),
          );

          if (result == true) {
            loadDiets();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text("Assign Diet"),
      ),
      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadDiets,
              child: diets.isEmpty
                  ? const Center(
                      child: Text(
                        "No diet plans assigned",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding:
                          const EdgeInsets.all(15),
                      itemCount: diets.length,
                      itemBuilder: (_, index) {
                        return dietCard(
                          diets[index],
                        );
                      },
                    ),
            ),
    );
  }
}