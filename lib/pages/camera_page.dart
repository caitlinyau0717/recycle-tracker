import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'ScanDetailPage.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
class Bottle{
  String? brand_name;
  String? bottle_name;
  double? value;
  String? packaging;
  Bottle.constructor1(brand, name, val, mat){
    brand_name = brand;
    bottle_name = name;
    value = val;
    packaging = mat;
  }
}
class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedPage = 0;
  final PageController _pageController = PageController(viewportFraction: 0.45);
  final ImagePicker _picker = ImagePicker();

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
  Future<Bottle> BarcodeData(String bottle_id) async{
    OpenFoodAPIConfiguration.userAgent = UserAgent(name: 'Your app name', url: 'Your url, if applicable');
    ProductQueryConfiguration config = ProductQueryConfiguration(
    bottle_id,
    version: ProductQueryVersion.v3,
  );
  ProductResultV3 product = await OpenFoodAPIClient.getProductV3(config);
  //print('Hello world: ${food_facts_project.calculate()}!');
  String? packaging = product.product?.packaging;
  String? bottle_name = product.product?.productName;
  double value = 0.05;
  String? brand_name = product.product?.brands;
  Bottle this_bottle = Bottle.constructor1(brand_name, bottle_name, value, packaging);
  return (this_bottle); // Coca Cola Zero
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

                // Scan mode switcher
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

                // Bottom row with $ saved, shutter, check
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Saved display
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

                      // 📂 Gallery picker & barcode scanner
                      GestureDetector(
                        onTap: () async {
                          final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            File imageFile = File(image.path);
                            final inputImage = InputImage.fromFile(imageFile);
                            final barcodeScanner = BarcodeScanner();

                            final List<Barcode> barcodes = await barcodeScanner.processImage(inputImage);
                            await barcodeScanner.close();
                            String? barcodeValue;
                            if (barcodes.isNotEmpty) {
                              barcodeValue = barcodes.first.rawValue;
                              print("📦 Barcode Scanned: $barcodeValue");
                            }
                            Bottle this_bottle = await BarcodeData(barcodeValue!);
                            String brandName = this_bottle.brand_name!;
                            String value = this_bottle.value!.toString(); 
                            String bottle_name = this_bottle.bottle_name!;
                            String packaging = this_bottle.packaging!;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ScanDetailPage(
                                  imageFile: imageFile,
                                  barcodeValue: barcodeValue,
                                  brandName: brandName,
                                  bottleName: bottle_name,
                                  packaging: packaging,
                                  cost: value,
                                ),
                              ),
                            );
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
                          child: const Icon(Icons.image, size: 30),
                        ),
                      ),

                      // ✅ Manual check
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
              backgroundImage: AssetImage('assets/profile.jpg'),
            ),
            Image.asset('assets/logo.png', height: 40),
            IconButton(
              icon: const Icon(Icons.camera_alt_rounded, size: 40),
              onPressed: () {
                // Already here
              },
            ),
          ],
        ),
      ),
    );
  }
}
