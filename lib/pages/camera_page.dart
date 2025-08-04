import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'ScanDetailPage.dart';
import 'session_gallery_page.dart';

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

  List<File> _sessionPhotos = [];

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
      File imageFile = File(image.path);

      setState(() {
        _sessionPhotos.add(imageFile); // Save image to session memory
      });
    } catch (e) {
      print('Error during capture/save: $e');
    }
  }

  Future<void> _submitSessionPhotos() async {
    if (_sessionPhotos.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("No Photos Taken"),
          content: const Text("Please take at least one photo before submitting."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }
    
    final File lastImage = _sessionPhotos.last;
    final inputImage = InputImage.fromFile(lastImage);

    final barcodeScanner = BarcodeScanner();
    final List<Barcode> barcodes = await barcodeScanner.processImage(inputImage);
    await barcodeScanner.close();

    String? barcodeValue;
    if (barcodes.isNotEmpty) {
      barcodeValue = barcodes.first.rawValue;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanDetailPage(
          imageFile: lastImage,
          barcodeValue: barcodeValue,
        ),
      ),
    );
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
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back_ios, color: Colors.black54, size: 16),
                        Text('home', style: TextStyle(color: Colors.black54, fontSize: 16)),
                      ],
                    ),
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
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // ✅ Under-scan controls: Gallery - Shutter - Submit
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 📂 Session Gallery Button (left)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SessionGalleryPage(
                                images: _sessionPhotos,
                                onDelete: (File image) {
                                  setState(() {
                                    _sessionPhotos.remove(image);
                                  });
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.photo_library, color: Colors.green, size: 28),
                        ),
                      ),

                      // 📸 Shutter button (center)
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

                      // Submit button (right)
                      GestureDetector(
                        onTap: _submitSessionPhotos,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: const [
                              Text(
                                "Submit",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.check_circle, color: Colors.green, size: 24),
                            ],
                          ),
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
