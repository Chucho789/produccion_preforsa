import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() =>
      _HistorialPageState();
}

class _HistorialPageState
    extends State<HistorialPage> {

  final supabase = Supabase.instance.client;

  bool cargando = true;

  List registros = [];

  @override
  void initState() {
    super.initState();
    cargarRegistros();
  }

  Future<void> cargarRegistros() async {

    final data = await supabase
        .from('registros')
        .select()
        .order(
          'fecha_hora',
          ascending: false,
        )
        .limit(100);

    setState(() {
      registros = data;
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Historial',
        ),
      ),

      body: cargando
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: registros.length,

              itemBuilder:
                  (context, index) {

                final registro =
                    registros[index];

                return Card(
                  margin:
                      const EdgeInsets.all(
                    8,
                  ),

                  child: ListTile(
                    leading: const Icon(
                      Icons.fact_check,
                    ),

                    title: Text(
                      registro['creado_por'] ??
                          '',
                    ),

                    subtitle: Text(
                      'Turno ${registro['turno']}'
                      '\n${registro['fecha_hora']}',
                    ),

                    trailing: Text(
                      'Maq ${registro['maquina_id']}',
                    ),
                  ),
                );
              },
            ),
    );
  }
}