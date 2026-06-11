import 'package:flutter/material.dart';

class IpsVariablesPage extends StatelessWidget {
  final int maquinaId;
  final String maquinaNombre;
  final String seccion;

  const IpsVariablesPage({
    super.key,
    required this.maquinaId,
    required this.maquinaNombre,
    required this.seccion,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(seccion),
      ),
      body: Center(
        child: Text(
          'Máquina: $maquinaNombre\n\nSección: $seccion',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}