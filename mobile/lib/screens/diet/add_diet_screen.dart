import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/client_model.dart';
import '../../models/diet_model.dart';
import '../../services/client_service.dart';
import '../../services/diet_service.dart';

class AddDietScreen extends StatefulWidget {
  final DietModel? diet;

  const AddDietScreen({super.key, this.diet});

  @override
  State<AddDietScreen> createState() => _AddDietScreenState();
}

class _AddDietScreenState extends State<AddDietScreen> {
  final _formKey = GlobalKey<FormState>();

  final DietService dietService = DietService();
  final ClientService clientService = ClientService();

  final titleController = TextEditingController();
  final notesController = TextEditingController();

  bool loading = false;
  bool loadingClients = true;

  List<ClientModel> clients = [];
  ClientModel? selectedClient;

  String selectedDay = "Monday";

  int waterIntake = 3;

  List<MealModel> meals = [];

  final List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];
  void addMeal() {
    setState(() {
      meals.add(
        MealModel(mealType: "Breakfast", food: "", quantity: "", calories: 0),
      );
    });
  }

  void removeMeal(int index) {
    setState(() {
      meals.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();

    loadClients();

    if (widget.diet != null) {
      titleController.text = widget.diet!.title;
      notesController.text = widget.diet!.notes;
      selectedDay = widget.diet!.day;
      waterIntake = widget.diet!.waterIntake;

      meals = widget.diet!.meals
          .map(
            (m) => MealModel(
              mealType: m.mealType,
              food: m.food,
              quantity: m.quantity,
              calories: m.calories,
            ),
          )
          .toList();
    } else {
      addMeal();
    }
  }

  Future<void> loadClients() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("Login expired");
      }

      final data = await clientService.getClients(token);

      setState(() {
        clients = data;

        if (widget.diet != null) {
          selectedClient = clients.firstWhere(
            (c) => c.id == widget.diet!.clientId,
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget clientDropdown() {
    return DropdownButtonFormField<ClientModel>(
      value: selectedClient,
      decoration: InputDecoration(
        labelText: "Select Client",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: clients.map((client) {
        return DropdownMenuItem(value: client, child: Text(client.name));
      }).toList(),
      onChanged: (client) {
        setState(() {
          selectedClient = client;
        });
      },
    );
  }

  Widget dayDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedDay,
      decoration: InputDecoration(
        labelText: "Day",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: days.map((day) {
        return DropdownMenuItem(value: day, child: Text(day));
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedDay = value!;
        });
      },
    );
  }

  Widget waterField() {
    return TextFormField(
      initialValue: waterIntake.toString(),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: "Water Intake (Litres)",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: (value) {
        waterIntake = int.tryParse(value) ?? 3;
      },
    );
  }

  Widget mealCard(int index) {
    final meal = meals[index];

    final foodController = TextEditingController(text: meal.food);
    final quantityController = TextEditingController(text: meal.quantity);
    final calorieController = TextEditingController(
      text: meal.calories == 0 ? "" : meal.calories.toString(),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "Meal ${index + 1}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => removeMeal(index),
                ),
              ],
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: meal.mealType,
              decoration: const InputDecoration(
                labelText: "Meal Type",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "Breakfast", child: Text("Breakfast")),
                DropdownMenuItem(value: "Lunch", child: Text("Lunch")),
                DropdownMenuItem(value: "Dinner", child: Text("Dinner")),
                DropdownMenuItem(value: "Snacks", child: Text("Snacks")),
              ],
              onChanged: (value) {
                meals[index] = MealModel(
                  mealType: value!,
                  food: meal.food,
                  quantity: meal.quantity,
                  calories: meal.calories,
                );

                setState(() {});
              },
            ),

            const SizedBox(height: 15),

            TextField(
              controller: foodController,
              decoration: const InputDecoration(
                labelText: "Food",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                meals[index] = MealModel(
                  mealType: meals[index].mealType,
                  food: value,
                  quantity: meals[index].quantity,
                  calories: meals[index].calories,
                );
              },
            ),

            const SizedBox(height: 15),

            TextField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: "Quantity",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                meals[index] = MealModel(
                  mealType: meals[index].mealType,
                  food: meals[index].food,
                  quantity: value,
                  calories: meals[index].calories,
                );
              },
            ),

            const SizedBox(height: 15),

            TextField(
              controller: calorieController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Calories",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                meals[index] = MealModel(
                  mealType: meals[index].mealType,
                  food: meals[index].food,
                  quantity: meals[index].quantity,
                  calories: int.tryParse(value) ?? 0,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loadingClients) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.diet == null ? "Add Diet" : "Edit Diet"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            titleField(),

            const SizedBox(height: 18),

            clientDropdown(),

            const SizedBox(height: 18),

            dayDropdown(),

            const SizedBox(height: 18),

            waterField(),

            const SizedBox(height: 18),

            TextFormField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Notes",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Meals",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            ...List.generate(meals.length, (index) => mealCard(index)),

            OutlinedButton.icon(
              onPressed: addMeal,
              icon: const Icon(Icons.add),
              label: const Text("Add Meal"),
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: loading ? null : saveDiet,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.diet == null ? "SAVE DIET" : "UPDATE DIET",
                        style: const TextStyle(fontSize: 18),
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> saveDiet() async {
  if (!_formKey.currentState!.validate()) return;

  if (selectedClient == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please select a client"),
      ),
    );
    return;
  }

  if (meals.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please add at least one meal"),
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

    final diet = DietModel(
      id: widget.diet?.id ?? "",
      clientId: selectedClient!.id,
      trainerId: "",
      title: titleController.text.trim(),
      day: selectedDay,
      meals: meals,
      waterIntake: waterIntake,
      notes: notesController.text.trim(),
    );

    if (widget.diet == null) {
      await dietService.addDiet(token, diet);
    } else {
      await dietService.updateDiet(
        token,
        widget.diet!.id,
        diet,
      );
    }

    if (!mounted) return;

    Navigator.pop(context, true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.diet == null
              ? "Diet Created Successfully"
              : "Diet Updated Successfully",
        ),
        backgroundColor: Colors.green,
      ),
    );
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

  Widget titleField() {
    return TextFormField(
      controller: titleController,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Diet title is required";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Diet Title",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
