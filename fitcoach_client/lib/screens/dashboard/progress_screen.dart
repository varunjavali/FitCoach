import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/api_constants.dart';
import '../../models/progress_model.dart';
import '../../services/progress_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final ProgressService progressService = ProgressService();
  final ImagePicker _picker = ImagePicker();

  List<ProgressModel> entries = [];
  bool loading = true;
  bool isOffline = false;
  String? error;

  static const _cacheKey = "cached_progress";
  static const _pendingKey = "pending_progress";

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

  static final _accent = Colors.greenAccent.shade400;

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("clientToken");
  }

  Future<void> loadProgress() async {
    setState(() {
      loading = true;
      error = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = await _getToken();

    if (token == null) {
      setState(() {
        loading = false;
        error = "Login expired";
      });
      return;
    }

    // Flush anything queued from a previous offline session first.
    await _syncPending(token, prefs);

    try {
      final serverEntries = await progressService.getMyProgress(token);

      await prefs.setString(
        _cacheKey,
        jsonEncode(serverEntries.map((e) => e.toJson()).toList()),
      );

      final pending = await _loadPending(prefs);

      setState(() {
        entries = [...pending, ...serverEntries];
        isOffline = false;
        loading = false;
      });
    } catch (e) {
      // Network failed — fall back to whatever's cached locally.
      final cachedJson = prefs.getString(_cacheKey);
      final pending = await _loadPending(prefs);

      if (cachedJson != null) {
        final cached = (jsonDecode(cachedJson) as List)
            .map((e) => ProgressModel.fromJson(e))
            .toList();

        setState(() {
          entries = [...pending, ...cached];
          isOffline = true;
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
          isOffline = true;
          error = pending.isEmpty
              ? "Could not load progress. Check your connection."
              : null;
          entries = pending;
        });
      }
    }
  }

  Future<List<ProgressModel>> _loadPending(SharedPreferences prefs) async {
    final raw = prefs.getString(_pendingKey);
    if (raw == null) return [];

    return (jsonDecode(raw) as List)
        .map((e) => ProgressModel.fromJson(e).copyWith(isPending: true))
        .toList();
  }

  Future<void> _savePending(
    SharedPreferences prefs,
    List<ProgressModel> pending,
  ) async {
    await prefs.setString(
      _pendingKey,
      jsonEncode(pending.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _syncPending(String token, SharedPreferences prefs) async {
    final pending = await _loadPending(prefs);
    if (pending.isEmpty) return;

    final stillPending = <ProgressModel>[];

    for (final entry in pending) {
      try {
        await progressService.addProgress(token, entry);
      } catch (_) {
        stillPending.add(entry);
      }
    }

    await _savePending(prefs, stillPending);
  }

  Future<void> _submitEntry({
    required double weight,
    double? height,
    String notes = "",
    String? photoPath,
  }) async {
    final token = await _getToken();
    if (token == null) return;

    final prefs = await SharedPreferences.getInstance();

    String? photoUrl;
    bool photoDroppedOffline = false;

    if (photoPath != null) {
      try {
        final relativeUrl =
            await progressService.uploadPhoto(token, photoPath);
        photoUrl = "${ApiConstants.mediaBaseUrl}$relativeUrl";
      } catch (_) {
        // Photo upload needs a live connection. If it fails, the entry
        // itself still goes through (queued if needed) — just without
        // the photo.
        photoDroppedOffline = true;
      }
    }

    final bmi = (height != null && height > 0)
        ? double.parse(
            (weight / ((height / 100) * (height / 100)))
                .toStringAsFixed(1),
          )
        : 0.0;

    final draft = ProgressModel(
      id: "local_${DateTime.now().millisecondsSinceEpoch}",
      date: DateTime.now(),
      weight: weight,
      height: height ?? 0,
      bmi: bmi,
      notes: notes,
      photo: photoUrl,
    );

    try {
      final saved = await progressService.addProgress(token, draft);

      setState(() {
        entries = [saved, ...entries];
      });

      if (photoDroppedOffline && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Entry saved, but the photo couldn't be uploaded — check your connection.",
            ),
          ),
        );
      }
    } catch (_) {
      // Offline — queue it locally and show it immediately as pending.
      final pending = await _loadPending(prefs);
      pending.insert(0, draft);
      await _savePending(prefs, pending);

      setState(() {
        entries = [draft.copyWith(isPending: true), ...entries];
        isOffline = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "No connection — entry saved locally and will sync automatically.",
            ),
          ),
        );
      }
    }
  }

  //---------------------------------------------------------
  // Themed input decoration for the Add Entry sheet
  //---------------------------------------------------------

  InputDecoration _fieldDecoration(String label) {
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
    );
  }

  void _openAddSheet() {
    final weightController = TextEditingController();
    final heightController = TextEditingController();
    final notesController = TextEditingController();
    String? pickedPhotoPath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(.14),
                        const Color(0xff203A43).withOpacity(.97),
                      ],
                    ),
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(.25)),
                    ),
                  ),
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom:
                        MediaQuery.of(sheetContext).viewInsets.bottom + 20,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        Text(
                          "Log Progress",
                          style: GoogleFonts.poppins(
                            fontSize: 19,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: weightController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: const TextStyle(color: Colors.white),
                          decoration: _fieldDecoration("Weight (kg) *"),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: heightController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: const TextStyle(color: Colors.white),
                          decoration:
                              _fieldDecoration("Height (cm) — optional"),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: notesController,
                          maxLines: 2,
                          style: const TextStyle(color: Colors.white),
                          decoration: _fieldDecoration("Notes — optional"),
                        ),
                        const SizedBox(height: 12),
                        if (pickedPhotoPath != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(pickedPhotoPath!),
                                height: 140,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withOpacity(.30),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () async {
                            final file = await _picker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 80,
                            );
                            if (file != null) {
                              setSheetState(() {
                                pickedPhotoPath = file.path;
                              });
                            }
                          },
                          icon: const Icon(Icons.add_a_photo, size: 18),
                          label: Text(
                            pickedPhotoPath == null
                                ? "Add Progress Photo"
                                : "Change Photo",
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: _accent,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              final weight = double.tryParse(
                                weightController.text.trim(),
                              );

                              if (weight == null || weight <= 0) {
                                ScaffoldMessenger.of(sheetContext)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text("Enter a valid weight"),
                                  ),
                                );
                                return;
                              }

                              final height = double.tryParse(
                                heightController.text.trim(),
                              );

                              Navigator.pop(sheetContext);

                              _submitEntry(
                                weight: weight,
                                height: height,
                                notes: notesController.text.trim(),
                                photoPath: pickedPhotoPath,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              child: Text(
                                "Save Entry",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _viewPhoto(String urlOrPath) {
    final isNetwork = urlOrPath.startsWith("http");

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black, elevation: 0),
          body: Center(
            child: InteractiveViewer(
              child: isNetwork
                  ? Image.network(urlOrPath)
                  : Image.file(File(urlOrPath)),
            ),
          ),
        ),
      ),
    );
  }

  List<ProgressModel> get chartEntries {
    final sorted = [...entries]..sort((a, b) => a.date.compareTo(b.date));
    return sorted;
  }

  //---------------------------------------------------------
  // Themed building blocks
  //---------------------------------------------------------

  Widget _glassCard({required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
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
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(.18)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _photoThumb(String urlOrPath, {double size = 90}) {
    final isNetwork = urlOrPath.startsWith("http");

    return isNetwork
        ? Image.network(
            urlOrPath,
            width: size,
            height: size,
            fit: BoxFit.cover,
          )
        : Image.file(
            File(urlOrPath),
            width: size,
            height: size,
            fit: BoxFit.cover,
          );
  }

  Widget _buildChart() {
    final points = chartEntries;

    if (points.length < 2) {
      return _glassCard(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            "Log at least 2 entries to see your weight trend",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.white60, fontSize: 13),
          ),
        ),
      );
    }

    final spots = <FlSpot>[
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].weight),
    ];

    final minY = points.map((e) => e.weight).reduce((a, b) => a < b ? a : b);
    final maxY = points.map((e) => e.weight).reduce((a, b) => a > b ? a : b);

    return _glassCard(
      padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Text(
              "Weight Trend",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: (minY - 2).floorToDouble(),
                maxY: (maxY + 2).ceilToDouble(),
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      getTitlesWidget: (value, meta) => Text(
                        value.toStringAsFixed(0),
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: _accent,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: 3.5,
                        color: _accent,
                        strokeWidth: 2,
                        strokeColor: const Color(0xff0F2027),
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: _accent.withOpacity(0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoStrip() {
    final withPhotos = entries.where((e) => e.photo != null).toList();

    if (withPhotos.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: withPhotos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          final entry = withPhotos[index];
          return GestureDetector(
            onTap: () => _viewPhoto(entry.photo!),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(.18)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _photoThumb(entry.photo!),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEntryTile(ProgressModel entry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(.10)),
        ),
        child: Row(
          children: [
            entry.photo != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _photoThumb(entry.photo!, size: 44),
                  )
                : Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _accent.withOpacity(.16),
                    ),
                    child: Icon(
                      Icons.monitor_weight_outlined,
                      color: _accent,
                      size: 18,
                    ),
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${entry.weight.toStringAsFixed(1)} kg"
                    "${entry.bmi > 0 ? "  •  BMI ${entry.bmi.toStringAsFixed(1)}" : ""}",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "${entry.date.day}/${entry.date.month}/${entry.date.year}"
                    "${entry.notes.isNotEmpty ? "  •  ${entry.notes}" : ""}",
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (entry.isPending)
              const Icon(
                Icons.cloud_upload_outlined,
                color: Colors.orangeAccent,
                size: 18,
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _glassAppBar("My Progress"),
      floatingActionButton: Padding(
        // DashboardScreen's Scaffold uses extendBody: true, so this
        // screen's content (and default FAB position) extends behind
        // its translucent bottom nav bar. Lift the FAB clear of it.
        padding: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton.extended(
          onPressed: _openAddSheet,
          backgroundColor: _accent,
          foregroundColor: Colors.black,
          icon: const Icon(Icons.add),
          label: Text(
            "Log Entry",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
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
                    onRefresh: loadProgress,
                    color: _accent,
                    backgroundColor: const Color(0xff203A43),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        16,
                        kToolbarHeight + 16,
                        16,
                        16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isOffline)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.orangeAccent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.orangeAccent.withOpacity(.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.cloud_off,
                                    color: Colors.orangeAccent,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "You're offline — showing cached data. New entries will sync automatically.",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Text(
                                error!,
                                style: GoogleFonts.poppins(
                                  color: Colors.redAccent.shade100,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          _buildChart(),
                          const SizedBox(height: 16),
                          _buildPhotoStrip(),
                          if (entries.any((e) => e.photo != null))
                            const SizedBox(height: 16),
                          Text(
                            "History",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (entries.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 30,
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(.08),
                                      ),
                                      child: const Icon(
                                        Icons.show_chart,
                                        color: Colors.white54,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      "No progress logged yet.\nTap \"Log Entry\" to get started.",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white60,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: entries.length,
                              itemBuilder: (_, index) =>
                                  _buildEntryTile(entries[index]),
                            ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}