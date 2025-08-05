import 'dart:io';
import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'home.dart';

class ScanDetailPage extends StatelessWidget {
  final List<File> images;
  final List<String> barcodeValues;

  const ScanDetailPage({
    super.key,
    required this.images,
    required this.barcodeValues,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top Bar
          Container(
            color: const Color(0xFFD5EFCD),
            padding: const EdgeInsets.only(top: 50, bottom: 15, left: 16, right: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Details',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Scrollable list of session images
          if (images.isNotEmpty)
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      images[index],
                      width: 120,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 16),

          // Barcode value list
          Expanded(
            child: barcodeValues.isEmpty
                ? const Center(child: Text("No barcodes found."))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: barcodeValues.length,
                    itemBuilder: (context, index) {
                      return _buildScannedItem(barcodeValues[index], index + 1);
                    },
                  ),
          ),

          // Bottom Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Total: \$${(barcodeValues.length * 0.05).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.green),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.check),
                  label: const Text('Done'),
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom nav
      bottomNavigationBar: Container(
        color: const Color(0xFFD5EFCD),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              child: CircleAvatar(
                radius: 25,
                // CHRIS: PROFILE PIC GOES HERE
                backgroundImage: AssetImage('assets/ProfilePic.png'),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Image.asset('assets/logo.png', height: 40),
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt_rounded, size: 40),
              onPressed: () {
                // Already on camera screen
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannedItem(String barcode, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Item $index',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            Text('\$0.05', style: const TextStyle(fontSize: 16)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Barcode: $barcode',
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const Divider(color: Colors.green),
      ],
    );
  }
}
