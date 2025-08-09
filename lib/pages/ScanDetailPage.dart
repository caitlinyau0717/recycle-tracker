import 'dart:io';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import '../models/scan_session.dart'; // relative path from pages folder
import 'profile_page.dart';
import 'home.dart';
import 'interPageComms.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'quantity_advanced.dart';
import 'package:recycletracker/db_connection.dart';


import 'package:provider/provider.dart';

class ScanDetailPage extends StatelessWidget {
  final mongo.ObjectId id;
  final List<File> images;
  final List<String> barcodeValues;
  final List<int> barcodeIndex;

  

  const ScanDetailPage({
    super.key,
    required this.images,
    required this.barcodeValues,
    required this.barcodeIndex,
    required this.id
  });

  @override
  Widget build(BuildContext context) {
    var id = context.read<UserData>().id;
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
                  int currIndex = barcodeIndex[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      images[currIndex],
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
                  onPressed: () => _saveSessionAndClose(context),
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
                  MaterialPageRoute(builder: (context) => ProfilePage(id: id)),
                );
              },
              child: const CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage('assets/ProfilePic.png'),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage(id: id)),
                  (Route<dynamic> route) => false,
                );
              },
              child: Image.asset('assets/logo.png', height: 40),
            ),
            const Icon(Icons.camera_alt_rounded, size: 40),
          ],
        ),
      ),
    );
  }

  /// Fetches deposit value for a given barcode using OpenFoodFacts
  Future<String?> fetchProductInfo(String barcode) async {
    OpenFoodAPIConfiguration.userAgent = UserAgent(
      name: 'MyScannerApp',
      url: 'https://example.com',
    );

    final config = ProductQueryConfiguration(
      barcode,
      version: ProductQueryVersion.v3,
      language: OpenFoodFactsLanguage.ENGLISH,
    );

    final result = await OpenFoodAPIClient.getProductV3(config);

    final name = result.product?.productName ?? 'null';
    String packaging = result.product?.packaging ?? 'null';
    List<String> categories = result.product?.categoriesTags ?? [];
    packaging = packaging.toLowerCase();

    if (name == 'null') {
      return '0.00';
    }

    bool isBev = false;
    for (String tag in categories) {
      tag = tag.toLowerCase();
      if (tag.contains("beverage")) {
        isBev = true;
        break;
      }
    }
    return fetchBottleInfo(barcode: barcode, stateCode: 'NY');

  }

  /// Builds the live list item view
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
          displayValue = '\$0.00';
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

  /// Saves the session to SharedPreferences and returns to previous page
  Future<void> _saveSessionAndClose(BuildContext context) async {
    // 1) Resolve deposits
    final deposits = await Future.wait(
      barcodeValues.map((b) async => await fetchProductInfo(b)),
    );

    // 2) Build ScanItems
    final items = <ScanItem>[];
    double total = 0.0;
    for (int i = 0; i < barcodeValues.length; i++) {
      final dStr = deposits[i]?.trim().replaceAll('\$', '');
      final d = double.tryParse(dStr!) ?? 0.0;
      total += d;
      items.add(
        ScanItem(
          barcode: barcodeValues[i],
          deposit: d.toStringAsFixed(2),
        ),
      );
    }

    // 3) Store selected image paths
    final selectedPaths = barcodeIndex.map((idx) => images[idx].path).toList();

    // 4) Create session
    final session = ScanSession(
      id: const Uuid().v4(),
      dateTime: DateTime.now(),
      items: items,
      total: total,
      imagePaths: selectedPaths,
    );

    // 5) Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final key = 'scan_history';
    final existing = prefs.getString(key);
    final sessions = existing == null
        ? <ScanSession>[]
        : ScanSession.decodeList(existing);

    sessions.insert(0, session); // newest first
    const maxSessions = 5;
    if (sessions.length > maxSessions) {
      sessions.removeRange(maxSessions, sessions.length);
    }

    await prefs.setString(key, ScanSession.encodeList(sessions));

    // 6) Pop back
    Navigator.pop(context, true);
  }
}
