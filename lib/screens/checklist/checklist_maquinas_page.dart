import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'checklist_form_page.dart';

class ChecklistMaquinasPage extends StatefulWidget {
  final int tipoId;
  final String titulo;

  const ChecklistMaquinasPage({
    super.key,
    required this.tipoId,
    required this.titulo,
  });

  @override
  State<ChecklistMaquinasPage> createState() => _ChecklistMaquinasPageState();
}

class _ChecklistMaquinasPageState extends State<ChecklistMaquinasPage> {
  final supabase = Supabase.instance.client;

  final Map<String, String> imagenesMaquinas = {
    'IPS-1': 'assets/maquinas/IPS400B.jpeg',
    'IPS-2': 'assets/maquinas/IPS400A.jpeg',
    'CCM32': 'assets/maquinas/TAPAS1.jpeg',
    'COLORA CAP': 'assets/maquinas/IM-01.jpg',
    'HXM258': 'assets/maquinas/IY-07.jpg',
    'HXM585': 'assets/maquinas/IY-05.jpg',
    'YIZUMI': 'assets/maquinas/IY-08.jpg',
    'VJ1': 'assets/maquinas/SOPLADO.jpg',
    'VJ2': 'assets/maquinas/SD-02.jpg',
    'VJ3': 'assets/maquinas/SD-03.jpg',
  };

  List maquinas = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarMaquinas();
  }

Future<void> cargarMaquinas() async {
  final data = await supabase
      .from("checklist_maquinas")
      .select("""
        maquinas(
          id,
          nombre
        )
      """)
      .eq("tipo_id", widget.tipoId)
      .eq("activo", true);

  setState(() {
    maquinas = data
        .map((e) => e["maquinas"])
        .where((e) => e != null)
        .toList();

    cargando = false;
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(15),
              child: GridView.builder(
                itemCount: maquinas.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: .95,
                ),
                itemBuilder: (context, index) {
                  final maquina = maquinas[index];

                  return InkWell(
                    onTap: () {
                      print("Abriendo formulario...");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChecklistFormPage(
                            maquinaId: maquina["id"],
                            maquinaNombre: maquina["nombre"],
                            tipoId: widget.tipoId,
                            titulo: widget.titulo,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(15),
                              ),
                              child: Image.asset(
                                imagenesMaquinas[maquina["nombre"]] ??
                                    "assets/maquinas/IPS400B.jpeg",
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              maquina["nombre"],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}