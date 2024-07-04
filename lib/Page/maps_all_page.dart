import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../Model/wisata_model.dart';


class MapsAllPage extends StatefulWidget {
  @override
  _MapsAllPageState createState() => _MapsAllPageState();
}

class _MapsAllPageState extends State<MapsAllPage> {
  late GoogleMapController mapController;
  Future<ModelWisata>? _kampusFuture;

  @override
  void initState() {
    super.initState();
    _kampusFuture = fetchKampus();
  }

  Future<ModelWisata> fetchKampus() async {
    final response = await http.get(Uri.parse('http://192.168.1.22/wisata/getWisata.php'));

    if (response.statusCode == 200) {
      return modelWisataFromJson(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Maps'),
      ),
      body: FutureBuilder<ModelWisata>(
        future: _kampusFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
            return Center(child: Text('No data found'));
          } else {
            Set<Marker> markers = snapshot.data!.data.map((kampus) {
              double? lat;
              double? lng;
              try {
                lat = double.parse(kampus.lat);
                lng = double.parse(kampus.lng);
              } catch (e) {
                print('Error parsing lat/lng for kampus: ${kampus.nama}, lat: ${kampus.lat}, lng: ${kampus.lng}');
                return null; // Return null for invalid data points
              }

              return Marker(
                markerId: MarkerId(kampus.nama),
                position: LatLng(lat!, lng!),
                infoWindow: InfoWindow(
                  title: kampus.nama,
                ),
              );
            }).where((marker) => marker != null).cast<Marker>().toSet();

            return GoogleMap(
              onMapCreated: (controller) {
                mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(-0.9145, 100.4607), // Koordinat pusat peta
                zoom: 10,
              ),
              markers: markers,
            );
          }
        },
      ),
    );
  }
}