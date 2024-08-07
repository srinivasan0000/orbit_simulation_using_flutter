import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'paints/celestial_bodies.dart';
import 'paints/orbitor.dart';

class GravityOrbitSimulation extends StatefulWidget {
  const GravityOrbitSimulation({super.key});

  @override
  State<GravityOrbitSimulation> createState() => _GravityOrbitSimulationState();
}

class _GravityOrbitSimulationState extends State<GravityOrbitSimulation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Planet> _planets = [];
  late Star _star;
  bool _isPlaying = false;
  double _starMass = 1000;
  double _simulationSpeed = 1.0;
  bool _showTrails = true;
  bool _enableSuction = false;
  Offset? _dragStart;
  Offset? _dragEnd;
  List<Offset> _forecastTrajectory = [];
  bool _isMovingStar = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..addListener(_updateSimulation);

    _star = Star(x: 200, y: 200, mass: _starMass, radius: 20);
  }

  void _updateSimulation() {
    if (_isPlaying) {
      setState(() {
        _updatePositions();
      });
    }
  }

  void _addPlanet(double x, double y, double vx, double vy) {
    setState(() {
      _planets.add(Planet(
        x: x,
        y: y,
        vx: vx,
        vy: vy,
        mass: 1,
        radius: 5,
        color: Colors.primaries[math.Random().nextInt(Colors.primaries.length)],
      ));
    });
  }

  List<Offset> _calculateForecastTrajectory(Offset start, Offset end) {
    List<Offset> trajectory = [];
    double vx = (start.dx - end.dx) / 20;
    double vy = (start.dy - end.dy) / 20;
    double x = end.dx;
    double y = end.dy;

    for (int i = 0; i < 100; i++) {
      trajectory.add(Offset(x, y));

      double dx = _star.x - x;
      double dy = _star.y - y;
      double distanceSquared = dx * dx + dy * dy;
      double distance = math.sqrt(distanceSquared);
      double force = 0.1 * _star.mass / distanceSquared;
      double ax = force * dx / distance;
      double ay = force * dy / distance;

      vx += ax * _simulationSpeed;
      vy += ay * _simulationSpeed;

      x += vx * _simulationSpeed;
      y += vy * _simulationSpeed;

      if (distance < _star.radius) break;
    }

    return trajectory;
  }

  void _updatePositions() {
    List<Planet> planetsToRemove = [];
    for (var planet in _planets) {
      double dx = _star.x - planet.x;
      double dy = _star.y - planet.y;
      double distanceSquared = dx * dx + dy * dy;
      double distance = math.sqrt(distanceSquared);

      double force = 0.1 * _star.mass * planet.mass / distanceSquared;
      double acceleration = force / planet.mass;

      planet.vx += acceleration * dx / distance * _simulationSpeed;
      planet.vy += acceleration * dy / distance * _simulationSpeed;

      planet.x += planet.vx * _simulationSpeed;
      planet.y += planet.vy * _simulationSpeed;

      if (distance < _star.radius + planet.radius) {
        planetsToRemove.add(planet);
        _flashStar();
      } else if (_enableSuction && distance < _star.radius * 1.5) {
        planetsToRemove.add(planet);
      }

      if (_showTrails) {
        planet.trail.add(Offset(planet.x, planet.y));
        if (planet.trail.length > 100) {
          planet.trail.removeAt(0);
        }
      }
    }

    setState(() {
      _planets.removeWhere((planet) => planetsToRemove.contains(planet));
    });
  }

  void _flashStar() {
    setState(() {
      _star.color = Colors.red;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _star.color = Colors.orange;
      });
    });
  }

  void _toggleStarSelection(bool selected) {
    setState(() {
      HapticFeedback.vibrate();
      _star.isSelected = selected;
      _isMovingStar = selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gravity and Orbits Simulation')),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onPanStart: (details) {
                if (_isMovingStar) {
                  setState(() {
                    _star.x = details.localPosition.dx;
                    _star.y = details.localPosition.dy;
                  });
                } else {
                  setState(() {
                    _dragStart = details.localPosition;
                    _dragEnd = details.localPosition;
                    _forecastTrajectory.clear();
                  });
                }
              },
              onPanUpdate: (details) {
                if (_isMovingStar) {
                  setState(() {
                    _star.x = details.localPosition.dx;
                    _star.y = details.localPosition.dy;
                  });
                } else {
                  setState(() {
                    _dragEnd = details.localPosition;
                    _forecastTrajectory = _calculateForecastTrajectory(_dragStart!, _dragEnd!);
                  });
                }
              },
              onPanEnd: (details) {
                if (_isMovingStar) {
                  _toggleStarSelection(false);
                } else if (_dragStart != null && _dragEnd != null) {
                  double vx = (_dragStart!.dx - _dragEnd!.dx) / 20;
                  double vy = (_dragStart!.dy - _dragEnd!.dy) / 20;
                  _addPlanet(_dragEnd!.dx, _dragEnd!.dy, vx, vy);
                }
                setState(() {
                  _dragStart = null;
                  _dragEnd = null;
                  _forecastTrajectory.clear();
                });
              },
              onLongPress: () {
                _toggleStarSelection(true);
              },
              child: CustomPaint(
                painter: OrbitPainter(
                  star: _star,
                  planets: _planets,
                  showTrails: _showTrails,
                  dragStart: _dragStart,
                  dragEnd: _dragEnd,
                  forecastTrajectory: _forecastTrajectory,
                ),
                size: Size.infinite,
              ),
            ),
          ),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () {
                  setState(() {
                    _isPlaying = !_isPlaying;
                    if (_isPlaying) {
                      _controller.repeat();
                    } else {
                      _controller.stop();
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() => _planets.clear()),
              ),
            ],
          ),
          Row(
            children: [
              const Text('Star Mass:', style: TextStyle(color: Colors.white70)),
              Expanded(
                child: Slider(
                  value: _starMass,
                  min: 100,
                  max: 5000,
                  onChanged: (value) => setState(() {
                    _starMass = value;
                    _star.mass = value;
                  }),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text('Simulation Speed:', style: TextStyle(color: Colors.white70)),
              Expanded(
                child: Slider(
                  value: _simulationSpeed,
                  min: 0.1,
                  max: 5.0,
                  onChanged: (value) => setState(() => _simulationSpeed = value),
                ),
              ),
            ],
          ),
          CheckboxListTile(
            title: const Text('Show Trails', style: TextStyle(color: Colors.white70)),
            value: _showTrails,
            onChanged: (value) => setState(() => _showTrails = value!),
          ),
          CheckboxListTile(
            title: const Text('Enable Suction', style: TextStyle(color: Colors.white70)),
            value: _enableSuction,
            onChanged: (value) => setState(() => _enableSuction = value!),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
