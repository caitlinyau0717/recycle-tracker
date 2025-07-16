
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gal/gal.dart';
import 'package:mobile_scanner/mobile_scanner.dart';


/*
class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _controller = CameraController(
          _cameras.first,
          ResolutionPreset.high,
        );
        await _controller!.initialize();
        if (mounted) setState(() {});
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _takePicture() async {
    if (_controller != null && _controller!.value.isInitialized) {
      final picture = await _controller!.takePicture();
      await Gal.putImage(picture.path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved to gallery')),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Please scan a bottle/can'),
        backgroundColor: Colors.red, // Test color
      ),
      body: _controller == null || !_controller!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: CameraPreview(_controller!),
                ),
                IconButton(
                  icon: const Icon(Icons.camera, size: 40),
                  onPressed: _takePicture,
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}

*/


class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // ← Critical for Android
      appBar: AppBar(
        title: const Text('Please scan a bottle or can'),
        backgroundColor: Colors.red.withOpacity(0.7),
        elevation: 0,
        toolbarHeight: 80, // ← Makes the bar more visible
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: MobileScannerController(),
            fit: BoxFit.cover, // ← Ensures full coverage
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                debugPrint('Scanned: ${barcode.rawValue}');
                // Add your scan handling logic here
              }
            },
          ),
        ],
      ),
    );
  }
}