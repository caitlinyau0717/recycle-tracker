import 'dart:io';
import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'home.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'quantity_advanced.dart';


class ScanDetailPage extends StatelessWidget {
  final List<File> images;
  final List<String> barcodeValues;
  final List<int> barcodeIndex;
  const ScanDetailPage({
    super.key,
    required this.images,
    required this.barcodeValues,
    required this.barcodeIndex,
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
                itemCount: barcodeIndex.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  int curr_Index = barcodeIndex[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      images[curr_Index],
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
  Future<String?> fetchProductInfo(String barcode) async {
    OpenFoodAPIConfiguration.userAgent = UserAgent(
      name: 'MyScannerApp',
      url: 'https://example.com',
    );

    final config = ProductQueryConfiguration(
      barcode,
      version: ProductQueryVersion.v3,
    );

    final result = await OpenFoodAPIClient.getProductV3(config);

    final name = result.product?.productName ?? 'null';
    String packaging = result.product?.packaging?? 'null';
    String categories = result.product?.categories?? 'null';
    categories = categories.toLowerCase();
    packaging = packaging.toLowerCase();
    if(name == 'null'){
      return '0.0';
    }
    return fetchBottleInfo(barcode: barcode, stateCode: 'NY');

  }

Widget _buildScannedItem(String barcode, int index) {
  return FutureBuilder<String?>(
    future: fetchProductInfo(barcode),
    builder: (context, snapshot) {
      String displayValue;
      if (snapshot.connectionState == ConnectionState.waiting) {
        displayValue = 'Loading...';
      } else if (snapshot.hasError) {
        displayValue = 'Error';
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        displayValue = '\$0.00'; // fallback value if empty string
      } else {
        displayValue = snapshot.data!;
      }
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
              Text(displayValue, style: const TextStyle(fontSize: 16)),
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
    },
  );
}
}
