import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Playable top-down open-city prototype. This is a foundation, not a GTA V clone.
class CityGame extends FlameGame with KeyboardEvents, HasCollisionDetection {
  final ValueNotifier<int> cash = ValueNotifier<int>(0);
  final Random _random = Random(7);
  late Player player;
  late Vehicle vehicle;
  bool inCar = false;
  bool _missionActive = false;
  final Set<LogicalKeyboardKey> _keys = {};

  @override
  Color backgroundColor() => const Color(0xFF6E985D);

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.center;
    // Large, tiled city with a road grid and blocks.
    add(RectangleComponent(
      position: Vector2(-1800, -1800),
      size: Vector2(3600, 3600),
      paint: Paint()..color = const Color(0xFF6E985D),
    ));
    for (var i = -8; i <= 8; i++) {
      final p = i * 180.0;
      add(RectangleComponent(
        position: Vector2(-1800, p - 25),
        size: Vector2(3600, 50),
        paint: Paint()..color = const Color(0xFF333B43),
      ));
      add(RectangleComponent(
        position: Vector2(p - 25, -1800),
        size: Vector2(50, 3600),
        paint: Paint()..color = const Color(0xFF333B43),
      ));
      // Road dashes
      for (var k = -8; k <= 8; k++) {
        add(RectangleComponent(
          position: Vector2(k * 180.0 - 2, p - 2),
          size: Vector2(28, 4),
          paint: Paint()..color = const Color(0xFFE8E2C8),
        ));
      }
    }

    // Procedural city blocks: buildings, small parks, and collectibles.
    for (var x = -7; x <= 7; x++) {
      for (var y = -7; y <= 7; y++) {
        if (_random.nextDouble() < .17) {
          add(ParkComponent(position: Vector2(x * 180.0 + 45, y * 180.0 + 45)));
        } else {
          final w = 55 + _random.nextDouble() * 55;
          final h = 55 + _random.nextDouble() * 55;
          add(BuildingComponent(
            position: Vector2(x * 180.0 + 42, y * 180.0 + 42),
            size: Vector2(w, h),
            shade: _random.nextInt(4),
          ));
        }
        if (_random.nextDouble() < .48) {
          add(CashPickup(position: Vector2(x * 180.0 + 110, y * 180.0 + 112), onCollect: () {
            cash.value += 100;
          }));
        }
      }
    }

    player = Player(position: Vector2(30, 30));
    vehicle = Vehicle(position: Vector2(75, 30));
    add(vehicle);
    add(player);
    camera.follow(player, snap: true);
  }

  void toggleVehicle() {
    if (!inCar && player.position.distanceTo(vehicle.position) < 90) {
      inCar = true;
      player.isHidden = true;
      camera.follow(vehicle, snap: true);
    } else if (inCar) {
      inCar = false;
      player.position = vehicle.position + Vector2(65, 0);
      player.isHidden = false;
      camera.follow(player, snap: true);
    }
  }

  void startMission() {
    _missionActive = true;
    overlays.add('mission');
  }

  @override
  void update(double dt) {
    super.update(dt);
    final direction = Vector2.zero();
    if (_keys.contains(LogicalKeyboardKey.keyW) || _keys.contains(LogicalKeyboardKey.arrowUp)) direction.y -= 1;
    if (_keys.contains(LogicalKeyboardKey.keyS) || _keys.contains(LogicalKeyboardKey.arrowDown)) direction.y += 1;
    if (_keys.contains(LogicalKeyboardKey.keyA) || _keys.contains(LogicalKeyboardKey.arrowLeft)) direction.x -= 1;
    if (_keys.contains(LogicalKeyboardKey.keyD) || _keys.contains(LogicalKeyboardKey.arrowRight)) direction.x += 1;
    if (direction.length2 > 0) direction.normalize();
    if (inCar) {
      vehicle.drive(direction, dt);
      player.position = vehicle.position.clone();
    } else {
      player.move(direction, dt);
    }
    if (_missionActive && cash.value >= 500) {
      _missionActive = false;
      overlays.remove('mission');
      cash.value += 500;
    }
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _keys
      ..clear()
      ..addAll(keysPressed);
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyE) toggleVehicle();
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyM) startMission();
    return KeyEventResult.handled;
  }
}

class BuildingComponent extends PositionComponent {
  BuildingComponent({required super.position, required super.size, required int shade})
      : _shade = shade;
  final int _shade;
  static const colors = [
    Color(0xFFB8B0A4), Color(0xFF8FA5B1), Color(0xFFC7B99E), Color(0xFF89968D)
  ];
  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(5)),
      Paint()..color = colors[_shade]);
    canvas.drawRect(Rect.fromLTWH(5, 5, size.x - 10, 8), Paint()..color = Colors.white.withOpacity(.25));
    final windows = Paint()..color = const Color(0xFF4B8096);
    for (double x = 10; x < size.x - 8; x += 18) {
      for (double y = 20; y < size.y - 8; y += 20) {
        canvas.drawRect(Rect.fromLTWH(x, y, 9, 10), windows);
      }
    }
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(4, size.y - 5, size.x - 8, 5), const Radius.circular(2)),
      Paint()..color = const Color(0xFF59636A));
  }
}

class ParkComponent extends PositionComponent {
  ParkComponent({required super.position}) : super(size: Vector2(90, 90));
  @override
  void render(Canvas canvas) {
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(10)),
      Paint()..color = const Color(0xFF4F8249));
    for (final p in [Vector2(20, 24), Vector2(65, 25), Vector2(45, 65)]) {
      canvas.drawCircle(Offset(p.x, p.y), 12, Paint()..color = const Color(0xFF285D36));
      canvas.drawCircle(Offset(p.x - 2, p.y - 3), 7, Paint()..color = const Color(0xFF3B7B43));
    }
  }
}

class Player extends PositionComponent {
  Player({required super.position}) : super(size: Vector2(30, 38), anchor: Anchor.center);
  bool isHidden = false;
  void move(Vector2 direction, double dt) {
    position += direction * (190 * dt);
    if (direction.length2 > 0) angle = atan2(direction.y, direction.x);
  }
  @override
  void render(Canvas canvas) {
    if (isHidden) return;
    canvas.drawOval(Rect.fromLTWH(2, 4, size.x - 4, size.y - 2),
      Paint()..color = const Color(0x55000000));
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(5, 10, 20, 25), const Radius.circular(7)),
      Paint()..color = const Color(0xFF2463D5));
    canvas.drawCircle(Offset(size.x / 2, 8), 7, Paint()..color = const Color(0xFFD6A47B));
    canvas.drawCircle(Offset(size.x / 2 + 2, 7), 7, Paint()..color = const Color(0xFF29252A)..style = PaintingStyle.stroke..strokeWidth = 2);
  }
}

class Vehicle extends PositionComponent {
  Vehicle({required super.position}) : super(size: Vector2(72, 38), anchor: Anchor.center);
  double _speed = 0;
  void drive(Vector2 direction, double dt) {
    if (direction.length2 > 0) {
      _speed = min(360, _speed + 240 * dt);
      angle = atan2(direction.y, direction.x);
      position += direction * _speed * dt;
    } else {
      _speed = max(0, _speed - 180 * dt);
    }
  }
  @override
  void render(Canvas canvas) {
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 4, size.x, size.y - 8), const Radius.circular(8)),
      Paint()..color = const Color(0xFFBE302E));
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(18, 7, 35, 24), const Radius.circular(5)),
      Paint()..color = const Color(0xFF253D4B));
    final tirePaint = Paint()..color = const Color(0xFF16191B);
    canvas.drawRect(const Rect.fromLTWH(10, 0, 14, 7), tirePaint);
    canvas.drawRect(Rect.fromLTWH(10, size.y - 7, 14, 7), tirePaint);
    canvas.drawRect(Rect.fromLTWH(size.x - 24, 0, 14, 7), tirePaint);
    canvas.drawRect(Rect.fromLTWH(size.x - 24, size.y - 7, 14, 7), tirePaint);
    canvas.drawRect(Rect.fromLTWH(size.x - 4, 9, 3, 6), Paint()..color = const Color(0xFFFFE6A6));
    canvas.drawRect(Rect.fromLTWH(size.x - 4, size.y - 15, 3, 6), Paint()..color = const Color(0xFFFFE6A6));
  }
}

class CashPickup extends PositionComponent {
  CashPickup({required super.position, required this.onCollect})
      : super(size: Vector2(24, 24), anchor: Anchor.center);
  final VoidCallback onCollect;
  bool _collected = false;
  @override
  void update(double dt) {
    super.update(dt);
    final game = findGame() as CityGame?;
    if (!_collected && game != null) {
      final target = game.inCar ? game.vehicle.position : game.player.position;
      if (target.distanceTo(position) < 30) {
        _collected = true;
        onCollect();
        removeFromParent();
      }
    }
  }
  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 10, Paint()..color = const Color(0xFFFFC83D));
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 5, Paint()..color = const Color(0xFFFFF1A8));
  }
}
