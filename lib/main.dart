import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'city_game.dart';

void main() => runApp(const CityLegendApp());

class CityLegendApp extends StatelessWidget {
  const CityLegendApp({super.key});

  @override
  Widget build(BuildContext context) {
    final game = CityGame();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'City Legend',
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        body: Stack(
          children: [
            GameWidget<CityGame>(game: game),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ValueListenableBuilder<int>(
                    valueListenable: game.cash,
                    builder: (_, cash, __) => DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xCC101820),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Text('CITY LEGEND   •   \$${cash}   •   ${game.inCar ? "DRIVING" : "ON FOOT"}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(left: 12, bottom: 12, child: _ControlsHint()),
            Positioned(
              right: 12, bottom: 12,
              child: Column(
                children: [
                  _ActionButton(label: 'E  سيارة', onPressed: () => game.toggleVehicle()),
                  const SizedBox(height: 8),
                  _ActionButton(label: 'مهمة', onPressed: () => game.startMission()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlsHint extends StatelessWidget {
  const _ControlsHint();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: const Color(0xCC101820), borderRadius: BorderRadius.circular(12)),
    child: const Text('حرّك اللاعب: WASD / الأسهم\\nاجمع النقاط الذهبية وجرّب السيارة', style: TextStyle(fontSize: 12)),
  );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF187A73), foregroundColor: Colors.white),
    child: Text(label),
  );
}