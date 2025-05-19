import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' as path; // Import with namespace
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  // Tambahkan deklarasi variabel yang diperlukan di sini
  CameraController? _controller;
  List<CameraDescription> cameras = [];
  File? _imageFile;
  bool _isScanning = false;
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }
  
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
  
  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      _controller = CameraController(
        cameras[0],
        ResolutionPreset.medium,
      );
      await _controller!.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }
  
  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      final XFile image = await _controller!.takePicture();
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(image.path); // Use path prefix here
      final File savedImage = File('${appDir.path}/$fileName');
      
      if (mounted) {
        final imageBytes = await image.readAsBytes();
        await savedImage.writeAsBytes(imageBytes);
        
        setState(() {
          _imageFile = savedImage;
        });
      }
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
    });

    // Simulasikan proses pemindaian selama 2 detik
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isScanning = false;
      });
      
      // Tampilkan dialog hasil pemindaian
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Hasil Scan'),
          content: Text('Pemindaian gambar berhasil dilakukan'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCameraPreview() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }
    
    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: CameraPreview(_controller!),
    );
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.file(
                _imageFile!,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
              if (_isScanning)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0.5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 20),
                      Text(
                        'Memproses gambar...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => setState(() => _imageFile = null),
                child: Text('Ambil Ulang'),
              ),
              ElevatedButton(
                onPressed: _isScanning ? null : _startScanning,
                child: Text('Scan Gambar'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera'),
      ),
      body: _imageFile == null
          ? Column(
              children: [
                Expanded(child: _buildCameraPreview()),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FloatingActionButton(
                    onPressed: _takePicture,
                    child: Icon(Icons.camera_alt),
                  ),
                ),
              ],
            )
          : _buildImagePreview(),
    );
  }
}