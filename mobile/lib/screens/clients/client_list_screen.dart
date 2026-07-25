import 'package:fit_coach/screens/clients/add_client_screen.dart';
import 'package:fit_coach/screens/clients/client_details_screen.dart' show ClientDetailsScreen;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/client_model.dart';
import '../../services/client_service.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  final ClientService clientService = ClientService();

  List<ClientModel> clients = [];
  List<ClientModel> filteredClients = [];

  bool loading = true;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadClients();
  }

  Future<void> loadClients() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("Token not found");
      }

      final data = await clientService.getClients(token);

      setState(() {
        clients = data;
        filteredClients = data;
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

  void search(String value) {
    setState(() {
      filteredClients = clients.where((client) {
        return client.name
            .toLowerCase()
            .contains(value.toLowerCase());
      }).toList();
    });
  }

  Future<void> deleteClient(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      if (token == null) return;

      await clientService.deleteClient(token, id);

      loadClients();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Client deleted"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  void confirmDelete(ClientModel client) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Client"),
        content: Text(
          "Delete ${client.name}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              deleteClient(client.id);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Widget clientCard(ClientModel client) {
  return Card(
    margin: const EdgeInsets.only(bottom: 15),
    child: ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClientDetailsScreen(
              client: client,
            ),
          ),
        );
      },
      leading: const CircleAvatar(
        child: Icon(Icons.person),
      ),
      title: Text(
        client.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("📞 ${client.phone}"),
          Text("🎯 ${client.goal}"),
          if (client.age != null)
            Text("Age : ${client.age}"),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == "delete") {
            confirmDelete(client);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: "edit",
            child: Text("Edit"),
          ),
          const PopupMenuItem(
            value: "delete",
            child: Text("Delete"),
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Clients"),
      ),
      floatingActionButton: FloatingActionButton(
  child: const Icon(Icons.add),
  onPressed: () async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddClientScreen(),
      ),
    );

    if (result == true) {
      loadClients();
    }
  },
),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadClients,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: TextField(
                      controller: searchController,
                      onChanged: search,
                      decoration: InputDecoration(
                        hintText: "Search Client",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: filteredClients.isEmpty
                        ? const Center(
                            child: Text(
                              "No Clients Found",
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount:
                                filteredClients.length,
                            itemBuilder: (_, index) {
                              return clientCard(
                                filteredClients[index],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}