import 'package:flutter/material.dart';

class HistoryDetailPage extends StatelessWidget {
  final String sessionDate;

  const HistoryDetailPage({super.key, required this.sessionDate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Session on $sessionDate")),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        separatorBuilder: (context, _) => const Divider(color: Colors.green),
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Item ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text("0.00"),
              ],
            ),
            subtitle: const Text("Barcode: No barcode found"),
          );
        },
      ),
    );
  }
}
