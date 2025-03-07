import 'package:flutter/material.dart';

class FavoriteScreen extends StatefulWidget {
  final List<Map<String, dynamic>> favoriteGolds;
  final Function toggleFavoriteGold;

  FavoriteScreen(this.favoriteGolds, this.toggleFavoriteGold);

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favorilerim"),
        titleTextStyle: TextStyle(
            color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold),
        backgroundColor: Colors.black,
      ),
      body: widget.favoriteGolds.isEmpty
          ? Center(child: Text("Favori altın bulunmuyor."))
          : ListView.builder(
              itemCount: widget.favoriteGolds.length,
              itemBuilder: (context, index) {
                final item = widget.favoriteGolds[index];
                bool isFavorite = item["isFavorite"];

                return Card(
                  color: const Color.fromARGB(255, 229, 205, 134),
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(item["key"] ?? "Bilinmeyen"),
                    subtitle: Text("Fiyat: ${item["sell"] ?? "Yok"} TL"),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          widget.toggleFavoriteGold(item);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
