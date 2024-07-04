import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsPage extends StatefulWidget {
  final double lat;
  final double lng;
  final String nama;

  MapsPage({
    required this.lat,
    required this.lng,
    required this.nama,
  });

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  late GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nama),
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.lat, widget.lng),
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: MarkerId(widget.nama),
            position: LatLng(widget.lat, widget.lng),
            infoWindow: InfoWindow(
              title: widget.nama,
            ),
          ),
        },
      ),
    );
  }
}