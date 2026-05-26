import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();

  // Phát âm thanh động cơ gầm rú khi bấm START
  static Future<void> playEngineStart() async {
    try {
      await _player.stop();
      // Audio source từ Mixkit CDN (Car Engine Start/Rev)
      await _player.play(UrlSource('https://assets.mixkit.co/active_storage/sfx/2654/2654-84.wav'));
    } catch (e) {
      print("Không thể phát âm thanh động cơ (Có thể do thiết bị/mạng): $e");
    }
  }

  // Phát âm thanh phanh xe cháy đường khi xe cán đích
  static Future<void> playBrakeScreech() async {
    try {
      await _player.stop();
      // Audio source từ Mixkit CDN (Car Brake Screech/Drift)
      await _player.play(UrlSource('https://assets.mixkit.co/active_storage/sfx/2816/2816-84.wav'));
    } catch (e) {
      print("Không thể phát âm thanh phanh (Có thể do thiết bị/mạng): $e");
    }
  }
}
