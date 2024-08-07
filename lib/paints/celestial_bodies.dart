import 'package:flutter/material.dart';

class CelestialBody {
  double x, y, mass, radius;
  Color color;

  CelestialBody({
    required this.x,
    required this.y,
    required this.mass,
    required this.radius,
    this.color = Colors.yellow,
  });
}

class Star extends CelestialBody {
  bool isSelected = false;
  Color get currentColor => isSelected ? Colors.orangeAccent : Colors.orange;

  Star({
    required super.x,
    required super.y,
    required super.mass,
    required super.radius,
  }) : super(color: Colors.orange);
}

class Planet extends CelestialBody {
  double vx, vy;
  List<Offset> trail = [];

  Planet({
    required super.x,
    required super.y,
    required this.vx,
    required this.vy,
    required super.mass,
    required super.radius,
    required super.color,
  });
}
