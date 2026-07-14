import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EstadoMaquinaPage extends StatefulWidget {
  const EstadoMaquinaPage({super.key});

  @override
  State<EstadoMaquinaPage> createState() => _EstadoMaquinaPageState();
}

class _EstadoMaquinaPageState extends State<EstadoMaquinaPage> {

  final supabase = Supabase.instance.client;

  List maquinas = [];
  List productos = [];

  int? maquinaSeleccionada;
  int? productoSeleccionado;

  final cicloController = TextEditingController();
  final cavidadesController = TextEditingController();
  final observacionController = TextEditingController();

  String estado = "Producción";

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarMaquinas();
  }

  Future<void> cargarMaquinas() async {

    final data = await supabase
        .from("maquinas")
        .select("id,nombre")
        .order("nombre");

    setState(() {
      maquinas = data;
      cargando = false;
    });

  }

  Future<void> cargarProductos() async {

    if(maquinaSeleccionada == null) return;

    final data = await supabase
        .from("maquina_productos")
        .select("""
          producto_id,
          productos(
            id,
            nombre,
            peso
          )
        """)
        .eq("maquina_id", maquinaSeleccionada!);

    setState(() {
      productos = data;
      productoSeleccionado = null;
    });

  }

  @override
  Widget build(BuildContext context) {
    bool validarDatos() {

  if (maquinaSeleccionada == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Seleccione una máquina")),
    );
    return false;
  }

  if (productoSeleccionado == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Seleccione un producto")),
    );
    return false;
  }

  if (cicloController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ingrese el ciclo")),
    );
    return false;
  }

  if (cavidadesController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ingrese las cavidades")),
    );
    return false;
  }

  return true;
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

Future<Map<String, dynamic>?> buscarRegistroExistente() async {

  final hoy = DateTime.now().toIso8601String().substring(0,10);

  final data = await supabase
      .from("estado_maquinas")
      .select()
      .eq("maquina_id", maquinaSeleccionada!)
      .eq("fecha", hoy)
      .eq("turno", obtenerTurno())
      .maybeSingle();

  return data;
}

String obtenerUsuario() {
  final user = supabase.auth.currentUser;
  return user?.userMetadata?["nombre"] ??
      user?.email ??
      "Usuario";
}

Future<void> guardarEstado() async {
  if (!validarDatos()) return;
  final existente = await buscarRegistroExistente();
  try {
if (existente != null) {
  final actualizar = await showDialog<bool>(

    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text("Registro existente"),
        content: const Text(
          "Ya existe un registro para esta máquina en este turno.\n\n¿Desea actualizarlo?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context,false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context,true),
            child: const Text("Actualizar"),
          ),
        ],
      );
    },
  );
  if(actualizar != true){
    return;
  }
  await supabase
      .from("estado_maquinas")
      .update({
        "producto_id": productoSeleccionado,
        "ciclo": double.parse(cicloController.text),
        "cavidades": int.parse(cavidadesController.text),
        "estado": estado,
        "observacion": observacionController.text,
      })
      .eq("id", existente["id"]);
} else {
  await supabase.from("estado_maquinas").insert({
      "maquina_id": maquinaSeleccionada,
      "producto_id": productoSeleccionado,
      "usuario_id": supabase.auth.currentUser!.id,
      "registrado_por": obtenerUsuario(),
      "fecha": DateTime.now().toIso8601String().substring(0,10),
      "turno": obtenerTurno(),
      "ciclo": double.parse(cicloController.text),
      "cavidades": int.parse(cavidadesController.text),
      "estado": estado,
      "observacion": observacionController.text,
    });
}
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Estado registrado correctamente"),
      ),
    );
    cicloController.clear();
    cavidadesController.clear();
    observacionController.clear();
    setState(() {
      maquinaSeleccionada = null;
      productoSeleccionado = null;
      productos.clear();
      estado = "Producción";

    });

  } catch(e){

    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
      ),
    );
  }
}

    if(cargando){
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Estado de Máquina"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              labelText: "Máquina",
              border: OutlineInputBorder(),
            ),
            value: maquinaSeleccionada,
            items: maquinas.map((m){
              return DropdownMenuItem(
                value: m["id"] as int,
                child: Text(m["nombre"]),
              );
            }).toList(),
            onChanged: (value){
              maquinaSeleccionada = value;
              cargarProductos();
            },
          ),
          const SizedBox(height:10),
          /// Producto
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              labelText: "Producto",
              border: OutlineInputBorder(),
            ),
            value: productoSeleccionado,
            items: productos.map((p){
              final producto = p["productos"];
              return DropdownMenuItem(
                value: producto["id"] as int,
                child: Text(producto["nombre"]),
              );
            }).toList(),
            onChanged: (value){
              setState(() {
                productoSeleccionado = value;
              });
            },
          ),
          const SizedBox(height:10),
          TextField(
            controller: cicloController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Ciclo (seg)",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height:10),
          TextField(
            controller: cavidadesController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Cavidades",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height:20),
          const Text(
            "Estado de Máquina",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize:17,
            ),
          ),
          const SizedBox(height:5),
          ...[
            "Producción",
            "ByPass",
            "Espera de Material",
            "Parada Correctiva",
            "Parada Programada",
            "Parada preventiva",
            "Sin Producción",
          ].map((e){

  return RadioListTile<String>(
    value: e,
    groupValue: estado,
    dense: true,
    visualDensity: const VisualDensity(
      horizontal: -4,
      vertical: -4,
    ),
    contentPadding: EdgeInsets.zero,
    title: Text(e,
      style: const TextStyle(
        fontSize: 15,
      ),
    ),
    onChanged: (v){
      setState(() {
        estado = v!;
      });
    },
  );
}),
const SizedBox(height:10),
          TextField(
            controller: observacionController,
            maxLines:2,
            decoration: const InputDecoration(
              labelText: "Observación",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height:15),
          SizedBox(
            height:55,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("Guardar"),
              onPressed: guardarEstado,
            ),
          ),
        ],
      ),
    );
  }
}