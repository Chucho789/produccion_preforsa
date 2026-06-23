import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'variables_page.dart';

class MenuSeccionesPage extends StatefulWidget {
  final int maquinaId;
  final String maquinaNombre;

  const MenuSeccionesPage({
    super.key,
    required this.maquinaId,
    required this.maquinaNombre,
  });

  @override
  State<MenuSeccionesPage> createState() =>
      _MenuSeccionesPageState();
}

class _MenuSeccionesPageState
    extends State<MenuSeccionesPage> {

  final supabase = Supabase.instance.client;

  List<String> secciones = [];

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarSecciones();
  }

  Future<void> cargarSecciones() async {

    final data = await supabase
        .from('vw_variables_maquina')
        .select('seccion')
        .eq('maquina_id', widget.maquinaId);

    final lista =
        data.map((e) => e['seccion'].toString())
            .toSet()
            .toList();

    setState(() {
      secciones = lista;
      cargando = false;
    });
  }

  IconData obtenerIcono(String seccion) {

    switch (seccion.toUpperCase()) {

      case 'PRESIONES':
        return Icons.speed;

      case 'ENFRIADOR DE LÁMPARAS':
        return Icons.ac_unit;

      case 'DIMENSIONES DE CABEZALES':
        return Icons.straighten;

      case 'TEMPERATURA DISTRIBUIDOR':
        return Icons.thermostat;

      case 'MODALIDAD AUTOMATICO':
        return Icons.timeline;  

      case 'CABEZALES DE TINTA':
        return Icons.local_drink;
      
      case 'CALEFACTORES MÁQUINA':
        return Icons.whatshot;

      case 'MOLDE':
        return Icons.precision_manufacturing;

      case 'MOLDEADO':
        return Icons.auto_fix_high;

      case 'SISTEMA HIDRÁULICO':
        return Icons.water_drop;

      case 'ENFRIADOR DE AGUA':
        return Icons.ac_unit;

      case 'CUCHILLA DE CORTE':
        return Icons.content_cut;

      
      default:
        return Icons.settings;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.maquinaNombre),
      ),

      body: cargando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),

              itemCount: secciones.length,

              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1,
              ),

              itemBuilder: (context, index) {

                final seccion =
                    secciones[index];

                return InkWell(
                  onTap: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            VariablesPage(
                          maquinaId:
                              widget.maquinaId,
                          maquinaNombre:
                              widget.maquinaNombre,
                          seccion:
                              seccion,
                        ),
                      ),
                    );
                  },

                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,

                      borderRadius: BorderRadius.circular(20),

                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255,102,87,87,).withOpacity(0.50),

                          blurRadius: 8,

                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [

                        Icon(
                          obtenerIcono(seccion),
                          size: 55,
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                        ),

                        const SizedBox(height: 20),

                        Text(
                          seccion,
                          textAlign: TextAlign.center,

                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}