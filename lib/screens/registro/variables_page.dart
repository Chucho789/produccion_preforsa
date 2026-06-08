import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VariablesPage extends StatefulWidget {
  final int maquinaId;
  final String maquinaNombre;

  const VariablesPage({
    super.key,
    required this.maquinaId,
    required this.maquinaNombre,
  });

  @override
  State<VariablesPage> createState() => _VariablesPageState();
}

class _VariablesPageState extends State<VariablesPage> {
  final supabase = Supabase.instance.client;

  List<dynamic> variables = [];

  final Map<int, TextEditingController> controllers = {};

  bool cargando = true;
  bool guardando = false;

  @override
  void initState() {
    super.initState();
    cargarVariables();
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> cargarVariables() async {
    try {
      final data = await supabase
          .from('vw_variables_maquina')
          .select()
          .eq('maquina_id', widget.maquinaId)
          .order('orden');

      for (var variable in data) {
        controllers[variable['variable_id']] =
            TextEditingController();
      }

      setState(() {
        variables = data;
        cargando = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        cargando = false;
      });
    }
  }

  int obtenerTurnoNumero() {
    final hora = DateTime.now().hour;

    if (hora >= 7 && hora < 15) {
      return 1;
    }

    if (hora >= 15 && hora < 23) {
      return 2;
    }

    return 3;
  }

  Future<void> guardarRegistro() async {
    try {
      setState(() {
        guardando = true;
      });

      final registro = await supabase
          .from('registros')
          .insert({
            'fecha':
                DateTime.now().toIso8601String().substring(0, 10),
            'turno': obtenerTurnoNumero(),
            'maquina_id': widget.maquinaId,
            'creado_por': 'Operador',
          })
          .select()
          .single();

      final registroId = registro['id'];

      for (var variable in variables) {
        final variableId = variable['variable_id'];

        final texto =
            controllers[variableId]?.text.trim() ?? '';

        if (texto.isEmpty) continue;

        await supabase.from('registro_detalle').insert({
          'registro_id': registroId,
          'variable_id': variableId,
          'valor': double.parse(texto),
        });
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registro guardado correctamente',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al guardar: $e',
          ),
        ),
      );
    }

    setState(() {
      guardando = false;
    });
  }

  Color obtenerColorSemaforo(
    String texto,
    double min,
    double max,
  ) {
    if (texto.isEmpty) {
      return Colors.grey;
    }

    final valor = double.tryParse(texto);

    if (valor == null) {
      return Colors.grey;
    }

    if (valor < min || valor > max) {
      return Colors.red;
    }

    final rango = max - min;

    final zonaAmarilla = rango * 0.10;

    if (valor <= min + zonaAmarilla ||
        valor >= max - zonaAmarilla) {
      return Colors.orange;
    }

    return Colors.green;
  }
  List<Widget> construirSecciones() {
  final Map<String, List<dynamic>> secciones = {};

  for (final variable in variables) {
    final seccion =
        variable['seccion'] ?? 'Sin sección';

    if (!secciones.containsKey(seccion)) {
      secciones[seccion] = [];
    }

    secciones[seccion]!.add(variable);
  }

  return secciones.entries.map((entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          entry.key,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: GridView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),

              itemCount: entry.value.length,

              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.5,
              ),

              itemBuilder: (context, index) {
                final variable =
                    entry.value[index];

                final variableId =
                    variable['variable_id'];

                final controller =
                    controllers[variableId]!;

                final min =
                    (variable['valor_min'] ?? 0)
                        .toDouble();

                final max =
                    (variable['valor_max'] ?? 0)
                        .toDouble();

                return StatefulBuilder(
                  builder:
                      (context, actualizar) {
                    return Container(
                      padding:
                          const EdgeInsets.all(8),

                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              Colors.grey.shade300,
                        ),

                        borderRadius:
                            BorderRadius.circular(
                                12),
                      ),

                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [
                          Text(
                            variable[
                                'variable_nombre'],

                            textAlign:
                                TextAlign.center,

                            maxLines: 2,

                            overflow:
                                TextOverflow.ellipsis,

                            style:
                                const TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                              height: 8),

                          TextFormField(
                            controller:
                                controller,

                            textAlign:
                                TextAlign.center,

                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),

                            onChanged: (_) {
                              actualizar(() {});
                            },

                            decoration:
                                InputDecoration(
                              isDense: true,

                              hintText:
                                  variable['unidad'],

                              border:
                                  const OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(
                              height: 6),

                          CircleAvatar(
                            radius: 8,

                            backgroundColor:
                                obtenerColorSemaforo(
                              controller.text,
                              min,
                              max,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }).toList();
}
  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.maquinaNombre),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.maquinaNombre),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...construirSecciones(),
          /*...variables.map((variable) {
            final variableId = variable['variable_id'];

            final controller =
                controllers[variableId]!;

            final min =
                (variable['valor_min'] ?? 0)
                    .toDouble();

            final max =
                (variable['valor_max'] ?? 0)
                    .toDouble();

            return StatefulBuilder(
              builder: (context, actualizar) {
                return Card(
                  margin:
                      const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          variable['variable_nombre'],
                          style:
                              const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'Rango: $min - $max ${variable['unidad']}',
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 55,
                                child:
                                    TextFormField(
                                  controller:
                                      controller,

                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal:
                                        true,
                                  ),

                                  onChanged: (_) {
                                    actualizar(
                                        () {});
                                  },

                                  decoration:
                                      InputDecoration(
                                    hintText:
                                        variable[
                                            'unidad'],
                                    border:
                                        const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                                width: 12),

                            CircleAvatar(
                              radius: 12,
                              backgroundColor:
                                  obtenerColorSemaforo(
                                controller.text,
                                min,
                                max,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),*/

          const SizedBox(height: 20),

          SizedBox(
            height: 55,
            child: ElevatedButton.icon(
              onPressed:
                  guardando ? null : guardarRegistro,
              icon: const Icon(Icons.save),
              label: Text(
                guardando
                    ? 'Guardando...'
                    : 'Guardar Registro',
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}