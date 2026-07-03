import 'package:flutter/material.dart';
import 'package:produccion_preforsa/screens/checklist/checklist_page.dart';
import 'package:produccion_preforsa/screens/configuracion/configuracion_page.dart';
import 'package:produccion_preforsa/theme/theme_provider.dart';
import 'package:provider/provider.dart';
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

    Consumer<ThemeProvider>(
      builder: (
        context,
        themeProvider,
        _,
      ) {

        return IconButton(

          icon: Icon(
            themeProvider.isDark
                ? Icons.light_mode
                : Icons.dark_mode,
          ),

          tooltip: 'Cambiar tema',

          onPressed: () {

            themeProvider.toggleTheme(
              !themeProvider.isDark,
            );

          },
        );
      },
    ),

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
  elevation: 8,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [

        Row(
          children: [

            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.engineering,
                size: 40,
                color: Colors.deepPurple,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    nombreUsuario,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.deepPurple,
                      ),
                    ),
                    child: Text(
                      rolUsuario,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Text(
                turno,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceAround,
          children: [

            _infoMini(
              Icons.calendar_month,
              DateTime.now()
                  .toString()
                  .substring(0, 10),
            ),

            _infoMini(
              Icons.factory,
              'Preforsa',
            ),

            _infoMini(
              Icons.verified_user,
              rolUsuario,
            ),
          ],
        ),
      ],
    ),
  ),
),

                  const SizedBox(height: 10),

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
                          color: Colors.deepPurple,
                        ),

                        _menuCard(
                          context,
                          icon: Icons.fact_check,
                          titulo: 'Checklist',
                          pagina: const ChecklistPage(),
                          color: Colors.deepPurple,
                        ),

                        _menuCard(
                          context,
                          icon: Icons.history,
                          titulo: 'Historial',
                          pagina: const HistorialPage(),
                          color: Colors.deepPurple,
                        ),

                        _menuCard(
                          context,
                          icon: Icons.bar_chart,
                          titulo: 'Gráficos',
                          pagina: const GraficosPage(),
                          color: Colors.deepPurple,
                        ),

                        _menuCard(
                          context,
                          icon: Icons.picture_as_pdf,
                          titulo: 'Reportes',
                          pagina: const ReportesPage(),
                          color: Colors.deepPurple,
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
                            color: Colors.deepPurple,
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
  required Color color,
}) 

{
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
              size: 55,
              color: color,
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
  Widget _infoMini(
  IconData icon,
  String texto,
) {
  return Column(
    children: [

      Icon(
        icon,
        color: const Color.fromARGB(255, 212, 132, 40),
      ),

      const SizedBox(height: 5),

      Text(
        texto,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}
}