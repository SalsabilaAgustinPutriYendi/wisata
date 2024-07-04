import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Model/wisata_model.dart';
import 'delete_page.dart';
import 'delete_page.dart';


class PageUtama extends StatefulWidget {
  @override
  _PageUtamaState createState() => _PageUtamaState();
}

class _PageUtamaState extends State<PageUtama> {
  List<Datum>? wisataList;

  @override
  void initState() {
    super.initState();
    fetchWisata();
  }

  Future<void> fetchWisata() async {
    try {
      var response = await http.get(Uri.parse('http://192.168.1.22/wisata/getWisata.php'));
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['isSuccess']) {
          List<Datum> wisata = List<Datum>.from(jsonData['data'].map((item) => Datum.fromJson(item)));
          setState(() {
            wisataList = wisata;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load wisata: ${jsonData['message']}')));
        }
      } else {
        throw Exception('Failed to load wisata');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Wisata'),
      ),
      body: wisataList == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: wisataList!.length,
        itemBuilder: (context, index) {
          var wisata = wisataList![index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              leading: Image.network(
                'http://192.168.1.22/wisata/gambar/${wisata.gambar}',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.error);
                },
              ),
              title: Text(wisata.nama),
              subtitle: Text(wisata.lokasi),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DetailPage(wisata: wisata)),
                ).then((_) => fetchWisata()); // Refresh list after returning from detail
              },
            ),
          );
        },
      ),
    );
  }
}
