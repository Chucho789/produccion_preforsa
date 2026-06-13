import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IpsSeccionPage extends StatefulWidget {
final int maquinaId;
final String maquinaNombre;
final String seccion;

const IpsSeccionPage({
super.key,
required this.maquinaId,
required this.maquinaNombre,
required this.seccion,
});

@override
State<IpsSeccionPage> createState() =>
_IpsSeccionPageState();
}

class _IpsSeccionPageState
extends State<IpsSeccionPage> {

final supabase = Supabase.instance.client;

bool cargando = true;
bool guardando = false;
List variables = [];

final Map<int, TextEditingController>
controllers = {};

@override
void initState() {
super.initState();
cargarVariables();
}

Future<void> cargarVariables() async {

final data = await supabase
    .from('vw_variables_maquina')
    .select()
    .eq('maquina_id', widget.maquinaId)
    .eq('seccion', widget.seccion)
    .order('orden');

for (final variable in data) {
  controllers[variable['variable_id']] =
      TextEditingController();
}

setState(() {
  variables = data;
  cargando = false;
});

}

int obtenerTurno() {
  final hora = DateTime.now().hour;

  if (hora >= 7 && hora < 15) {
    return 1;
  }

  if (hora >= 15 && hora < 23) {
    return 2;
  }

  return 3;
}

bool validarCampos() {
  for (final variable in variables) {
    final obligatorio =
        variable['obligatorio'] ?? false;

    if (!obligatorio) continue;

    final controller =
        controllers[variable['variable_id']]!;

    if (controller.text.trim().isEmpty) {
      return false;
    }
  }

  return true;
}

Future<void> guardarDatos() async {
  try {
    if (!validarCampos()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debe completar todos los campos',
          ),
        ),
      );
      return;
    }

    setState(() {
      guardando = true;
    });

    final usuario =
        supabase.auth.currentUser;

    String nombreUsuario = 'Operador';

    if (usuario != null) {
      final perfil = await supabase
          .from('perfiles')
          .select('nombre')
          .eq('id', usuario.id)
          .maybeSingle();

      if (perfil != null) {
        nombreUsuario =
            perfil['nombre'];
      }
    }

    final registro = await supabase
        .from('registros')
        .insert({
          'fecha':
              DateTime.now()
                  .toIso8601String()
                  .substring(0, 10),

          'turno': obtenerTurno(),

          'maquina_id':
              widget.maquinaId,

          'usuario_id':
              usuario?.id,

          'creado_por':
              nombreUsuario,

          'fecha_hora':
              DateTime.now()
                  .toIso8601String(),
        })
        .select()
        .single();

    final registroId =
        registro['id'];

    for (final variable in variables) {
      final controller =
          controllers[
              variable['variable_id']]!;

      final texto =
          controller.text.trim();

      if (texto.isEmpty) {
        continue;
      }

      if (variable['tipo'] ==
          'texto') {
        await supabase
            .from(
                'registro_detalle')
            .insert({
          'registro_id':
              registroId,

          'variable_id':
              variable[
                  'variable_id'],

          'valor_texto':
              texto,
        });
      } else {
        await supabase
            .from(
                'registro_detalle')
            .insert({
          'registro_id':
              registroId,

          'variable_id':
              variable[
                  'variable_id'],

          'valor': double.parse(
            texto.replaceAll(
                ',', '.'),
          ),
        });
      }
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Datos guardados correctamente',
        ),
      ),
    );

    for (final controller
        in controllers.values) {
      controller.clear();
    }
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

  setState(() {
    guardando = false;
  });
}

Color obtenerColor(
TextEditingController controller,
double min,
double max,
) {
if (controller.text.isEmpty) {
return Colors.white;
}
final valor = double.tryParse(
  controller.text.replaceAll(',', '.'),
);

if (valor == null) {
  return Colors.white;
}

if (valor >= min && valor <= max) {
  return Colors.green.shade100;
}

return Colors.red.shade100;

}

List<Widget> construirSecciones() {

  return [

    GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),

      itemCount: variables.length,

      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),

      itemBuilder: (context, index) {

        final variable =
            variables[index];

        final controller =
            controllers[
                variable['variable_id']]!;

        return StatefulBuilder(
          builder:
              (context, setCardState) {

            return Card(
              color: obtenerColor(
                controller,
                (variable['valor_min'] ?? 0)
                    .toDouble(),
                (variable['valor_max'] ?? 0)
                    .toDouble(),
              ),

              child: Padding(
                padding:
                    const EdgeInsets.all(12),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      variable[
                          'variable_nombre'],

                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    TextField(
                      controller:
                          controller,

                      onChanged: (_) {
                        setCardState(() {});
                      },

                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),

                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),

                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Center(
                            widthFactor: 1,
                            child: Text(
                              variable['unidad'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ),
  ];
}

@override
Widget build(BuildContext context) {

if (cargando) {
  return const Scaffold(
    body: Center(
      child: CircularProgressIndicator(),
    ),
  );
}

return Scaffold(
  appBar: AppBar(
    title: Text(widget.seccion),
  ),
body: Column(
  children: [
    Expanded(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: construirSecciones(),
        
      ),
    ),

    Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton.icon(
          onPressed: guardando
              ? null
              : guardarDatos,
          icon: const Icon(Icons.save),
          label: Text(
            guardando
                ? 'Guardando...'
                : 'Guardar',
          ),
        ),
      ),
    ),
  ],
),
);
}
}
