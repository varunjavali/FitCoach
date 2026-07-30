import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/client_model.dart';
import '../../services/client_service.dart';
import 'client_progress_list_screen.dart';

class ProgressClientListScreen extends StatefulWidget {
  const ProgressClientListScreen({super.key});

  @override
  State<ProgressClientListScreen> createState() =>
      _ProgressClientListScreenState();
}

class _ProgressClientListScreenState
    extends State<ProgressClientListScreen> {
  final ClientService _clientService = ClientService();

  final TextEditingController _searchController =
      TextEditingController();

  List<ClientModel> _clients = [];
  List<ClientModel> _filteredClients = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("Login expired");
      }

      final clients =
          await _clientService.getClients(token);

      setState(() {
        _clients = clients;
        _filteredClients = clients;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _search(String value) {
    setState(() {
      _filteredClients = _clients.where((client) {
        return client.name
                .toLowerCase()
                .contains(value.toLowerCase()) ||
            client.phone.contains(value);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _clientCard(ClientModel client) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple,
          child: Text(
            client.name.isNotEmpty
                ? client.name[0].toUpperCase()
                : "?",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          client.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(client.phone),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ClientProgressListScreen(
                client: client,
              ),
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
        title: const Text("Client Progress"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: _search,
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
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _filteredClients.isEmpty
                    ? const Center(
                        child: Text(
                          "No clients found",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadClients,
                        child: ListView.builder(
                          itemCount: _filteredClients.length,
                          itemBuilder: (context, index) {
                            return _clientCard(
                              _filteredClients[index],
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}