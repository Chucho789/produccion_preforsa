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

      final usuario =
          Supabase.instance.client.auth.currentUser;

      final perfil = await supabase
          .from('perfiles')
          .select()
          .eq('id', usuario!.id)
          .single();

      final registro = await supabase
          .from('registros')
          .insert({
            'fecha':
                DateTime.now().toIso8601String().substring(0, 10),

            'turno': obtenerTurnoNumero(),

            'maquina_id': widget.maquinaId,

            'usuario_id': usuario.id,

            'creado_por': perfil['nombre'],
          })
          .select()
          .single();
      final registroId = registro['id'];
      for (var variable in variables) {
        final variableId = variable['variable_id'];
        final texto =
              controllers[variableId]?.text.trim() ?? '';

          if (texto.isEmpty) {
            throw Exception(
              'Debe completar todas las variables.'
            );
          }
        await supabase
            .from('registro_detalle')
            .insert({

          'registro_id': registroId,

          'variable_id': variableId,

          'valor':
              texto == '-'
                  ? null
                  : double.parse(texto),

          'valor_texto':
              texto == '-'
                  ? '-'
                  : null,
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

Color obtenerColorTarjeta(
  String texto,
  double min,
  double max,
) {
  if (texto.isEmpty) {
    return Colors.white;
  }

  final valor = double.tryParse(texto);

  if (valor == null) {
    return Colors.white;
  }

  if (valor < min || valor > max) {
    return Colors.red.shade200;
  }

  final rango = max - min;

  if (rango <= 0) {
    return Colors.green.shade200;
  }

  final zonaAmarilla = rango * 0.10;

  if (
      valor <= min + zonaAmarilla ||
      valor >= max - zonaAmarilla) {
    return Colors.yellow.shade200;
  }

  return Colors.green.shade200;
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
          ...construirSubsecciones(
            entry.value,
          ),
        ],
      ),
    );
  }).toList();
}

List<Widget> construirSubsecciones(
    List<dynamic> variablesSeccion) {
  final Map<String, List<dynamic>> subsecciones = {};
  for (final variable in variablesSeccion) {
    final subseccion =
        (variable['subseccion'] ?? '')
            .toString()
            .trim();
    if (subseccion.isEmpty) {
      continue;
    }
    subsecciones.putIfAbsent(
      subseccion,
      () => [],
    );
    subsecciones[subseccion]!.add(variable);
  }
if (subsecciones.isEmpty) {
  return [
    Padding(
      padding: const EdgeInsets.all(6),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: variablesSeccion.map((variable) {
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
          return SizedBox(
            width: 160,

            child: Container(
              padding:
                  const EdgeInsets.all(5),

              decoration: BoxDecoration(
                color: obtenerColorTarjeta(
                  controller.text,
                  min,
                  max,
                ),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Text(
                    variable[
                        'variable_nombre'],
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                      height: 4),

                  SizedBox(
                  height: 40,
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [

                      TextFormField(
                        controller: controller,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.text,
                        onChanged: (_) {
                            setState(() {});
                          },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(right: 25),
                        child: IgnorePointer(
                          child: Text(
                            variable['unidad'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    ),
  ];
}

  return subsecciones.entries.map((subgrupo) {

    return ExpansionTile(
      title: Text(
        subgrupo.key,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),

      children: [
        Padding(
          padding: const EdgeInsets.all(5),

          child: GridView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),

            itemCount: subgrupo.value.length,

            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 5,
              childAspectRatio: 1,
            ),

            itemBuilder: (context, index) {

              final variable =
                  subgrupo.value[index];

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

              print(
                  '${variable['variable_nombre']} -> ${variable['unidad']}'
                );
              
              return StatefulBuilder(
                builder:
                    (context, actualizar) {

                  return Container(
                    padding:
                        const EdgeInsets.all(5),

                    decoration: BoxDecoration(
                        color: obtenerColorTarjeta(
                          controller.text,
                          min,
                          max,
                        ),

                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),

                        borderRadius:
                            BorderRadius.circular(15),
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
                            fontSize: 10,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                            height: 2),


                          TextFormField(
                              controller: controller,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.text,
                              onChanged: (_) {
                                actualizar(() {});
                              },
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),

                                suffixText: variable['unidad'],

                                suffixStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 163, 156, 156),
                                ),
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

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}