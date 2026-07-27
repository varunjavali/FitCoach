import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  //---------------------------------------------------------
  // Theme constants — shared across the app
  //---------------------------------------------------------

  static const _bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xff0F2027),
      Color(0xff203A43),
      Color(0xff2C5364),
    ],
  );

  static final Color _accent = Colors.greenAccent.shade400;

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

  //---------------------------------------------------------
  // Themed input decoration — shared by all fields + dropdowns
  //---------------------------------------------------------

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

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

  Widget clientDropdown() {
    return DropdownButtonFormField<ClientModel>(
      value: selectedClient,
      dropdownColor: const Color(0xff203A43),
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: Colors.white70,
      decoration: _decoration("Select Client"),
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
      dropdownColor: const Color(0xff203A43),
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: Colors.white70,
      decoration: _decoration("Day"),
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
      style: const TextStyle(color: Colors.white),
      decoration: _decoration("Water Intake (Litres)"),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: _glassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Small, clear icon so each meal reads at a glance.
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _accent.withOpacity(.16),
                  ),
                  child: Icon(
                    Icons.restaurant,
                    color: _accent,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "Meal ${index + 1}",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  onPressed: () => removeMeal(index),
                ),
              ],
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: meal.mealType,
              dropdownColor: const Color(0xff203A43),
              style: const TextStyle(color: Colors.white),
              iconEnabledColor: Colors.white70,
              decoration: _decoration("Meal Type"),
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
              style: const TextStyle(color: Colors.white),
              decoration: _decoration("Food"),
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
              style: const TextStyle(color: Colors.white),
              decoration: _decoration("Quantity"),
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
              style: const TextStyle(color: Colors.white),
              decoration: _decoration("Calories"),
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

  @override
  Widget build(BuildContext context) {
    if (loadingClients) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: _bgGradient),
          child: Center(
            child: CircularProgressIndicator(color: _accent),
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _glassAppBar(widget.diet == null ? "Add Diet" : "Edit Diet"),
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
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.fromLTRB(20, kToolbarHeight + 14, 20, 20),
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
                    style: const TextStyle(color: Colors.white),
                    decoration: _decoration("Notes"),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    "Meals",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 15),

                  ...List.generate(meals.length, (index) => mealCard(index)),

                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(.30)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: addMeal,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(
                      "Add Meal",
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: loading ? null : saveDiet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.black,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              widget.diet == null
                                  ? "SAVE DIET"
                                  : "UPDATE DIET",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
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
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Diet title is required";
        }
        return null;
      },
      decoration: _decoration("Diet Title"),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    notesController.dispose();
    super.dispose();
  }
}