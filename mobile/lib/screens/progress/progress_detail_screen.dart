import 'package:flutter/material.dart';
import '../../models/progress_model.dart';

class ProgressDetailScreen extends StatelessWidget {
  final ProgressModel progress;

  const ProgressDetailScreen({
    super.key,
    required this.progress,
  });

  Widget measurementTile(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Progress Details"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [

                  const CircleAvatar(
                    radius: 35,
                    child: Icon(
                      Icons.show_chart,
                      size: 35,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    "${progress.weight} kg",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    "BMI : ${progress.bmi}",
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    progress.date
                        .toLocal()
                        .toString()
                        .split(" ")[0],
                  ),

                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          measurementTile(
            "Height",
            "${progress.height} cm",
          ),

          measurementTile(
            "Body Fat",
            "${progress.bodyFat} %",
          ),

          measurementTile(
            "Chest",
            "${progress.chest} cm",
          ),

          measurementTile(
            "Waist",
            "${progress.waist} cm",
          ),

          measurementTile(
            "Biceps",
            "${progress.biceps} cm",
          ),

          measurementTile(
            "Forearm",
            "${progress.forearm} cm",
          ),

          measurementTile(
            "Thigh",
            "${progress.thigh} cm",
          ),

          measurementTile(
            "Shoulder",
            "${progress.shoulder} cm",
          ),

          measurementTile(
            "Neck",
            "${progress.neck} cm",
          ),

          if (progress.notes.isNotEmpty) ...[
            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Trainer Notes",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(progress.notes),

                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}