# City Legend — Dart / Flutter open-city starter

This is a **playable top-down 2D prototype**, not a complete GTA V recreation and not a 3D game yet. It provides a procedural city grid, buildings, parks, a player, a drivable vehicle, cash pickups, a HUD, and a starter mission trigger.

## Run it
1. Install Flutter SDK: https://docs.flutter.dev/get-started/install
2. Extract the project ZIP and open a terminal in this folder.
3. Run `flutter pub get`
4. Run `flutter run -d chrome` for web, or `flutter run` for a connected device.
5. Controls: WASD / arrow keys to move; E to enter/exit the nearby car; M to show the mission prompt.

## Important next steps for a true 3D open-world game
A production-scale 3D game requires a real 3D renderer/engine, authored or licensed 3D assets, animation rigs, physics, traffic/pedestrian AI, missions, audio, save data, optimization, and extensive testing. Dart/Flutter alone does not recreate GTA V's engine or assets. This starter is a foundation for gameplay systems; for high-end 3D, consider Unreal Engine or Unity, with Dart used only where an appropriate integration exists.
