import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/client_model.dart';
import '../../models/progress_model.dart';
import '../../services/client_service.dart';
import '../../services/progress_service.dart';

class AddProgressScreen extends StatefulWidget {
  final ProgressModel? progress;

  const AddProgressScreen({
    super.key,
    this.progress,
  });

  @override
  State<AddProgressScreen> createState() =>
      _AddProgressScreenState();
}

class _AddProgressScreenState
    extends State<AddProgressScreen> {
  final _formKey = GlobalKey<FormState>();

  final ProgressService progressService =
      ProgressService();

  final ClientService clientService =
      ClientService();

  bool loading = false;
  bool loadingClients = true;

  List<ClientModel> clients = [];

  ClientModel? selectedClient;

  DateTime selectedDate = DateTime.now();
  final weightController = TextEditingController();

final heightController = TextEditingController();

final bmiController = TextEditingController();

final bodyFatController = TextEditingController();

final chestController = TextEditingController();

final waistController = TextEditingController();

final bicepsController = TextEditingController();

final forearmController = TextEditingController();

final thighController = TextEditingController();

final shoulderController = TextEditingController();

final neckController = TextEditingController();

final notesController = TextEditingController();
void calculateBMI() {
  final weight = double.tryParse(
        weightController.text,
      ) ??
      0;

  final height =
      (double.tryParse(
            heightController.text,
          ) ??
          0) /
      100;

  if (weight > 0 && height > 0) {
    final bmi = weight / (height * height);

    bmiController.text =
        bmi.toStringAsFixed(1);

    setState(() {});
  }
}
@override
void initState() {
  super.initState();

  loadClients();

  if (widget.progress != null) {
    final p = widget.progress!;

    selectedDate = p.date;

    weightController.text =
        p.weight.toString();

    heightController.text =
        p.height.toString();

    bmiController.text =
        p.bmi.toString();

    bodyFatController.text =
        p.bodyFat.toString();

    chestController.text =
        p.chest.toString();

    waistController.text =
        p.waist.toString();

    bicepsController.text =
        p.biceps.toString();

    forearmController.text =
        p.forearm.toString();

    thighController.text =
        p.thigh.toString();

    shoulderController.text =
        p.shoulder.toString();

    neckController.text =
        p.neck.toString();

    notesController.text =
        p.notes;
  }
}
Future<void> loadClients() async {
  try {
    final prefs =
        await SharedPreferences.getInstance();

    final token = prefs.getString("token");

    if (token == null) {
      throw Exception("Login expired");
    }

    final data =
        await clientService.getClients(token);

    setState(() {
      clients = data;

      if (widget.progress != null) {
        selectedClient = clients.firstWhere(
          (c) =>
              c.id ==
              widget.progress!.clientId,
          orElse: () => clients.first,
        );
      } else if (clients.isNotEmpty) {
        selectedClient = clients.first;
      }

      loadingClients = false;
    });
  } catch (e) {
    setState(() {
      loadingClients = false;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(e.toString()),
      ),
    );
  }
}
Widget clientDropdown() {
  return DropdownButtonFormField<ClientModel>(
    value: selectedClient,
    decoration: InputDecoration(
      labelText: "Select Client",
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    items: clients.map((client) {
      return DropdownMenuItem(
        value: client,
        child: Text(client.name),
      );
    }).toList(),
    onChanged: (client) {
      setState(() {
        selectedClient = client;
      });
    },
    validator: (value) {
      if (value == null) {
        return "Please select a client";
      }
      return null;
    },
  );
}
Widget datePicker() {
  return InkWell(
    onTap: () async {
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );

      if (picked != null) {
        setState(() {
          selectedDate = picked;
        });
      }
    },
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: "Date",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
      ),
    ),
  );
}
Widget measurementField({
  required TextEditingController controller,
  required String label,
  bool requiredField = false,
  VoidCallback? onChanged,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    validator: requiredField
        ? (value) {
            if (value == null || value.isEmpty) {
              return "$label is required";
            }
            return null;
          }
        : null,
    onChanged: (_) {
      if (onChanged != null) {
        onChanged();
      }
    },
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
Future<void> saveProgress() async {
  if (!_formKey.currentState!.validate()) return;

  if (selectedClient == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please select a client"),
      ),
    );
    return;
  }

  try {
    setState(() {
      loading = true;
    });

    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("token");

    if (token == null) {
      throw Exception("Login expired");
    }

    final progress = ProgressModel(
      id: widget.progress?.id ?? "",
      clientId: selectedClient!.id,
      trainerId: "",
      date: selectedDate,
      weight: double.parse(weightController.text),
      height: double.parse(heightController.text),
      bmi: double.parse(bmiController.text),
      bodyFat: double.tryParse(bodyFatController.text) ?? 0,
      chest: double.tryParse(chestController.text) ?? 0,
      waist: double.tryParse(waistController.text) ?? 0,
      biceps: double.tryParse(bicepsController.text) ?? 0,
      forearm: double.tryParse(forearmController.text) ?? 0,
      thigh: double.tryParse(thighController.text) ?? 0,
      shoulder: double.tryParse(shoulderController.text) ?? 0,
      neck: double.tryParse(neckController.text) ?? 0,
      photo: "",
      notes: notesController.text,
    );

    if (widget.progress == null) {
      await progressService.addProgress(token, progress);
    } else {
      await progressService.updateProgress(
        token,
        widget.progress!.id,
        progress,
      );
    }

    if (!mounted) return;

    Navigator.pop(context, true);
  } catch (e) {
    setState(() {
      loading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }
}
@override
Widget build(BuildContext context) {
  if (loadingClients) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  return Scaffold(
    appBar: AppBar(
      title: Text(
        widget.progress == null
            ? "Add Progress"
            : "Edit Progress",
      ),
    ),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          clientDropdown(),

          const SizedBox(height: 18),

          datePicker(),

          const SizedBox(height: 18),

          measurementField(
            controller: weightController,
            label: "Weight (kg)",
            requiredField: true,
            onChanged: calculateBMI,
          ),

          const SizedBox(height: 18),

          measurementField(
            controller: heightController,
            label: "Height (cm)",
            requiredField: true,
            onChanged: calculateBMI,
          ),

          const SizedBox(height: 18),

          TextFormField(
            controller: bmiController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: "BMI",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 18),

          measurementField(
            controller: bodyFatController,
            label: "Body Fat (%)",
          ),

          const SizedBox(height: 18),

          measurementField(
            controller: chestController,
            label: "Chest (cm)",
          ),

          const SizedBox(height: 18),

          measurementField(
            controller: waistController,
            label: "Waist (cm)",
          ),

          const SizedBox(height: 18),

          measurementField(
            controller: bicepsController,
            label: "Biceps (cm)",
          ),

          const SizedBox(height: 18),

          measurementField(
            controller: forearmController,
            label: "Forearm (cm)",
          ),

          const SizedBox(height: 18),

          measurementField(
            controller: thighController,
            label: "Thigh (cm)",
          ),

          const SizedBox(height: 18),

          measurementField(
            controller: shoulderController,
            label: "Shoulder (cm)",
          ),

          const SizedBox(height: 18),

          measurementField(
            controller: neckController,
            label: "Neck (cm)",
          ),

          const SizedBox(height: 18),

          TextFormField(
            controller: notesController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: "Notes",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: loading ? null : saveProgress,
              child: loading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text(
                      widget.progress == null
                          ? "SAVE PROGRESS"
                          : "UPDATE PROGRESS",
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    ),
  );
}
@override
void dispose() {
  weightController.dispose();
  heightController.dispose();
  bmiController.dispose();
  bodyFatController.dispose();
  chestController.dispose();
  waistController.dispose();
  bicepsController.dispose();
  forearmController.dispose();
  thighController.dispose();
  shoulderController.dispose();
  neckController.dispose();
  notesController.dispose();

  super.dispose();
}
}