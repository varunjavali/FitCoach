import 'dart:ui';

import 'package:fit_coach/screens/diet/diet_detail_screen.dart' show DietDetailScreen;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  //---------------------------------------------------------
  // Themed delete confirmation dialog
  //---------------------------------------------------------

  Future<void> deleteDiet(String dietId) async {
    final confirm = await showDialog<bool>(
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
                    "Delete Diet",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Are you sure you want to delete this diet?",
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
                          "Delete",
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
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
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              // Small, clear icon circle — sized to read as a
              // label, not compete with the diet title.
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _accent.withOpacity(.16),
                ),
                child: Icon(
                  Icons.restaurant_menu,
                  color: _accent,
                  size: 20,
                ),
              ),
              title: Text(
                diet.title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 13,
                          color: Colors.white38,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          diet.day,
                          style: GoogleFonts.poppins(
                            color: Colors.white60,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_dining,
                          size: 13,
                          color: Colors.white38,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "${diet.meals.length} Meals",
                          style: GoogleFonts.poppins(
                            color: Colors.white60,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              trailing: PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white70,
                  size: 20,
                ),
                color: const Color(0xff203A43),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white.withOpacity(.15)),
                ),
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
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: "edit",
                    child: Text(
                      "Edit",
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                  PopupMenuItem(
                    value: "delete",
                    child: Text(
                      "Delete",
                      style: GoogleFonts.poppins(
                        color: Colors.redAccent.shade100,
                      ),
                    ),
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
          ),
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
                fontSize: 17,
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _glassAppBar("${widget.client.name}'s Diet Plans"),
      floatingActionButton: FloatingActionButton.extended(
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
        backgroundColor: _accent,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: Text(
          "Assign Diet",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
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
            child: loading
                ? Center(
                    child: CircularProgressIndicator(color: _accent),
                  )
                : RefreshIndicator(
                    onRefresh: loadDiets,
                    color: _accent,
                    backgroundColor: const Color(0xff203A43),
                    child: diets.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.only(top: kToolbarHeight),
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * .5,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                              Colors.white.withOpacity(.08),
                                        ),
                                        child: const Icon(
                                          Icons.restaurant_outlined,
                                          color: Colors.white54,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        "No diet plans assigned",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white70,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: EdgeInsets.fromLTRB(
                              15,
                              kToolbarHeight + 16,
                              15,
                              16,
                            ),
                            itemCount: diets.length,
                            itemBuilder: (_, index) {
                              return dietCard(
                                diets[index],
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