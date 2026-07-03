import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VariablesPage extends StatefulWidget {
  final int maquinaId;
  final String maquinaNombre;
  final String seccion;

  final Map<String, dynamic>? datosSeccion;

  const VariablesPage({
    super.key,
    required this.maquinaId,
    required this.maquinaNombre,
    required this.seccion,
    this.datosSeccion,
  });

  @override
  State<VariablesPage> createState() => _VariablesPageState();
}

class _VariablesPageState extends State<VariablesPage> {

  final supabase = Supabase.instance.client;

  bool cargando = true;

  List<dynamic> variables = [];

  final Map<int, TextEditingController> controllers = {};

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
          .eq('seccion', widget.seccion)
          .order('orden');

      for (final variable in data) {

  String valorInicial = "";

  if (widget.datosSeccion != null) {

    final lista = List<Map<String, dynamic>>.from(
      widget.datosSeccion!["variables"],
    );

    final encontrado = lista.firstWhere(

      (v) => v["variable_id"] == variable["variable_id"],

      orElse: () => <String, dynamic>{},

    );

    if (encontrado.isNotEmpty) {
      valorInicial =
          encontrado["valor"]?.toString() ?? "";
    }

  }

  controllers[variable["variable_id"]] =
      TextEditingController(
    text: valorInicial,
  );

}

      setState(() {

        variables = data;

        cargando = false;

      });

    } catch (e) {

      debugPrint(e.toString());

    }

  }

  bool validarSeccionCompleta() {

    for (final variable in variables) {

      final id = variable['variable_id'];

      final texto = controllers[id]!.text.trim();

      if (texto.isEmpty) {

        return false;

      }

    }

    return true;

  }

  Color obtenerColorTarjeta(

    BuildContext context,

    String texto,

    double min,

    double max,

  ) {

    final oscuro =
        Theme.of(context).brightness ==
            Brightness.dark;

    final colorBase =
        oscuro
            ? const Color(0xff2b2b2b)
            : Colors.white;

    if (texto.isEmpty) return colorBase;

    final valor = double.tryParse(
      texto.replaceAll(",", "."),
    );

    if (valor == null) return colorBase;

    if (valor < min || valor > max) {

      return oscuro
          ? const Color(0xff5b2323)
          : Colors.red.shade200;

    }

    final rango = max - min;

    final margen = rango * .10;

    if (valor <= min + margen ||
        valor >= max - margen) {

      return oscuro
          ? const Color(0xff6a5c14)
          : Colors.yellow.shade200;

    }

    return oscuro
        ? const Color(0xff1d4d28)
        : Colors.green.shade200;

  }
  Widget construirTarjeta(dynamic variable) {

    final id = variable['variable_id'];

    final controller = controllers[id]!;

    final minimo =
        (variable['valor_min'] ?? 0).toDouble();

    final maximo =
        (variable['valor_max'] ?? 0).toDouble();

    return SizedBox(

      width: 170,

      child: Container(

        padding: const EdgeInsets.all(8),

        decoration: BoxDecoration(

          color: obtenerColorTarjeta(
            context,
            controller.text,
            minimo,
            maximo,
          ),

          borderRadius: BorderRadius.circular(15),

          border: Border.all(
            color: Colors.grey.shade300,
          ),

        ),

        child: Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            Text(

              variable['variable_nombre'],

              textAlign: TextAlign.center,

              style: const TextStyle(

                fontWeight: FontWeight.bold,

                fontSize: 12,

              ),

            ),

            const SizedBox(height: 8),

            TextFormField(

              controller: controller,

              textAlign: TextAlign.center,

              keyboardType:
                  variable['tipo'] == 'texto'
                      ? TextInputType.text
                      : const TextInputType.numberWithOptions(
                          decimal: true,
                        ),

              onChanged: (_) {

                setState(() {});

              },

              decoration: InputDecoration(

                border: const OutlineInputBorder(),

                isDense: true,

                suffixText:
                    variable['unidad'] ?? '',

                contentPadding:
                    const EdgeInsets.symmetric(

                  horizontal: 10,

                  vertical: 10,

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

  List<Widget> construirVariables() {

    variables.sort(

      (a, b) =>

          (a['orden'] ?? 0)

              .compareTo(

            b['orden'] ?? 0,

          ),

    );

    return [

      Wrap(

        alignment: WrapAlignment.center,

        spacing: 12,

        runSpacing: 12,

        children: variables

            .map(

              (variable) =>

                  construirTarjeta(variable),

            )

            .toList(),

      ),

    ];

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

        title: Text(widget.seccion),

      ),

      body: ListView(

        padding: const EdgeInsets.all(16),

        children: [

          ...construirVariables(),

          const SizedBox(height: 25),

          SizedBox(

            height: 55,

            child: ElevatedButton.icon(

              icon: const Icon(
                Icons.check_circle,
              ),

              label: const Text(
                "Sección registrada",
              ),

              onPressed: () {

                if (!validarSeccionCompleta()) {

                  ScaffoldMessenger.of(context)
                      .showSnackBar(

                    const SnackBar(

                      content: Text(
                        "Debe completar todas las variables.",
                      ),

                      backgroundColor: Colors.red,

                    ),

                  );

                  return;

                }

                Navigator.pop(

                  context,

                  {

                    "seccion": widget.seccion,

                    "variables":

                        variables.map((variable) {

                      final id =
                          variable['variable_id'];

                      return {

                        "variable_id": id,

                        "valor":
                            controllers[id]!
                                .text
                                .trim(),

                      };

                    }).toList(),

                  },

                );

              },

            ),

          ),

          const SizedBox(height: 20),

        ],

      ),

    );

  }

}