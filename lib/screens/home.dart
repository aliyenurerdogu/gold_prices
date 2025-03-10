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
  List<dynamic> filteredGoldPrices = [];
  bool isLoading = true;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  late AnimationController _controller;
  Map<String, dynamic>? selectedGold;

  @override
  void initState() {
    super.initState();
    fetchGoldPrices();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
      lowerBound: 0.5,
      upperBound: 1.0,
    );
  }

  Future<void> fetchGoldPrices() async {
    final url = Uri.parse("https://api.smokinyazilim.com/harem_altin/prices");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse =
            jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          goldPrices =
              List<Map<String, dynamic>>.from(jsonResponse["data"] ?? []);
          filteredGoldPrices = List.from(goldPrices);
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

  void searchGold(String query) {
    if (query.isEmpty) {
      setState(() {
        isSearching = false;
        filteredGoldPrices = List.from(goldPrices);
      });
      return;
    }
    setState(() {
      isSearching = true;
      filteredGoldPrices = goldPrices
          .where(
              (gold) => gold["key"].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(hintText: "Altın ara..."),
                onChanged: searchGold,
              )
            : Text("Altın Fiyatları"),
        titleTextStyle: TextStyle(
            color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  if (isSearching) {
                    searchController.clear();
                    searchGold("");
                  } else {
                    isSearching = true;
                  }
                });
              },
              icon: Icon(
                isSearching ? Icons.close : Icons.search,
                color: Colors.amber,
              ))
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (selectedGold != null)
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Card(
                      color: Colors.amber.shade200,
                      child: ListTile(
                        title: Text(selectedGold!["key"] ?? "Bilinmeyen"),
                        subtitle: Text(
                            "Alış: ${selectedGold!["buy"] ?? "Bilinmeyen"} TL"),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
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
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          title: Text(item["key"] ?? "Bilinmeyen"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text("Alış: ${item["buy"] ?? "Yok"} TL"),
                                  SizedBox(width: 10),
                                  Text("Satış: ${item["sell"] ?? "Yok"} TL"),
                                ],
                              ),
                              Text(
                                "%${item["percent"] ?? "Yok"}",
                                style: TextStyle(
                                  color: isRising
                                      ? Colors.green
                                      : isFalling
                                          ? Colors.red
                                          : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              widget.toggleFavorite(item);
                              setState(() {});
                            },
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
