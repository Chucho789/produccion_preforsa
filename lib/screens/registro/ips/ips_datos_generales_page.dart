import 'package:flutter/material.dart';

class IpsDatosGeneralesPage extends StatefulWidget {
  final int maquinaId;
  final String maquinaNombre;

  const IpsDatosGeneralesPage({
    super.key,
    required this.maquinaId,
    required this.maquinaNombre,
  });

  @override
  State<IpsDatosGeneralesPage> createState() =>
      _IpsDatosGeneralesPageState();
}

class _IpsDatosGeneralesPageState
    extends State<IpsDatosGeneralesPage> {
  final aceiteController = TextEditingController();
  final aguaEntradaController = TextEditingController();
  final aguaManoController = TextEditingController();
  final aguaMoldeController = TextEditingController();
  final dewPointController = TextEditingController();
  final secadorController = TextEditingController();
  final materialController = TextEditingController();

  @override
  void dispose() {
    aceiteController.dispose();
    aguaEntradaController.dispose();
    aguaManoController.dispose();
    aguaMoldeController.dispose();
    dewPointController.dispose();
    secadorController.dispose();
    materialController.dispose();
    super.dispose();
  }

  Widget campo(
    String titulo,
    String unidad,
    TextEditingController controller,
  ) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                suffixText: unidad,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos Generales'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 2, // 👈 2 COLUMNAS
              childAspectRatio: 1.2,
              padding: const EdgeInsets.all(16),
              children: [
                campo('Temperatura Aceite', '°C', aceiteController),
                campo('Temperatura Agua Entrada Máquina', '°C', aguaEntradaController),
                campo('Temperatura Agua Mano Toma', '°C', aguaManoController),
                campo('Temperatura Agua Molde', '°C', aguaMoldeController),
                campo('Dew Point Secador', '°C', dewPointController),
                campo('Temperatura Secador', '°C', secadorController),
                campo('Temperatura Entrada Material', '°C', materialController),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 55,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}