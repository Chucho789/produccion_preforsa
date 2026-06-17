import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'detalle_registro_page.dart';

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
    .select('''
      *,
      maquinas(nombre)
    ''')
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

                    onTap: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetalleRegistroPage(
                            registroId: registro['id'],
                          ),
                        ),
                      );
                    },

                    leading: const Icon(
                      Icons.fact_check,
                    ),

                    title: Text(
                      registro['maquinas']['nombre'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(
                        'Registrado por: ${registro['creado_por']}'
                        '\nTurno: ${registro['turno']}'
                        '\nFecha: ${registro['fecha']}',
                      ),

                    trailing: const Icon(
                      Icons.chevron_right,
                    ),
                  ),
                );
              },
            ),
    );
  }
}