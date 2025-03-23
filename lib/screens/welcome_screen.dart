import 'package:flutter/material.dart';
import '../db_helper.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _nameController = TextEditingController();

  void _saveName() async {
    String name = _nameController.text.trim();
    if (name.isNotEmpty) {
      await StorageHelper.saveUserName(name);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome!")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("What's your name?", style: TextStyle(fontSize: 20)),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Enter your name"),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _saveName, child: Text("Continue")),
          ],
        ),
      ),
    );
  }
}
