import 'package:flutter/material.dart';

class IndustrialBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final orangePaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final lightOrangePaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.25)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Línea superior derecha
    Path topPath = Path();

    topPath.moveTo(size.width, 20);

    topPath.quadraticBezierTo(
      size.width - 80,
      0,
      size.width - 180,
      100,
    );

    topPath.quadraticBezierTo(
      size.width - 250,
      160,
      size.width - 320,
      120,
    );

    canvas.drawPath(topPath, orangePaint);

    // Segunda línea paralela
    Path topPath2 = Path();

    topPath2.moveTo(size.width, 50);

    topPath2.quadraticBezierTo(
      size.width - 90,
      30,
      size.width - 190,
      120,
    );

    topPath2.quadraticBezierTo(
      size.width - 260,
      180,
      size.width - 330,
      150,
    );

    canvas.drawPath(topPath2, lightOrangePaint);

    // Línea inferior izquierda
    Path bottomPath = Path();

    bottomPath.moveTo(0, size.height - 50);

    bottomPath.quadraticBezierTo(
      80,
      size.height - 100,
      180,
      size.height - 180,
    );

    bottomPath.quadraticBezierTo(
      250,
      size.height - 240,
      350,
      size.height - 200,
    );

    canvas.drawPath(bottomPath, orangePaint);

    // Segunda línea inferior
    Path bottomPath2 = Path();

    bottomPath2.moveTo(0, size.height - 80);

    bottomPath2.quadraticBezierTo(
      100,
      size.height - 130,
      200,
      size.height - 220,
    );

    bottomPath2.quadraticBezierTo(
      280,
      size.height - 280,
      380,
      size.height - 240,
    );

    canvas.drawPath(bottomPath2, lightOrangePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}