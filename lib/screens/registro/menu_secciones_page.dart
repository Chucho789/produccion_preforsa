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

  bool cargando = true;

  List<String> secciones = [];
  final Map<String, Map<String, dynamic>>
      registrosPorSeccion = {};
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
    secciones = data
        .map((e) => e['seccion'].toString())
        .toSet()
        .toList();
    setState(() {
      cargando = false;

    });
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
  bool get registroCompleto {
    return registrosPorSeccion.length ==
        secciones.length;
  }
  Future<void> abrirSeccion(
      String seccion) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VariablesPage(
          maquinaId: widget.maquinaId,
          maquinaNombre:
              widget.maquinaNombre,
          seccion: seccion,
        ),
      ),
    );
    if (resultado == null) return;
    registrosPorSeccion[seccion] =
        Map<String, dynamic>.from(resultado);
    setState(() {});
  }
  Future<void> guardarRegistroCompleto() async {
  if (!registroCompleto) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Debe registrar todas las secciones.",
        ),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }
  try {
    final usuario = supabase.auth.currentUser;
    if (usuario == null) return;
    String nombreUsuario = "Operador";
    final perfil = await supabase
        .from("perfiles")
        .select("nombre")
        .eq("id", usuario.id)
        .maybeSingle();
    if (perfil != null) {
      nombreUsuario = perfil["nombre"];
    }
    final registro = await supabase
        .from("registros")
        .insert({
      "fecha": DateTime.now()
          .toIso8601String()
          .substring(0,10),
      "turno": obtenerTurnoNumero(),
      "maquina_id": widget.maquinaId,
      "usuario_id": usuario.id,
      "creado_por": nombreUsuario,
      "fecha_hora":
          DateTime.now().toIso8601String(),
    })
        .select()
        .single();
    final registroId = registro["id"];
    for (final seccion
        in registrosPorSeccion.values) {
      final variables =
          List<Map<String,dynamic>>.from(
        seccion["variables"],
      );
      for (final variable in variables) {
        final texto =
            variable["valor"]
                .toString()
                .trim();
        if (texto == "-") {
          await supabase
              .from("registro_detalle")
              .insert({
            "registro_id": registroId,
            "variable_id":
                variable["variable_id"],
            "valor_texto": "-",
          });
        } else {
          final numero =
              double.tryParse(
            texto.replaceAll(",", "."),
          );
          await supabase
              .from("registro_detalle")
              .insert({
            "registro_id": registroId,
            "variable_id":
                variable["variable_id"],
            "valor": numero,
          });
        }
      }
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Registro guardado correctamente.",
        ),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  catch(e){
    debugPrint(e.toString());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
      ),
    );
  }
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
    case "DATOS GENERALES":
      return Icons.thermostat;      
    case "CICLO ESTÁNDAR":
      return  Icons.repeat;
    case "FASES":
      return Icons.timeline;           
    case "TEMPERATURAS TORNILLO":
      return Icons.thermostat_auto_outlined;     
    case "TORNILLO":
      return Icons.device_thermostat;
    case "INYECTOR":
      return  Icons.speed;
    case "HOT RUNNER":
      return Icons.local_fire_department;
    case "SECADOR":
      return Icons.air;
    default:
      return Icons.settings;
  }
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
      title: Text(widget.maquinaNombre),
    ),
    body: Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: secciones.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1,
            ),

            itemBuilder: (context,index){
              final seccion = secciones[index];
              final registrada =
                  registrosPorSeccion.containsKey(
                      seccion);
              return InkWell(
                onTap: (){
                  abrirSeccion(seccion);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius:
                        BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(.15),
                        blurRadius: 8,
                        offset: const Offset(0,4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        registrada
                            ? Icons.check_circle
                            : obtenerIcono(seccion),
                        size: 55,
                        color: registrada
                            ? Colors.green
                            : Theme.of(context)
                                .colorScheme
                                .primary,
                      ),
                      const SizedBox(height:20),
                      Text(
                        seccion,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed:
                  guardarRegistroCompleto,
              icon: const Icon(Icons.save),
              label: const Text(
                "Guardar Registro",
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}