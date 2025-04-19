import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const LatLng _center = LatLng(37.7749, -122.4194); // San Francisco
  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId('1'),
      position: LatLng(37.7749, -122.4194),
      infoWindow: InfoWindow(
        title: 'Happy Paws Veterinary',
        snippet: 'Open until 6 PM',
      ),
    ),
    const Marker(
      markerId: MarkerId('2'),
      position: LatLng(37.7833, -122.4167),
      infoWindow: InfoWindow(
        title: 'Pet Care Clinic',
        snippet: 'Open until 7 PM',
      ),
    ),
    const Marker(
      markerId: MarkerId('3'),
      position: LatLng(37.7750, -122.4183),
      infoWindow: InfoWindow(
        title: 'Animal Wellness Center',
        snippet: 'Open until 5 PM',
      ),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Services'),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: _center,
          zoom: 13,
        ),
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        mapType: MapType.normal,
      ),
    );
  }
} 