import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'ScanDetailPage.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  final PageController _pageController = PageController(viewportFraction: 0.45);
  final ImagePicker _picker = ImagePicker();
  int _selectedPage = 0;
  bool isLoading = false;
  Map<String, dynamic>? productData;

  final List<String> scanModes = ['Quick Scan', 'Bulk Scan'];

  List<File> _bulkScannedImages = [];
  List<String> _bulkScannedBarcodes = [];
  List<Map<String, dynamic>> _bulkProductData = [];

  Future<Map<String, dynamic>?> fetchProductData(String barcode) async {
    final url = Uri.parse('https://world.openfoodfacts.org/api/v2/product/$barcode.json');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching product data: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      _controller = CameraController(_cameras.first, ResolutionPreset.high);
      await _controller!.initialize();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _captureAndSaveAndScan() async {
    try {
      setState(() => isLoading = true);
      final XFile image = await _controller!.takePicture();
      await Gal.putImage(image.path);

      File imageFile = File(image.path);
      final inputImage = InputImage.fromFile(imageFile);
      final barcodeScanner = BarcodeScanner();
      final List<Barcode> barcodes = await barcodeScanner.processImage(inputImage);
      await barcodeScanner.close();

      if (barcodes.isNotEmpty) {
        final barcodeValue = barcodes.first.rawValue!;
        final productData = await fetchProductData(barcodeValue);

        if (_selectedPage == 0) { // Single scan mode
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScanDetailPage(
                images: [imageFile],
                barcodeValues: [barcodeValue],
              ),
            ),
          );
        } else { // Bulk scan mode
          setState(() {
            _bulkScannedImages.add(imageFile);
            _bulkScannedBarcodes.add(barcodeValue);
            _bulkProductData.add(productData ?? {});
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Added ${_bulkScannedImages.length} items')),
          );
        }
      }
    } catch (e) {
      print('Error during capture: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _navigateToBulkResults() {
    if (_bulkScannedImages.isEmpty) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanDetailPage(
          images: _bulkScannedImages,
          barcodeValues: _bulkScannedBarcodes,
        ),
      ),
    );
  }

  // Update the check button to handle bulk mode
  Widget _buildCheckButton() {
    return GestureDetector(
      onTap: _selectedPage == 0 
          ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => ScanDetailPage(images: [], barcodeValues: [])))
          : _navigateToBulkResults,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.check, color: Colors.green, size: 28),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (keep your existing build method exactly the same)

    final screenSize = MediaQuery.of(context).size;
    final scanBoxWidth = screenSize.width * 0.9;
    final scanBoxHeight = screenSize.height * 0.5;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _controller == null || !_controller!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Camera preview inside scan box
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
                            child: CameraPreview(_controller!),
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

                // Top back button
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

                // Swipeable scan mode bar
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

                // Under-scan controls: $ saved - shutter - check button
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

                      // 📸 Shutter button (save + gallery)
                      GestureDetector(
                        onTap: _captureAndSaveAndScan,
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

                      // ✅ Check Button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ScanDetailPage()),
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

      // Bottom footer
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