import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Model/wisata_model.dart';
import 'maps_page.dart';

class PageDetail extends StatelessWidget {
  final Datum wisata;

  const PageDetail({super.key, required this.wisata});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Wisata'),
        backgroundColor: Colors.lightBlue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            wisata.gambar.isNotEmpty
                ? Image.network(
              'http://192.168.1.22/wisata/gambar/${wisata.gambar}',
              width: double.infinity,
              fit: BoxFit.cover,
            )
                : Icon(Icons.image_not_supported, size: 200),
            SizedBox(height: 20),
            Divider(color: Colors.grey),
            SizedBox(height: 20),
            Text(
              wisata.nama,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    wisata.lokasi,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            const Row(
              children: [
                Icon(FontAwesomeIcons.infoCircle, color: Colors.blue),
                SizedBox(width: 5),
                Text(
                  'Deskripsi:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 5),
            Text(
              wisata.deskripsi,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            const Row(
              children: [
                Icon(FontAwesomeIcons.user, color: Colors.blue),
                SizedBox(width: 5),
                Text(
                  'profil:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 5),
            Text(
              wisata.profil,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(FontAwesomeIcons.mapMarkerAlt, color: Colors.green),
                SizedBox(width: 5),
                Text(
                  'Koordinat:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 5),
            Text(
              'Lat: ${wisata.lat}, Lng: ${wisata.lng}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(FontAwesomeIcons.map),
                label: Text('Lihat di Peta'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapsPage(
                        lat: double.parse(wisata.lat),
                        lng: double.parse(wisata.lng),
                        nama: wisata.nama,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}