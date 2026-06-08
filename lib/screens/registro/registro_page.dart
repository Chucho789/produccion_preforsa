import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'variables_page.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final supabase = Supabase.instance.client;

  final Map<String, String> imagenesMaquinas = {
  'IPS-1': 'assets/maquinas/IPS400B.jpeg',
  'IPS-2': 'assets/maquinas/IPS400A.jpeg',
  'CCM32': 'assets/maquinas/TAPAS1.jpeg',
  'COLORA CAP': 'assets/maquinas/IM-01.jpg',
  'HXM258': 'assets/maquinas/IY-07.jpg',
  'HXM585': 'assets/maquinas/IY-05.jpg',
  'YIZUMI': 'assets/maquinas/IY-08.jpg',
  'VJ1': 'assets/maquinas/SOPLADO.jpg',
  'VJ2': 'assets/maquinas/SD-02.jpg',
  'VJ3': 'assets/maquinas/SD-03.jpg',
};

  List<dynamic> areas = [];
  List<dynamic> maquinas = [];

  int? areaSeleccionada;
  int? maquinaSeleccionada;

  @override
  void initState() {
    super.initState();
    cargarAreas();
  }

  Future<void> cargarAreas() async {
    try {
      final data = await supabase
          .from('areas')
          .select()
          .order('nombre');

      setState(() {
        areas = data;
      });
    } catch (e) {
      debugPrint('Error cargando áreas: $e');
    }
  }

  Future<void> cargarMaquinas(int areaId) async {
    try {
      final data = await supabase
          .from('maquinas')
          .select()
          .eq('area_id', areaId)
          .order('nombre');

      setState(() {
        maquinas = data;
        maquinaSeleccionada = null;
      });
    } catch (e) {
      debugPrint('Error cargando máquinas: $e');
    }
  }

  String obtenerTurno() {
    final hora = DateTime.now().hour;

    if (hora >= 7 && hora < 15) {
      return 'Turno 1';
    } else if (hora >= 15 && hora < 23) {
      return 'Turno 2';
    } else {
      return 'Turno 3';
    }
  }

  @override
  Widget build(BuildContext context) {
    final turno = obtenerTurno();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Datos'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    Text(
                      turno,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateTime.now().toString().substring(0, 10),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Área',
                border: OutlineInputBorder(),
              ),
              value: areaSeleccionada,
              items: areas.map((area) {
                return DropdownMenuItem<int>(
                  value: area['id'],
                  child: Text(area['nombre']),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  areaSeleccionada = value;
                });

                cargarMaquinas(value);
              },
            ),

            const SizedBox(height: 20),

            if (maquinas.isNotEmpty)
  Expanded(
    child: GridView.builder(
      itemCount: maquinas.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        final maquina = maquinas[index];

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VariablesPage(
                  maquinaId: maquina['id'],
                  maquinaNombre: maquina['nombre'],
                ),
              ),
            );
          },
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(15),
            ),
            child: Column(
              children: [

                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child: Image.asset(
                      imagenesMaquinas[
                              maquina['nombre']] ??
                          'assets/maquinas/IPS400B.jpeg',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsets.all(10),
                  child: Text(
                    maquina['nombre'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  ),

          ],
        ),
      ),
    );
  }
}