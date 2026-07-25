import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/client_model.dart';
import '../../models/progress_model.dart';
import '../../services/progress_service.dart';
import 'add_progress_screen.dart';
import 'progress_detail_screen.dart';

class ClientProgressListScreen extends StatefulWidget {
  final ClientModel client;

  const ClientProgressListScreen({
    super.key,
    required this.client,
  });

  @override
  State<ClientProgressListScreen> createState() =>
      _ClientProgressListScreenState();
}

class _ClientProgressListScreenState
    extends State<ClientProgressListScreen> {

  final ProgressService progressService =
      ProgressService();

  List<ProgressModel> progressList = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    try {

      final prefs =
          await SharedPreferences.getInstance();

      final token =
          prefs.getString("token");

      if (token == null) {
        throw Exception("Login expired");
      }

      final data =
          await progressService.getClientProgress(
        token,
        widget.client.id,
      );

      setState(() {
        progressList = data;
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

  Future<void> deleteProgress(String id) async {

    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Progress"),
        content: const Text(
          "Delete this progress record?",
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context,false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context,true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if(confirm!=true) return;

    try{

      final prefs =
          await SharedPreferences.getInstance();

      final token =
          prefs.getString("token");

      if(token==null){
        throw Exception("Login expired");
      }

      await progressService.deleteProgress(
        token,
        id,
      );

      await loadProgress();

    }catch(e){

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );

    }

  }

  Widget progressCard(
      ProgressModel progress){

    return Card(
      margin: const EdgeInsets.only(
        bottom: 15,
      ),
      child: ListTile(

        leading: const CircleAvatar(
          child: Icon(
            Icons.show_chart,
          ),
        ),

        title: Text(
          "${progress.weight} kg",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            Text(
              "BMI : ${progress.bmi}",
            ),

            Text(
              "Body Fat : ${progress.bodyFat} %",
            ),

          ],
        ),

        trailing:
            PopupMenuButton<String>(

          onSelected: (value) async{

            if(value=="edit"){

              final result=
                  await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:(_)=>
                      AddProgressScreen(
                    progress: progress,
                  ),
                ),
              );

              if(result==true){
                loadProgress();
              }

            }

            if(value=="delete"){

              await deleteProgress(
                progress.id,
              );

            }

          },

          itemBuilder:(_)=>const[

            PopupMenuItem(
              value:"edit",
              child: Text("Edit"),
            ),

            PopupMenuItem(
              value:"delete",
              child: Text("Delete"),
            ),

          ],

        ),

        onTap:(){

          Navigator.push(
            context,
            MaterialPageRoute(
              builder:(_)=>
                  ProgressDetailScreen(
                progress: progress,
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
      title: Text("${widget.client.name}'s Progress"),
    ),

    floatingActionButton: FloatingActionButton.extended(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AddProgressScreen(),
          ),
        );

        if (result == true) {
          loadProgress();
        }
      },
      icon: const Icon(Icons.add),
      label: const Text("Add Progress"),
    ),

    body: loading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : RefreshIndicator(
            onRefresh: loadProgress,
            child: progressList.isEmpty
                ? const Center(
                    child: Text(
                      "No progress records found",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: progressList.length,
                    itemBuilder: (_, index) {
                      return progressCard(
                        progressList[index],
                      );
                    },
                  ),
          ),
  );
}
  }