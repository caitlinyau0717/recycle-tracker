import 'dart:io';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/scan_session.dart'; // from lib/pages -> lib/models
import 'profile_page.dart';
import 'home.dart';

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

  // ----------------- helpers -----------------

  List<String> _validBarcodes() =>
      barcodeValues.where((b) => b.trim().isNotEmpty).toList();

  double _parseDeposit(String s) {
    final cleaned = s.replaceAll('\$', '').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  Future<double> _computeLiveTotal() async {
    final barcodes = _validBarcodes();
    if (barcodes.isEmpty) return 0.0;

    // Fetch name+deposit for each, then sum deposits
    final List<Map<String, String>> infos = await Future.wait<Map<String, String>>(
      barcodes.map<Future<Map<String, String>>>((b) async => await fetchProductInfo(b)),
    );

    double sum = 0.0;
    for (final info in infos) {
      sum += _parseDeposit(info['deposit'] ?? '0.00');
    }
    return sum;
  }

  // ------------- OpenFoodFacts lookup -------------

  /// Returns both product name and deposit for a barcode.
  /// Keys: 'name' and 'deposit' (string like "0.05").
  Future<Map<String, String>> fetchProductInfo(String barcode) async {
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

    final name = result.product?.productName?.trim();
    final categories = result.product?.categoriesTags ?? [];

    // Simple beverage check; tweak later if you want state/packaging logic
    final isBev = categories.any((t) => t.toLowerCase().contains('beverage'));

    // For now you return 0.05 either way; keeps behavior consistent
    final deposit = isBev ? '0.05' : '0.05';

    return {
      'name': (name == null || name.isEmpty) ? 'Unknown Product' : name,
      'deposit': deposit,
    };
  }

  // ----------------- UI pieces -----------------

  /// Renders a row showing product name (title), deposit on the right, and barcode as subtitle.
  Widget _buildScannedItem(String barcode, int index) {
    return FutureBuilder<Map<String, String>>(
      future: fetchProductInfo(barcode),
      builder: (context, snapshot) {
        String title = 'Loading...';
        String depositText = 'Loading...';

        if (snapshot.connectionState == ConnectionState.waiting) {
          // keep defaults
        } else if (snapshot.hasError) {
          title = 'Lookup error';
          depositText = 'Error';
        } else if (snapshot.hasData) {
          final data = snapshot.data!;
          final name = data['name'] ?? 'Unknown Product';
          final depStr = data['deposit'] ?? '0.00';
          final dep = _parseDeposit(depStr);
          title = name;
          depositText = '\$${dep.toStringAsFixed(2)}';
        } else {
          title = 'Unknown Product';
          depositText = '\$0.00';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Text(depositText, style: const TextStyle(fontSize: 16)),
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

  // ------------- save & close (names later) -------------

  /// Saves the session to SharedPreferences and pops. We still store just barcode+deposit for now.
  Future<void> _saveSessionAndClose(BuildContext context) async {
    final barcodes = _validBarcodes();

    // fetch deposits using the same name+deposit API, but only keep deposits (names later)
    final List<Map<String, String>> infos = await Future.wait<Map<String, String>>(
      barcodes.map<Future<Map<String, String>>>((b) async => await fetchProductInfo(b)),
    );

    final items = <ScanItem>[];
    double total = 0.0;

    for (int i = 0; i < barcodes.length; i++) {
      final dep = _parseDeposit(infos[i]['deposit'] ?? '0.00');
      total += dep;
      items.add(
        ScanItem(
          barcode: barcodes[i],
          deposit: dep.toStringAsFixed(2),
        ),
      );
    }

    // Save the images referenced by this session
    final selectedPaths = barcodeIndex
        .where((idx) => idx >= 0 && idx < images.length)
        .map((idx) => images[idx].path)
        .toList();

    final session = ScanSession(
      id: const Uuid().v4(),
      dateTime: DateTime.now(),
      items: items,
      total: total,
      imagePaths: selectedPaths,
    );

    final prefs = await SharedPreferences.getInstance();
    const key = 'scan_history';
    final existing = prefs.getString(key);
    final sessions = existing == null
        ? <ScanSession>[]
        : ScanSession.decodeList(existing);

    sessions.insert(0, session);
    const maxSessions = 5;
    if (sessions.length > maxSessions) {
      sessions.removeRange(maxSessions, sessions.length);
    }

    await prefs.setString(key, ScanSession.encodeList(sessions));

    Navigator.pop(context, true);
  }

  // ----------------- widget -----------------

  @override
  Widget build(BuildContext context) {
    final barcodes = _validBarcodes();

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

          // Scrollable list of session images (from indices)
          if (images.isNotEmpty && barcodeIndex.isNotEmpty)
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: barcodeIndex.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final currIndex = barcodeIndex[index];
                  if (currIndex < 0 || currIndex >= images.length) {
                    return Container(
                      width: 120,
                      height: 140,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade100,
                      ),
                      child: const Text('Image\nnot found', textAlign: TextAlign.center),
                    );
                  }
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

          // Barcode value list (now shows product names)
          Expanded(
            child: barcodes.isEmpty
                ? const Center(child: Text("No barcodes found."))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: barcodes.length,
                    itemBuilder: (context, index) {
                      return _buildScannedItem(barcodes[index], index + 1);
                    },
                  ),
          ),

          // Bottom Row: live total + Done
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
                  child: FutureBuilder<double>(
                    future: _computeLiveTotal(),
                    builder: (context, snap) {
                      final total = (snap.data ?? 0.0).toStringAsFixed(2);
                      return Text(
                        'Total: \$$total',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      );
                    },
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
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
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
                  MaterialPageRoute(builder: (context) => HomePage()),
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
}
