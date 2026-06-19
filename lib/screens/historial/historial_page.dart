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
    .eq('eliminado', false)
    .limit(100)
    .order(
      'fecha_hora',
      ascending: false,
    );
    

    setState(() {
      registros = data;
      cargando = false;
    });
  }

  Future<void> confirmarEliminar(
  int registroId,
) async {

  final confirmar =
      await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          'Eliminar registro',
        ),

        content: const Text(
          '¿Está seguro de eliminar este registro?\n\nEsta acción no se puede deshacer.',
        ),

        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                false,
              );
            },
            child: const Text(
              'Cancelar',
            ),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.red,
            ),

            onPressed: () {
              Navigator.pop(
                context,
                true,
              );
            },

            child: const Text(
              'Eliminar',
            ),
          ),
        ],
      );
    },
  );

  if (confirmar == true) {
    eliminarRegistro(
      registroId,
    );
  }
}

Future<void> eliminarRegistro(
  int registroId,
) async {

  try {

    await supabase
        .from('registro_detalle')
        .delete()
        .eq(
          'registro_id',
          registroId,
        );

    await supabase
        .from('registros')
        .delete()
        .eq(
          'id',
          registroId,
        );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Registro eliminado',
        ),
      ),
    );

    cargarRegistros();

  } catch (e) {

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          'Error: $e',
        ),
      ),
    );
  }
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

                    trailing: IconButton(icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: (){
                      confirmarEliminar(
                        registro['id'],
                      );
                    }
                    ),
                  ),
                );
              },
            ),
    );
  }
}
