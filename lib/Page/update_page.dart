import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Model/wisata_model.dart';

class PageUpdate extends StatefulWidget {
  final Datum wisata;
  final Function refreshData;

  const PageUpdate({super.key, required this.wisata, required this.refreshData});

  @override
  State<PageUpdate> createState() => _PageUpdateState();
}

class _PageUpdateState extends State<PageUpdate> {
  late TextEditingController txtNama;
  late TextEditingController txtLokasi;
  late TextEditingController txtDeskripsi;
  late TextEditingController txtLat;
  late TextEditingController txtLng;
  late TextEditingController txtProfil;
  late TextEditingController txtGambar;

  GlobalKey<FormState> keyForm = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    txtNama = TextEditingController(text: widget.wisata.nama);
    txtLokasi = TextEditingController(text: widget.wisata.lokasi);
    txtDeskripsi = TextEditingController(text: widget.wisata.deskripsi);
    txtLat = TextEditingController(text: widget.wisata.lat);
    txtLng = TextEditingController(text: widget.wisata.lng);
    txtProfil = TextEditingController(text: widget.wisata.profil);
    txtGambar = TextEditingController(text: widget.wisata.gambar ?? '');
  }

  Future<void> updateWisata() async {
    try {
      setState(() {
        isLoading = true;
      });

      http.Response response = await http.post(
        Uri.parse('http://192.168.1.22/wisata/updateWisata.php'),
        body: {
          'id': widget.wisata.id,
          'nama': txtNama.text,
          'lokasi': txtLokasi.text,
          'deskripsi': txtDeskripsi.text,
          'lat': txtLat.text,
          'lng': txtLng.text,
          'profil': txtProfil.text,
          'gambar': txtGambar.text,
        },
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['value'] == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'])),
          );
          widget.refreshData();
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'])),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Wisata'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Form(
        key: keyForm,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                buildTextField('Nama', txtNama),
                buildTextField('Lokasi', txtLokasi),
                buildTextField('Deskripsi', txtDeskripsi),
                buildTextField('Lat', txtLat),
                buildTextField('Lng', txtLng),
                buildTextField('Profil', txtProfil),
                buildTextField('Gambar', txtGambar),
                SizedBox(height: 20),
                Center(
                  child: isLoading
                      ? CircularProgressIndicator()
                      : MaterialButton(
                    minWidth: 150,
                    height: 45,
                    onPressed: () {
                      if (keyForm.currentState?.validate() == true) {
                        updateWisata();
                      }
                    },
                    child: Text('Update'),
                    color: Colors.green,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(width: 1, color: Colors.blueGrey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        validator: (val) => val!.isEmpty ? "Tidak boleh kosong" : null,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}