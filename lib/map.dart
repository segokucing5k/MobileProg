import 'package:flutter/material.dart';

class SimpleMapView extends StatelessWidget {
  const SimpleMapView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      margin: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5.0,
            spreadRadius: 1.0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Stack(
          children: [
            // Map placeholder
            Center(
              child: Image.asset(
                'assets/map_placeholder.png',
                fit: BoxFit.cover,
                width: double.infinity,
                // Replace with your actual map image or use a placeholder
                errorBuilder: (context, error, stackTrace) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map, size: 50, color: Colors.grey),
                      SizedBox(height: 10),
                      Text('Store Location Map', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('123 Shopping Street, City', style: TextStyle(color: Colors.grey[600])),
                    ],
                  );
                },
              ),
            ),
            // Store location marker
            Center(
              child: Icon(
                Icons.location_on,
                color: Colors.red[700],
                size: 36,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
