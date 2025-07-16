
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


class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final MobileScannerController _cameraController = MobileScannerController();
  bool _isScanning = false;

  void _startScan() {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
    });

    //Timeout if nothing is scanned
    Future.delayed(const Duration(seconds: 5), () {
      if (_isScanning) {
        setState(() {
          _isScanning = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No barcode found. Please try again.')),
        );
      }
    });
  }

  void _handleDetection(List<Barcode> barcodes) {
    if (!_isScanning || barcodes.isEmpty) return;

    final scanned = barcodes.first.rawValue ?? 'Unknown';

    setState(() {
      _isScanning = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Scanned item: $scanned')),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Please scan a bottle/can'),
        backgroundColor: const Color.fromARGB(255, 133, 239, 137),
      ),
      body: Stack(
        children: [
          //Always show the camera
          MobileScanner(
            controller: _cameraController,
            onDetect: (capture) {
              _handleDetection(capture.barcodes);
            },
          ),

          //Scan Button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: ElevatedButton.icon(
                onPressed: _startScan,
                icon: const Icon(Icons.camera),
                label: Text(_isScanning ? 'Scanning...' : 'Scan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 13, 255, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}