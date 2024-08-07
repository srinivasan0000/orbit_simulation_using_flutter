import 'package:flutter/material.dart';

import 'celestial_bodies.dart';

class OrbitPainter extends CustomPainter {
  final Star star;
  final List<Planet> planets;
  final bool showTrails;
  final Offset? dragStart;
  final Offset? dragEnd;
  final List<Offset> forecastTrajectory;

  OrbitPainter({
    required this.star,
    required this.planets,
    required this.showTrails,
    this.dragStart,
    this.dragEnd,
    required this.forecastTrajectory,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = star.currentColor;

    canvas.drawCircle(Offset(star.x, star.y), star.radius, paint);

    if (star.isSelected) {
      paint
        ..color = Colors.orangeAccent.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(star.x, star.y), star.radius + 5, paint);

      paint
        ..color = Colors.orangeAccent
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(star.x, star.y - star.radius - 5), 3, paint);
      canvas.drawCircle(Offset(star.x, star.y + star.radius + 5), 3, paint);
      canvas.drawCircle(Offset(star.x - star.radius - 5, star.y), 3, paint);
      canvas.drawCircle(Offset(star.x + star.radius + 5, star.y), 3, paint);
    }

    for (var planet in planets) {
      if (showTrails) {
        paint.color = planet.color.withOpacity(1);
        for (int i = 0; i < planet.trail.length - 1; i++) {
          canvas.drawLine(planet.trail[i], planet.trail[i + 1], paint);
        }
      }

      paint.color = planet.color;
      canvas.drawCircle(Offset(planet.x, planet.y), planet.radius, paint);
    }

    if (forecastTrajectory.isNotEmpty) {
      paint
        ..color = Colors.green.withOpacity(0.5)
        ..strokeWidth = 2;
      for (int i = 0; i < forecastTrajectory.length - 1; i++) {
        canvas.drawLine(forecastTrajectory[i], forecastTrajectory[i + 1], paint);
      }
    }

    if (dragStart != null && dragEnd != null) {
      paint
        ..color = Colors.red
        ..strokeWidth = 2;
      canvas.drawLine(dragStart!, dragEnd!, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
