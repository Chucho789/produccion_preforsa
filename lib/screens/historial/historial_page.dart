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
List registrosFiltrados = [];

List maquinas = [];

int? maquinaSeleccionada;

DateTime? fechaSeleccionada;

  

@override
void initState() {
  super.initState();
  iniciar();
}

Future<void> iniciar() async {

  await cargarMaquinas();

  await cargarRegistros();

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

  registrosFiltrados = List.from(data);

  cargando = false;

});
  }

Future<void> cargarMaquinas() async {

  final data = await supabase
      .from("maquinas")
      .select("id,nombre")
      .order("nombre");

  debugPrint("Máquinas:");
  debugPrint(data.toString());

  setState(() {
    maquinas = data;
  });

}

Future<void> seleccionarFecha() async {

  final fecha = await showDatePicker(
    context: context,
    initialDate: fechaSeleccionada ?? DateTime.now(),
    firstDate: DateTime(2024),
    lastDate: DateTime(2035),
  );

  if (fecha == null) return;

  setState(() {

    fechaSeleccionada = fecha;

  });

  aplicarFiltros();

}

void aplicarFiltros() {

  registrosFiltrados = registros.where((registro) {

    bool cumpleFecha = true;
    bool cumpleMaquina = true;

    if (fechaSeleccionada != null) {

      final fechaRegistro =
          registro["fecha"].toString();

      final fechaFiltro =
          fechaSeleccionada!
              .toIso8601String()
              .substring(0, 10);

      cumpleFecha =
          fechaRegistro == fechaFiltro;
    }

    if (maquinaSeleccionada != null) {

      cumpleMaquina =
          registro["maquina_id"] ==
          maquinaSeleccionada;

    }

    return cumpleFecha &&
        cumpleMaquina;

  }).toList();

  setState(() {});

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
        child: CircularProgressIndicator(),
      )
    : Column(
        children: [

        Padding(
  padding: const EdgeInsets.all(12),
  child: Card(
    elevation: 5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Center(
            child: Text(
              "FILTRO DE MÁQUINAS",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),

          const SizedBox(height: 10),

          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today),
            label: Text(
              fechaSeleccionada == null
                  ? "Seleccionar fecha"
                  : fechaSeleccionada!
                      .toString()
                      .substring(0,10),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(
                double.infinity,
                55,
              ),
            ),
            onPressed: seleccionarFecha,
          ),

          const SizedBox(height: 10),

          DropdownButtonFormField<int?>(
            value: maquinaSeleccionada,

            isExpanded: true,

            decoration: InputDecoration(
              labelText: "Máquina",
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(
                Icons.precision_manufacturing,
              ),
            ),

            items: [

              const DropdownMenuItem<int?>(
                value: null,
                child: Text("Todas"),
              ),

              ...maquinas.map(
                (m) => DropdownMenuItem<int?>(
                  value: m["id"],
                  child: Text(m["nombre"]),
                ),
              ),

            ],

            onChanged: (value) {

              setState(() {

                maquinaSeleccionada = value;

              });

              aplicarFiltros();

            },

          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(

              icon: const Icon(Icons.clear),

              label: const Text(
                "Limpiar filtros",
              ),

              onPressed: () {

                setState(() {

                  fechaSeleccionada = null;

                  maquinaSeleccionada = null;

                  registrosFiltrados =
                      List.from(registros);

                });

              },

            ),
          ),

        ],
      ),
    ),
  ),
),
const SizedBox(height: 5),
          Expanded(
            child: ListView.builder(
              itemCount: registrosFiltrados.length,
              itemBuilder: (context, index) {

                final registro =
                    registrosFiltrados[index];

                return Card(
                  margin: const EdgeInsets.all(8),

                  child: ListTile(

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DetalleRegistroPage(
                            registroId:
                                registro['id'],
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
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(
                      'Registrado por: ${registro['creado_por']}'
                      '\nTurno: ${registro['turno']}'
                      '\nFecha: ${registro['fecha']}',
                    ),

                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        confirmarEliminar(
                          registro['id'],
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
