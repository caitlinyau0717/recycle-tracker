import 'dart:io';
import 'package:flutter/material.dart';

class ScanDetailPage extends StatelessWidget {
  final File? imageFile;
  final String? barcodeValue;

  const ScanDetailPage({super.key, this.imageFile, this.barcodeValue});

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

          // Show image if available
          if (imageFile != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(imageFile!, height: 200, fit: BoxFit.cover),
              ),
            ),

          // Show barcode result
          if (barcodeValue != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '📦 Scanned Barcode: $barcodeValue',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),

          const SizedBox(height: 16),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildItem('Coca Cola 16 oz Bottle', '\$0.05'),
                _buildItem('Mountain Dew 16 oz Bottle', '\$0.05'),
                _buildItem('Poland Spring 8 oz Bottle', '\$0.10', count: 2),
                _buildItem('Sprite 8 oz Can', '\$0.05'),
              ],
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
                  child: const Text(
                    'Total: \$0.25',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
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
            const CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage('assets/profile.jpg'),
            ),
            Image.asset('assets/logo.png', height: 40),
            IconButton(
              icon: const Icon(Icons.camera_alt_rounded, size: 40),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String name, String price, {int count = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
            if (count > 1)
              Text('x$count', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 4),
        Text(price, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        const Divider(color: Colors.green),
      ],
    );
  }
}
