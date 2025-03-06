import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hesabım"),
        titleTextStyle: TextStyle(
            color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold),
        backgroundColor: Colors.black,
      ),
      body: Center(child: Text("hesap ayarları")),
    );
  }
}
