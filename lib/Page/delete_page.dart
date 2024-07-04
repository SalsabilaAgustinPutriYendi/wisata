import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../Model/wisata_model.dart';


class DetailPage extends StatefulWidget {
  final Datum wisata;

  const DetailPage({Key? key, required this.wisata}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late TextEditingController namaController;
  late TextEditingController lokasiController;
  late TextEditingController deskripsiController;
  late TextEditingController latController;
  late TextEditingController lngController;
  late GoogleMapController mapController;
  File? _image;

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.wisata.nama);
    lokasiController = TextEditingController(text: widget.wisata.lokasi);
    deskripsiController = TextEditingController(text: widget.wisata.deskripsi);
    latController = TextEditingController(text: widget.wisata.lat);
    lngController = TextEditingController(text: widget.wisata.lng);
  }

  Future<void> updateWisata() async {
    var request = http.MultipartRequest('POST', Uri.parse('http://192.168.1.22/wisata/updateWisata.php'));
    request.fields['id'] = widget.wisata.id;
    request.fields['nama'] = namaController.text;
    request.fields['lokasi'] = lokasiController.text;
    request.fields['deskripsi'] = deskripsiController.text;
    request.fields['lat'] = latController.text;
    request.fields['lng'] = lngController.text;

    if (_image != null) {
      request.files.add(await http.MultipartFile.fromPath('gambar', _image!.path));
    }

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    var jsonData = json.decode(responseData);

    if (response.statusCode == 200 && jsonData['isSuccess']) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Wisata updated successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update wisata: ${jsonData['message']}')));
    }
  }

  Future<void> deleteWisata() async {
    var response = await http.post(
      Uri.parse('http://192.168.1.22/wisata/deleteWisata.php'),
      body: {'id': widget.wisata.id},
    );
    var jsonData = json.decode(response.body);

    if (response.statusCode == 200 && jsonData['isSuccess']) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Wisata deleted successfully')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete wisata: ${jsonData['message']}')));
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wisata.nama),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Image.network(
                    'http://192.168.1.22/wisata/gambar/${widget.wisata.gambar}',
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(child: Text('Failed to load image'));
                    },
                  ),
                  if (_image != null)
                    Image.file(
                      _image!,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('Change Image'),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: namaController,
                decoration: InputDecoration(labelText: 'Nama'),
              ),
              TextField(
                controller: lokasiController,
                decoration: InputDecoration(labelText: 'Lokasi'),
              ),
              TextField(
                controller: deskripsiController,
                decoration: InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
              ),
              TextField(
                controller: latController,
                decoration: InputDecoration(labelText: 'Latitude'),
              ),
              TextField(
                controller: lngController,
                decoration: InputDecoration(labelText: 'Longitude'),
              ),
              SizedBox(height: 10),
              Container(
                height: 300,
                width: double.infinity,
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(double.parse(widget.wisata.lat), double.parse(widget.wisata.lng)),
                    zoom: 14,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId(widget.wisata.id),
                      position: LatLng(double.parse(widget.wisata.lat), double.parse(widget.wisata.lng)),
                    ),
                  },
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: updateWisata,
                    child: Text('Update'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Confirm Delete'),
                          content: Text('Are you sure you want to delete this item?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                deleteWisata();
                                Navigator.pop(context);
                              },
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
