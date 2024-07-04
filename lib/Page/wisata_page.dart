import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wisata/Page/update_page.dart';
import 'dart:convert';
import '../Model/wisata_model.dart';
import 'detail_wisata_page.dart';
import 'insert_page.dart';


class PageWisata extends StatefulWidget {
  const PageWisata({super.key});

  @override
  State<PageWisata> createState() => _PageWisataState();
}

class _PageWisataState extends State<PageWisata> {
  bool isLoading = true;
  List<Datum> wisataList = [];

  @override
  void initState() {
    super.initState();
    fetchWisata();
  }

  Future<void> fetchWisata() async {
    final response = await http.get(Uri.parse('http://192.168.1.22/wisata/getWisata.php'));

    if (response.statusCode == 200) {
      final data = modelWisataFromJson(response.body);
      setState(() {
        wisataList = data.data;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data')),
      );
    }
  }

  void refreshData() {
    setState(() {
      isLoading = true;
    });
    fetchWisata();
  }

  Future<void> deleteWisata(String id) async {
    final response = await http.post(
      Uri.parse('http://192.168.1.22/wisata/deleteWisata.php'),
      body: {'id': id},
    );

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      if (jsonData['value'] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonData['message'])),
        );
        refreshData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonData['message'])),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Wisata'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: wisataList.length,
        itemBuilder: (context, index) {
          final wisata = wisataList[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              leading: wisata.gambar.isNotEmpty
                  ? Image.network(
                'http://192.168.1.22/wisata/gambar/${wisata.gambar}',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
                  : Icon(Icons.image_not_supported, size: 50),
              title: Text(wisata.nama),
              subtitle: Text(wisata.lokasi),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PageUpdate(
                            wisata: wisata,
                            refreshData: refreshData,
                          ),
                        ),
                      ).then((value) => fetchWisata());
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      deleteWisata(wisata.id);
                    },
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PageDetail(wisata: wisata),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PageInsert(refreshData: refreshData),
            ),
          );
          refreshData();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}