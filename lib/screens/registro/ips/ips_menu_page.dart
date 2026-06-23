import 'package:flutter/material.dart';
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
  return InkWell(
    borderRadius: BorderRadius.circular(20),

    onTap: () {

      String seccion = titulo;

      if (titulo == "Ciclo") {
        seccion = "Ciclo Estándar";
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

    child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,

        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 102, 87, 87).withOpacity(0.50),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Icon(
              icono,
              size: 55,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),

            const SizedBox(height: 20),

            Text(
              titulo,
              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}