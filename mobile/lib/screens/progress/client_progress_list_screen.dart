import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
  final ProgressService progressService = ProgressService();

  List<ProgressModel> progressList = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("Login expired");
      }

      final data = await progressService.getClientProgress(
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

  //----------------------------------------------------
  // Weight trend chart
  //----------------------------------------------------

  List<ProgressModel> get _chronological {
    final sorted = [...progressList]
      ..sort((a, b) => a.date.compareTo(b.date));
    return sorted;
  }

  Widget _weightChart() {
    final points = _chronological;

    if (points.length < 2) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              "Add at least 2 progress entries to see the weight trend",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
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

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8, bottom: 12),
              child: Text(
                "Weight Trend",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minY: (minY - 2).floorToDouble(),
                  maxY: (maxY + 2).ceilToDouble(),
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 34,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withOpacity(0.12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //----------------------------------------------------
  // Progress entry card (view only — no edit/delete)
  //----------------------------------------------------

  Widget progressCard(ProgressModel progress) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.show_chart),
        ),
        title: Text(
          "${progress.weight} kg",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("BMI : ${progress.bmi}"),
            Text("Body Fat : ${progress.bodyFat} %"),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProgressDetailScreen(
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
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () async {
      //     final result = await Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (_) => const AddProgressScreen(),
      //       ),
      //     );

      //     if (result == true) {
      //       loadProgress();
      //     }
      //   },
      //   icon: const Icon(Icons.add),
      //   label: const Text("Add Progress"),
      // ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadProgress,
              child: ListView(
                padding: const EdgeInsets.all(15),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _weightChart(),
                  const SizedBox(height: 20),
                  if (progressList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          "No progress records found",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    )
                  else
                    ...progressList.map(progressCard),
                ],
              ),
            ),
    );
  }
}