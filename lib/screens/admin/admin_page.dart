import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración'),
      ),
      body: const Center(
        child: Text(
          'Módulo de Administración',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}