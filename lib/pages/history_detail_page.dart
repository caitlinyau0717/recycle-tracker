import 'dart:io';
import 'package:flutter/material.dart';
import '../models/scan_session.dart';

class HistoryDetailPage extends StatelessWidget {
  final ScanSession session;
  const HistoryDetailPage({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Session on ${_formatDateTime(session.dateTime)}")),
      body: Column(
        children: [
          if ((session.imagePaths ?? []).isNotEmpty)
            SizedBox(
              height: 120,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                scrollDirection: Axis.horizontal,
                itemCount: session.imagePaths!.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final path = session.imagePaths![i];
                  final file = File(path);
                  if (!file.existsSync()) {
                    return Container(
                      width: 100,
                      height: 120,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade100,
                      ),
                      child: const Text("Image\nnot found", textAlign: TextAlign.center),
                    );
                  }
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(file, width: 100, height: 120, fit: BoxFit.cover),
                  );
                },
              ),
            ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: session.items.length,
              separatorBuilder: (context, _) => const Divider(color: Colors.green),
              itemBuilder: (context, index) {
                final item = session.items[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Item ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("\$${item.deposit}"),
                    ],
                  ),
                  subtitle: Text("Barcode: ${item.barcode}"),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Total: \$${session.total.toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    final mm = two(dt.month);
    final dd = two(dt.day);
    final yy = two(dt.year % 100);
    final hour12 = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = two(dt.minute);
    return "$mm/$dd/$yy  $hour12:$min $ampm";
  }
}
