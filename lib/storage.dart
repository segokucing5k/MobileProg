import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  /// Mengambil file dari penyimpanan lokal
  Future<List<File>?> pickFiles({
    FileType type = FileType.any,
    bool allowMultiple = false,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type,
        allowMultiple: allowMultiple,
      );

      if (result != null) {
        return result.paths.map((path) => File(path!)).toList();
      } else {
        // Pengguna membatalkan pemilihan
        return null;
      }
    } catch (e) {
      debugPrint('Error memilih file: $e');
      return null;
    }
  }

  /// Mengambil gambar dari penyimpanan lokal
  Future<List<File>?> pickImages({bool allowMultiple = false}) async {
    return pickFiles(
      type: FileType.image,
      allowMultiple: allowMultiple,
    );
  }

  /// Menyimpan file ke penyimpanan lokal
  Future<File?> saveFile(String fileName, List<int> bytes) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      
      return file;
    } catch (e) {
      debugPrint('Error menyimpan file: $e');
      return null;
    }
  }
}

/// Widget untuk menampilkan preview file yang dipilih
class FilePreviewWidget extends StatelessWidget {
  final File file;
  
  const FilePreviewWidget({
    Key? key,
    required this.file,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final extension = file.path.split('.').last.toLowerCase();
    
    // Preview untuk gambar
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Text('Gagal memuat gambar'));
        },
      );
    }
    
    // Preview untuk PDF
    else if (extension == 'pdf') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.picture_as_pdf, size: 48, color: Colors.red),
          Text(file.path.split('/').last),
        ],
      );
    }
    
    // Preview untuk file lainnya
    else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.insert_drive_file, size: 48),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(file.path.split('/').last),
          ),
        ],
      );
    }
  }
}

/// Contoh penggunaan
class StorageAccess extends StatefulWidget {
  const StorageAccess({Key? key}) : super(key: key);

  @override
  State<StorageAccess> createState() => _StorageAccessState();
}

class _StorageAccessState extends State<StorageAccess> {
  final StorageService _storageService = StorageService();
  List<File> _selectedFiles = [];
  
  Future<void> _pickFiles() async {
    final files = await _storageService.pickFiles(allowMultiple: true);
    if (files != null) {
      setState(() {
        _selectedFiles = files;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Akses Penyimpanan Lokal'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _pickFiles,
              child: const Text('Pilih File dari Penyimpanan'),
            ),
          ),
          Expanded(
            child: _selectedFiles.isEmpty
                ? const Center(child: Text('Belum ada file yang dipilih'))
                : ListView.builder(
                    itemCount: _selectedFiles.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: SizedBox(
                          height: 200,
                          child: FilePreviewWidget(file: _selectedFiles[index]),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}