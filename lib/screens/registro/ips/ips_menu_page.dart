import 'package:flutter/material.dart';
import 'ips_datos_generales_page.dart';
import 'ips_variables_page.dart';
import 'ips_seccion_page.dart';
class IpsMenuPage extends StatelessWidget {
  final int maquinaId;
  final String maquinaNombre;

  const IpsMenuPage({
    super.key,
    required this.maquinaId,
    required this.maquinaNombre,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(maquinaNombre),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [
            _modulo(
              context,
              "Datos Generales",
              Icons.thermostat,
            ),

            _modulo(
              context,
              "Ciclo",
              Icons.repeat,
            ),

            _modulo(
              context,
              "Fases",
              Icons.timeline,
            ),

            _modulo(
              context,
              "Tornillo",
              Icons.settings,
            ),

            _modulo(
              context,
              "Temperaturas Tornillo",
              Icons.device_thermostat,
            ),

            _modulo(
              context,
              "Inyector",
              Icons.speed,
            ),

            _modulo(
              context,
              "Hot Runner",
              Icons.local_fire_department,
            ),

            _modulo(
              context,
              "Secador",
              Icons.air,
            ),
          ],
        ),
      ),
    );
  }

  Widget _modulo(
    BuildContext context,
    String titulo,
    IconData icono,
  ) {
    return Card(
      elevation: 6,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),

                  onTap: () {

                    String seccion = titulo;

                    if (titulo == "Ciclo") {
                      seccion = "Ciclo Estándar";
                    }

                    if (titulo == "Tornillo") {
                      seccion = "Tornillo";
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => IpsSeccionPage(
                          maquinaId: maquinaId,
                          maquinaNombre: maquinaNombre,
                          seccion: seccion,
                        ),
                      ),
                    );
                  },

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icono,
              size: 50,
            ),

            const SizedBox(height: 10),

            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}