import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'ScanDetailPage.dart';
import 'session_gallery_page.dart';
import 'profile_page.dart';
import 'home.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  enum ScanType {
  quick(0),
  bulk(1);
  const ScanType(this.code);
  final int code;
  static ScanType fromCode(int code) =>
      ScanType.values.firstWhere((e) => e.code == code);
  }
class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

List<String> scannedBarcodes = [];

class _CameraPageState extends State<CameraPage> with RouteAware {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  final PageController _pageController = PageController(viewportFraction: 0.30);
  final ImagePicker _picker = ImagePicker();
  int _selectedPage = 0;

  List<File> _sessionPhotos = [];
  final List<String> scanModes = ['Quick Scan', 'Bulk Scan'];
  ScanType _currMode = ScanType.quick;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void didPopNext() {
    // Called when returning to CameraPage
    final route = ModalRoute.of(context);
    if (route?.settings.name == null) {
      // Default pop back from unnamed route like ScanDetailPage
      setState(() {
        _sessionPhotos.clear();
        scannedBarcodes.clear();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }
  //
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
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> _captureAndSaveAndScan() async {
    try {
      final XFile image = await _controller!.takePicture();
      File imageFile = File(image.path);

      setState(() {
        _sessionPhotos.add(imageFile);
      });
    } catch (e) {
      print('Error during capture/save: $e');
    }
  }

  Future<void> _submitSessionPhotos() async {
    //if session photos don't exist then say so and move onto barcode scanning
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
    //Suggestion: bulk scan and quick delete so be wary
    //barcode scanning
    final barcodeScanner = BarcodeScanner();
    scannedBarcodes.clear();
    List<int> _barcodeOrigin = [];
    int _barcodeIndex = 0;
    for (final image in _sessionPhotos) {
      final inputImage = InputImage.fromFile(image);
      final List<Barcode> barcodes = await barcodeScanner.processImage(inputImage);
        if (barcodes.isNotEmpty) {
          if(_currMode == ScanType.quick){
            print("sdk");
            scannedBarcodes.add(barcodes.first.rawValue ?? 'Unknown');
            _barcodeOrigin.add(_barcodeIndex);
          }
          if(_currMode == ScanType.bulk){
            for (Barcode barcode in barcodes){
            scannedBarcodes.add(barcode.rawValue ?? 'Unknown');
            _barcodeOrigin.add(_barcodeIndex);
            }
          }
        } else {
        scannedBarcodes.add('No barcode found');
        }
        _barcodeIndex++;
    }

    await barcodeScanner.close();
    //build details
    final sessionCompleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ScanDetailPage(
          images: _sessionPhotos,
          barcodeValues: scannedBarcodes,
          barcodeIndex: _barcodeOrigin,
        ),
      ),
    );
    if (sessionCompleted == true) {
      setState(() {
        _sessionPhotos.clear();
        scannedBarcodes.clear();
      });
    }

    // If the user finished the session by pressing "Done"
    if (sessionCompleted == true) {
      setState(() {
        _sessionPhotos.clear();
        scannedBarcodes.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final scanBoxWidth = screenSize.width * 0.9;
    final scanBoxHeight = screenSize.height * 0.6;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _controller == null || !_controller!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned.fill(
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment(0.0, -0.3),
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
                        alignment: Alignment(0.0, -0.3),
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

                Positioned(
                  top: 50,
                  left: 16,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                            (Route<dynamic> route) => false,
                          );
                        },
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
                        setState(() {
                        _selectedPage = index;
                        _currMode = ScanType.fromCode(index);
                        });
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
                              _currMode = ScanType.fromCode(index);
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

                      Positioned(
                        bottom: 40,
                        left: 0,
                        right: 0,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Shutter button – centered under logo
                            GestureDetector(
                              onTap: () {
                                _captureAndSaveAndScan();
                                ScaffoldMessenger.of(context).showSnackBar(
                                   SnackBar(
                                    content: Text("Scanned"),
                                    duration: Duration(milliseconds: 500),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                if (_currMode == ScanType.bulk){
                                  print("bulk scan dect\n");
                                  _submitSessionPhotos();
                                }
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

                            // Gallery button – floated to the left of center
                            Positioned(
                              left: MediaQuery.of(context).size.width / 2 - 140,
                              child: GestureDetector(
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
                            ),

                            // Submit button – floated to the right of center
                            Positioned(
                              right: MediaQuery.of(context).size.width / 2 - 175,
                              child: GestureDetector(
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
                            ),
                          ],
                        ),
                      ),
              ],
            ),

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
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
//make bulk scan different