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

class _GoldPriceScreenState extends State<GoldPriceScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> goldPrices = [];
  bool isLoading = true;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    fetchGoldPrices();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _controller.repeat(reverse: true);
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
        throw Exception("API hatası: ${response.statusCode}");
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print("Hata: $error");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                final percent =
                    double.tryParse(item["percent"].toString()) ?? 0;
                final isRising = percent > 0;
                final isFalling = percent < 0;
                final isFavorite = widget.favoriteGolds
                    .any((fav) => fav["key"] == item["key"]);

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
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            Color textColor = Colors.black;

                            // Günlük değişim rengi
                            if (isRising) {
                              textColor = Colors.green;
                            } else if (isFalling) {
                              textColor = Colors.red;
                            }

                            // Anlık değişim animasyonu
                            if (_controller.value < 0.5) {
                              textColor = isRising
                                  ? Colors.green
                                  : isFalling
                                      ? Colors.red
                                      : textColor;
                            }

                            return Text(
                              "%${item["percent"] ?? "Yok"}",
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        widget.toggleFavorite(item);
                        setState(() {});
                      },
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
