import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/favorite.dart';
import 'screens/cart.dart';
import 'screens/profile.dart';
import 'services/local_storage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  List<Map<String, Object>> favoriteGolds = [];

  void initState() {
    super.initState();
    loadFavorites();
  }

  void toggleFavoriteGold(dynamic item) {
    setState(() {
      if (favoriteGolds.any((gold) => gold["key"] == item["key"])) {
        favoriteGolds.removeWhere((gold) => gold["key"] == item["key"]);
      } else {
        favoriteGolds.add({...item, "isFavorite": true});
      }
    });
    saveFavoriteGolds();
  }

  void loadFavorites() async {
    List<String> favoriteKeys = await getData("favorites");
    setState(() {
      favoriteGolds =
          favoriteKeys.map((key) => {"key": key, "isFavorite": true}).toList();
    });
  }

  void saveFavoriteGolds() async {
    List<String> favoriteKeys =
        favoriteGolds.map((item) => item["key"].toString()).toList();
    await saveData("favorites", favoriteKeys);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            GoldPriceScreen(toggleFavoriteGold, favoriteGolds),
            FavoriteScreen(favoriteGolds),
            CartScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: Colors.black,
          selectedItemColor: Colors.amber,
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Anasayfa'),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite), label: 'Favorilerim'),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), label: 'Sepetim'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hesabım'),
          ],
        ),
      ),
    );
  }
}
