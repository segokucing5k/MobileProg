import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class OSMMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(-7.28062680476065, 112.79539233832905),
        zoom: 20.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(-7.28062680476065, 112.79539233832905),
              builder: (ctx) => Icon(
                Icons.location_on,
                color: Colors.red,
                size: 40,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  // Function to open map in external app
  Future<void> openInExternalMap() async {
    final Uri url = Uri.parse('https://maps.app.goo.gl/gxr8U3377A7kFtQF9');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}