import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IpsDatosGeneralesPage extends StatefulWidget {
  final int maquinaId;
  final String maquinaNombre;

  const IpsDatosGeneralesPage({
    super.key,
    required this.maquinaId,
    required this.maquinaNombre,
  });

  @override
  State<IpsDatosGeneralesPage> createState() =>
      _IpsDatosGeneralesPageState();
}

class _IpsDatosGeneralesPageState
    extends State<IpsDatosGeneralesPage> {
  final supabase = Supabase.instance.client;

  bool guardando = false;

  final aceiteController = TextEditingController();
  final aguaEntradaController = TextEditingController();
  final aguaManoController = TextEditingController();
  final aguaMoldeController = TextEditingController();
  final dewPointController = TextEditingController();
  final secadorController = TextEditingController();
  final materialController = TextEditingController();

  @override
  void dispose() {
    aceiteController.dispose();
    aguaEntradaController.dispose();
    aguaManoController.dispose();
    aguaMoldeController.dispose();
    dewPointController.dispose();
    secadorController.dispose();
    materialController.dispose();
    super.dispose();
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

  Future<void> guardarDatos() async {
    try {
      setState(() {
        guardando = true;
      });

      final registro = await supabase
          .from('registros')
          .insert({
            'fecha':
                DateTime.now().toIso8601String().substring(0, 10),
            'turno': obtenerTurno(),
            'maquina_id': widget.maquinaId,
            'creado_por': 'Operador',
            'fecha_hora':
                DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final registroId = registro['id'];

      final variables = [
        {
          'id': 9,
          'controller': aceiteController,
        },
        {
          'id': 10,
          'controller': aguaEntradaController,
        },
        {
          'id': 11,
          'controller': aguaManoController,
        },
        {
          'id': 12,
          'controller': aguaMoldeController,
        },
        {
          'id': 13,
          'controller': dewPointController,
        },
        {
          'id': 14,
          'controller': secadorController,
        },
        {
          'id': 15,
          'controller': materialController,
        },
      ];

      for (final variable in variables) {
        final controller =
            variable['controller'] as TextEditingController;

        if (controller.text.trim().isEmpty) {
          continue;
        }

        await supabase
            .from('registro_detalle')
            .insert({
          'registro_id': registroId,
          'variable_id': variable['id'],
          'valor': double.parse(
            controller.text.replaceAll(',', '.'),
          ),
        });
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Datos guardados correctamente',
          ),
        ),
      );

      aceiteController.clear();
      aguaEntradaController.clear();
      aguaManoController.clear();
      aguaMoldeController.clear();
      dewPointController.clear();
      secadorController.clear();
      materialController.clear();
    } catch (e) {
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

  Widget campo(
    String titulo,
    String unidad,
    TextEditingController controller,
  ) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                prefixText: '$unidad ',
                hintText: '0.0',
                border:
                    const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Datos Generales',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              padding:
                  const EdgeInsets.all(16),
              children: [
                campo(
                  'Temperatura Aceite',
                  '°C',
                  aceiteController,
                ),

                campo(
                  'Temperatura Agua Entrada Máquina',
                  '°C',
                  aguaEntradaController,
                ),

                campo(
                  'Temperatura Agua Mano Toma',
                  '°C',
                  aguaManoController,
                ),

                campo(
                  'Temperatura Agua Molde',
                  '°C',
                  aguaMoldeController,
                ),

                campo(
                  'Dew Point Secador',
                  '°C',
                  dewPointController,
                ),

                campo(
                  'Temperatura Secador',
                  '°C',
                  secadorController,
                ),

                campo(
                  'Temperatura Entrada Material',
                  '°C',
                  materialController,
                ),
              ],
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.all(16),
            child: SizedBox(
              height: 55,
              width: double.infinity,
              child:
                  ElevatedButton.icon(
                onPressed: guardando
                    ? null
                    : guardarDatos,
                icon: const Icon(
                  Icons.save,
                ),
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