import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetalleRegistroPage extends StatefulWidget {
  final int registroId;

  const DetalleRegistroPage({
    super.key,
    required this.registroId,
  });

  @override
  State<DetalleRegistroPage> createState() =>
      _DetalleRegistroPageState();
}

class _DetalleRegistroPageState
    extends State<DetalleRegistroPage> {

  final supabase = Supabase.instance.client;

  bool cargando = true;

  List detalles = [];

  @override
  void initState() {
    super.initState();
    cargarDetalle();
  }

  Future<void> cargarDetalle() async {

        final data = await supabase
            .from('registro_detalle')
            .select('''
              valor,
              valor_texto,
              variables(
                nombre,
                unidad,
                seccion,
                subseccion
              )
            ''')
            .eq(
              'registro_id',
              widget.registroId,
            );
            print(data);

    setState(() {
      detalles = data;
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Map<String, List<dynamic>>> grupos = {};

for (final detalle in detalles) {

  final variable = detalle['variables'];

  final seccion =
      variable['seccion'] ?? 'Sin sección';

  final subseccion =
      (variable['subseccion'] ?? '')
          .toString()
          .trim();

  grupos.putIfAbsent(
    seccion,
    () => {},
  );

  grupos[seccion]!.putIfAbsent(
    subseccion,
    () => [],
  );

  grupos[seccion]![subseccion]!
      .add(detalle);
}
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registro #${widget.registroId}',
        ),
      ),

      body: cargando
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : ListView(
    children: grupos.entries.map((seccion) {

      return Card(
        margin: const EdgeInsets.all(8),

        child: ExpansionTile(

          initiallyExpanded: true,

          title: Text(
            seccion.key,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          children: seccion.value.entries.map((sub) {

            final tieneSubseccion =
                sub.key.isNotEmpty;

            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                if (tieneSubseccion)
                  Padding(
                    padding:
                        const EdgeInsets.all(12),
                    child: Text(
                      sub.key,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),

                ...sub.value.map((detalle) {

                  final variable =
                      detalle['variables'];

                  String valor = '';

                  if (detalle['valor_texto'] !=
                      null) {

                    valor =
                        detalle['valor_texto']
                            .toString();

                  } else {

                    valor =
                        detalle['valor']
                            .toString();
                  }

                  return ListTile(

                    title: Text(
                      variable['nombre'],
                    ),

                    subtitle: Text(
                      variable['unidad'] ?? '',
                    ),

                    trailing: Text(
                      valor,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  );
                }),
              ],
            );
          }).toList(),
        ),
      );
    }).toList(),
)
    );
  }
}