import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../historial/historial_page.dart';  
import '../registro/registro_page.dart';
import '../graficos/graficos_page.dart';
import '../reportes/reportes_page.dart';
import '../admin/admin_page.dart';
import '../login/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;

  String nombreUsuario = "Usuario";
  String rolUsuario = "Operador";

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarPerfil();
  }

  Future<void> cargarPerfil() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) return;

      final perfil = await supabase
          .from('perfiles')
          .select()
          .eq('id', user.id)
          .single();

      setState(() {
        nombreUsuario = perfil['nombre'];
        rolUsuario = perfil['rol'];
        cargando = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        cargando = false;
      });
    }
  }

  Future<void> cerrarSesion() async {
    await supabase.auth.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  String obtenerTurno() {
    final hora = DateTime.now().hour;

    if (hora >= 7 && hora < 15) {
      return "Turno 1";
    }

    if (hora >= 15 && hora < 23) {
      return "Turno 2";
    }

    return "Turno 3";
  }

  @override
  Widget build(BuildContext context) {
    final turno = obtenerTurno();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Producción Preforsa"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: cerrarSesion,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: cargando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 35,
                            child: Icon(
                              Icons.person,
                              size: 35,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            nombreUsuario,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Chip(
                            label: Text(rolUsuario),
                          ),

                          const SizedBox(height: 15),

                          Text(
                            turno,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            DateTime.now()
                                .toString()
                                .substring(0, 10),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      children: [
                        _menuCard(
                          context,
                          icon: Icons.edit_note,
                          titulo: 'Registro',
                          pagina: const RegistroPage(),
                        ),

                        _menuCard(
                          context,
                          icon: Icons.history,
                          titulo: 'Historial',
                          pagina: const HistorialPage(),
                        ),

                        _menuCard(
                          context,
                          icon: Icons.bar_chart,
                          titulo: 'Gráficos',
                          pagina: const GraficosPage(),
                        ),

                        _menuCard(
                          context,
                          icon: Icons.picture_as_pdf,
                          titulo: 'Reportes',
                          pagina: const ReportesPage(),
                        ),

                        if (rolUsuario.toLowerCase() ==
                                'administrador' ||
                            rolUsuario.toLowerCase() ==
                                'supervisor')
                          _menuCard(
                            context,
                            icon: Icons.settings,
                            titulo: 'Administración',
                            pagina: const AdminPage(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _menuCard(
    BuildContext context, {
    required IconData icon,
    required String titulo,
    required Widget pagina,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => pagina,
          ),
        );
      },
      child: Card(
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
            ),

            const SizedBox(height: 10),

            Text(
              titulo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}