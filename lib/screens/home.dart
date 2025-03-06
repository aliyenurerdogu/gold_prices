import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoldPriceScreen extends StatefulWidget {
  final Function toggleFavorite;
  final List<dynamic> favoriteGolds;
  GoldPriceScreen(this.toggleFavorite, this.favoriteGolds);
  @override
  _GoldPriceScreenState createState() => _GoldPriceScreenState();
}

class _GoldPriceScreenState extends State<GoldPriceScreen> {
  List<dynamic> goldPrices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGoldPrices();
  }

  Future<void> fetchGoldPrices() async {
    final url = Uri.parse("https://api.smokinyazilim.com/harem_altin/prices");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse =
            jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          goldPrices = jsonResponse["data"];
          isLoading = false;
        });
      } else {
        throw Exception("API hatası: $response.statusCode");
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print("Hata: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Altın Fiyatları"),
        titleTextStyle: TextStyle(
            color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: goldPrices.length,
              itemBuilder: (context, index) {
                final item = goldPrices[index];
                final isFavorite = widget.favoriteGolds.contains(item);
                return Card(
                  color: const Color.fromARGB(255, 229, 205, 134),
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(item["key"] ?? "Bilinmeyen"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Alış: ${item["buy"] ?? "Yok"} TL"),
                        Text("Satış: ${item["sell"] ?? "Yok"} TL"),
                        Text("Değişim: %${item["percent"] ?? "Yok"}"),
                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () => widget.toggleFavorite(item),
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
