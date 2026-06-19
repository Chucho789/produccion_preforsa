import 'package:flutter/material.dart';

class ColoraPage extends StatelessWidget {

  const ColoraPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'COLORA CAP',
        ),
      ),

      body: GridView.count(

        padding: const EdgeInsets.all(16),

        crossAxisCount: 2,

        crossAxisSpacing: 16,

        mainAxisSpacing: 16,

        children: [

          _tarjeta(
            context,
            'Enfriador de Lámparas',
            Icons.thermostat,
          ),

          _tarjeta(
            context,
            'Presiones',
            Icons.speed,
          ),

          _tarjeta(
            context,
            'Dimensiones de Cabezales',
            Icons.straighten,
          ),

          _tarjeta(
            context,
            'Temperatura Distribuidor',
            Icons.device_thermostat,
          ),

          _tarjeta(
            context,
            'Cabezales de Tinta',
            Icons.print,
          ),

          _tarjeta(
            context,
            'Modalidad Automático',
            Icons.settings,
          ),

          _tarjeta(
            context,
            'Datos Generales',
            Icons.info,
          ),
        ],
      ),
    );
  }

  Widget _tarjeta(
    BuildContext context,
    String titulo,
    IconData icono,
  ) {

    return Card(

      elevation: 4,

      child: InkWell(

        onTap: () {

        },

        child: Column(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Icon(
              icono,
              size: 48,
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              titulo,
              textAlign:
                  TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}