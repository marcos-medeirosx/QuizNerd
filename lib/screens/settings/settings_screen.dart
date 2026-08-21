import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Configurações'),
      ),
      body: const Center(
        child: Text(
          'Configurações em breve...',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}