import 'package:flutter/material.dart';
import 'package:shopping_app/beranda.dart';
import 'mapzzzz.dart';
import 'camera.dart';
import 'voice.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OSM in Flutter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
      // home: BerandaPage(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shopping App')),
      body: Column(
        children: [
          // Bagian peta (2/3 layar)
          Expanded(
            flex: 2,
            child: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: OSMMap(),
              ),
            ),
          ),

          // Bagian tombol (1/3 layar)
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CameraScreen(),
                            ),
                          );
                        },
                        icon: Icon(Icons.camera_alt),
                        label: Text('Kamera'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Aksi untuk peta jika diperlukan
                        },
                        icon: Icon(Icons.map),
                        label: Text('Peta'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VoiceRecorderApp(),
                            ),
                          );
                        },
                        icon: Icon(Icons.mic),
                        label: Text('Suara'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
