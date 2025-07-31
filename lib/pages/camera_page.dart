import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  final MobileScannerController _scannerController = MobileScannerController();
  final PageController _pageController = PageController(viewportFraction: 0.45);

  final List<String> scanModes = ['Quick Scan', 'Bulk Scan'];
  int _selectedPage = 0;
  bool _isScanning = false;
  String? _lastScanned;

  @override
  void dispose() {
    _scannerController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _handleBarcodeDetection(List<Barcode> barcodes) {
    if (_isScanning || barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null || code == _lastScanned) return;

    _lastScanned = code;
    _isScanning = true;

    fetchProductInfo(code, context).then((_) {
      Future.delayed(const Duration(seconds: 3), () {
        _isScanning = false;
      });
    });
  }

  Future<void> fetchProductInfo(String barcode, BuildContext context) async {
    OpenFoodAPIConfiguration.userAgent = UserAgent(
      name: 'MyScannerApp',
      url: 'https://example.com',
    );

    final config = ProductQueryConfiguration(
      barcode,
      version: ProductQueryVersion.v3,
    );

    final result = await OpenFoodAPIClient.getProductV3(config);

    final name = result.product?.productName ?? 'Product not found';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Product: $name')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final scanBoxWidth = screenSize.width * 0.9;
    final scanBoxHeight = screenSize.height * 0.5;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Live camera with barcode scanner
          Positioned.fill(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: scanBoxWidth,
                      height: scanBoxHeight,
                      child: MobileScanner(
                        controller: _scannerController,
                        allowDuplicates: false,
                        onDetect: (capture) {
                          _handleBarcodeDetection(capture.barcodes);
                        },
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: scanBoxWidth,
                    height: scanBoxHeight,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Back button
          Positioned(
            top: 50,
            left: 16,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'home',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ],
            ),
          ),

          // Scan mode selector
          Positioned(
            bottom: 130,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 40,
              child: PageView.builder(
                controller: _pageController,
                itemCount: scanModes.length,
                onPageChanged: (index) {
                  setState(() => _selectedPage = index);
                },
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        scanModes[index],
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Bottom scan status + action buttons
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    children: [
                      Text('\$0.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('saved', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isScanning = true;
                    });
                    // You could also trigger a manual scan timeout here if needed
                  },
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green, width: 4),
                      color: Colors.grey[300],
                    ),
                    child: const Icon(Icons.camera_alt, size: 30),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Manually confirmed scan.')),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.check, color: Colors.green, size: 28),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom navigation bar
      bottomNavigationBar: Container(
        color: const Color(0xFFD5EFCD),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage('assets/ProfilePic.png'),
            ),
            Image.asset('assets/logo.png', height: 40),
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
}
