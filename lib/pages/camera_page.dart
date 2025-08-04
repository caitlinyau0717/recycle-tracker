import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:gal/gal.dart';
import 'ScanDetailPage.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  final PageController _pageController = PageController(viewportFraction: 0.30);
  final ImagePicker _picker = ImagePicker();
  int _selectedPage = 0;

  final List<String> scanModes = ['Quick Scan', 'Bulk Scan'];

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
      final XFile image = await _controller!.takePicture();

      // Save to gallery using gal
      await Gal.putImage(image.path);
      print('Saved to gallery: ${image.path}');

      // Scan barcode from captured image
      File imageFile = File(image.path);
      final inputImage = InputImage.fromFile(imageFile);
      final barcodeScanner = BarcodeScanner();
      final List<Barcode> barcodes = await barcodeScanner.processImage(inputImage);
      await barcodeScanner.close();

      String? barcodeValue;
      if (barcodes.isNotEmpty) {
        barcodeValue = barcodes.first.rawValue;
        print("Barcode from camera: $barcodeValue");
      }

      // Open gallery picker for more selection
      final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        File pickedFile = File(pickedImage.path);
        final pickedInput = InputImage.fromFile(pickedFile);
        final pickedScanner = BarcodeScanner();
        final List<Barcode> pickedBarcodes = await pickedScanner.processImage(pickedInput);

        String? pickedValue;
        if (pickedBarcodes.isNotEmpty) {
          pickedValue = pickedBarcodes.first.rawValue;
          print("Barcode from gallery: $pickedValue");
        }

        await pickedScanner.close();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanDetailPage(
              imageFile: pickedFile,
              barcodeValue: pickedValue ?? barcodeValue,
            ),
          ),
        );
      } else {
        // If no gallery image picked, just show the captured image
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanDetailPage(
              imageFile: imageFile,
              barcodeValue: barcodeValue,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error during capture/save/scan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Row(
                          children: [
                            Icon(Icons.arrow_back_ios, color: Colors.black54, size: 16),
                            Text('home', style: TextStyle(color: Colors.black54, fontSize: 16)),
                          ],
                        ),
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
                        final isSelected = index == _selectedPage;
                        return GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                            setState(() {
                              _selectedPage = index;
                            });
                          },
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.green.withAlpha((0.8 * 255).toInt())
                                    : Colors.black.withAlpha((0.6 * 255).toInt()),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                scanModes[index],
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                          )
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

                      // Check Button
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
