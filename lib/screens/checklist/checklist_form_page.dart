import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChecklistFormPage extends StatefulWidget {
  final int maquinaId;
  final String maquinaNombre;
  final int tipoId;
  final String titulo;

  const ChecklistFormPage({
    super.key,
    required this.maquinaId,
    required this.maquinaNombre,
    required this.tipoId,
    required this.titulo,
  });

  @override
  State<ChecklistFormPage> createState() => _ChecklistFormPageState();
}

class _ChecklistFormPageState extends State<ChecklistFormPage> {

final supabase = Supabase.instance.client;

bool cargando = true;

List<Map<String,dynamic>> items = [];
List<Map<String,dynamic>> itemsMostrar = [];
int get inspeccionesCompletadas{
  return items.where((e)=>e["estado"]!="").length;
}

double get progreso{
  if(items.isEmpty)return 0;
  return inspeccionesCompletadas/items.length;
}

  @override
  void initState() {
    super.initState();
    cargarItems();
  }

Future<void> cargarItems() async {
  try {
    final data = await supabase
        .from("checklist_items")
        .select()
        .eq("tipo_id", widget.tipoId)
        .eq("maquina_id", widget.maquinaId)
        .order("orden_categoria")
        .order("orden");

    debugPrint("Checklist cargado: ${data.length} items");

items = data.map<Map<String,dynamic>>((e){
  return{
    "id":e["id"],
    "descripcion":e["descripcion"],
    "categoria":e["categoria"]??"",
    "orden":e["orden"]??0,
    "orden_categoria":e["orden_categoria"]??999,
    "estado":"",
    "comentario":"",
  };
}).toList();
items.sort((a,b){

  final cat = (a["orden_categoria"] as int)
      .compareTo(b["orden_categoria"] as int);

  if(cat != 0){
    return cat;
  }

  return (a["orden"] as int)
      .compareTo(b["orden"] as int);

});
itemsMostrar.clear();

String categoriaActual = "";

for(final item in items){

  if(item["categoria"] != categoriaActual){

    categoriaActual = item["categoria"];

    itemsMostrar.add({
      "header": true,
      "categoria": categoriaActual,
    });

  }

  itemsMostrar.add(item);

}
    setState(() {
      cargando = false;
    });

  } catch (e, s) {
    debugPrint("ERROR Checklist");
    debugPrint(e.toString());
    debugPrint(s.toString());

    setState(() {
      cargando = false;
    });
  }
}

Future<void> guardarChecklist() async {

  for(final item in items){

    if(item["estado"]==""){

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content: Text("Debe completar todos los ítems."),
          backgroundColor: Colors.red,
        ),

      );

      return;

    }

  }

  final usuario=supabase.auth.currentUser;

  if(usuario==null)return;

  String nombre="Operador";

  final perfil=await supabase
      .from("perfiles")
      .select("nombre")
      .eq("id",usuario.id)
      .maybeSingle();

  if(perfil!=null){

    nombre=perfil["nombre"];

  }

  int turno=3;

  final hora=DateTime.now().hour;

  if(hora>=7&&hora<15){
    turno=1;
  }else if(hora>=15&&hora<23){
    turno=2;
  }

  final encabezado=await supabase
      .from("checklist_registros")
      .insert({

        "tipo_id":widget.tipoId,
        "maquina_id":widget.maquinaId,
        "usuario_id":usuario.id,
        "operador":nombre,
        "turno":turno,
        "fecha": DateTime.now().toIso8601String().substring(0,10),
        "hora": TimeOfDay.now().format(context),
        "fecha_hora": DateTime.now().toIso8601String(),
        "observacion_general": "",

      })
      .select()
      .single();

  final checklistId=encabezado["id"];

for(final item in items){

  await supabase
      .from("checklist_detalle")
      .insert({

        "checklist_id": encabezado["id"],
        "item_id": item["id"],
        "estado": item["estado"],
        "comentario": item["comentario"],

      });

}

  if(!mounted)return;

  ScaffoldMessenger.of(context).showSnackBar(

    const SnackBar(

      content: Text("Checklist guardado correctamente."),

      backgroundColor: Colors.green,

    ),

  );

  Navigator.pop(context);

}

  @override
  Widget build(BuildContext context){
if(cargando){
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
          Padding(
  padding: const EdgeInsets.fromLTRB(16,16,16,8),
  child: Column(
    children:[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:[
          Text(
            "$inspeccionesCompletadas de ${items.length} inspecciones",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize:16,
            ),
          ),
          Text(
            "${(progreso*100).toStringAsFixed(0)}%",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize:16,
            ),
          ),
        ],
      ),
      const SizedBox(height:8),
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: LinearProgressIndicator(
          value: progreso,
          minHeight: 12,
        ),
      ),
    ],
  ),
),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: itemsMostrar.length,
              itemBuilder:(context,index){
                final item = itemsMostrar[index];
                if(item["header"] == true){

  return Padding(

    padding: const EdgeInsets.only(
      top:20,
      bottom:10,
    ),

    child: Container(

      padding: const EdgeInsets.symmetric(
        vertical:10,
        horizontal:15,
      ),

      decoration: BoxDecoration(

        color: Colors.deepPurple,

        borderRadius: BorderRadius.circular(8),

      ),

      child: Text(

        item["categoria"],

        style: const TextStyle(

          color: Colors.white,

          fontSize:18,

          fontWeight: FontWeight.bold,

          letterSpacing:1,

        ),

      ),

    ),

  );

}
                return Card(
                  margin: const EdgeInsets.only(bottom:8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal:12,
                        vertical:5,
                      ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children:[
                        Text(
                          item["descripcion"],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize:17,
                          ),
                        ),
                        const SizedBox(height:6),

                        RadioListTile<String>(
                          dense: true,
                          visualDensity: const VisualDensity(
                            vertical: -4,
                          ),
                          contentPadding: EdgeInsets.zero,
                          value:"COMPLETADO",
                          groupValue:item["estado"],
                          activeColor: Colors.green,
                          title:const Text("Completado"),
                          onChanged:(v){
                            setState((){
                              item["estado"]=v;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          dense: true,
                          visualDensity: const VisualDensity(
                            vertical: -4,
                          ),
                          contentPadding: EdgeInsets.zero,
                          value:"NO COMPLETADO",
                          groupValue:item["estado"],
                          activeColor: Colors.red,
                          title:const Text("No completado"),
                          onChanged:(v){
                            setState((){
                              item["estado"]=v;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          dense: true,
                          visualDensity: const VisualDensity(
                            vertical: -4,
                          ),
                          contentPadding: EdgeInsets.zero,
                          value:"NO APLICA",
                          groupValue:item["estado"],
                          activeColor: Colors.grey,
                          title:const Text("No aplica"),
                          onChanged:(v){
                            setState((){
                              item["estado"]=v;
                            });
                          },
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(
                              Icons.comment,
                              color: item["comentario"].toString().trim().isNotEmpty
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            tooltip: item["comentario"].toString().trim().isNotEmpty
                                ? "Comentario registrado"
                                : "Agregar comentario",
                            onPressed: (){
                              _comentario(item);
                            },
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
              height:55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Guardar Checklist"),
                onPressed: guardarChecklist,
              ),
            ),
          ),
        ],
      ),
    );
  }

        void _comentario(Map<String,dynamic> item){

          final controller = TextEditingController(
            text: item["comentario"],
          );

        showDialog(
          context: context,
          builder:(context){
            return AlertDialog(
        title: const Text("Comentario"),
        content: SizedBox(
          width: 800,
          child: TextField(
            controller: controller,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: "Escriba una observación...",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                item["comentario"] = controller.text.trim();
              });
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      );
    },
  );
}
}