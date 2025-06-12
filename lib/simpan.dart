import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class storageAccess extends StatefulWidget {
  @override
  State<storageAccess> createState() => _MyAppState();
}

class _MyAppState extends State<storageAccess> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadImageFromPrefs();
  }

  Future<void> _loadImageFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('saved_image_path');
    if (imagePath != null) {
      setState(() {
        _imageFile = File(imagePath);
      });
    }
  }

  Future<void> _pickAndSaveImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = pickedFile.name;
      final savedImage = await File(pickedFile.path).copy('\${appDir.path}/\$fileName');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_image_path', savedImage.path);

      setState(() {
        _imageFile = savedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Simpan Image di Local Storage')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _imageFile == null
                  ? Text('Belum ada gambar disimpan')
                  : Image.file(_imageFile!, width: 200, height: 200),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickAndSaveImage,
                child: Text('Pilih dan Simpan Gambar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}