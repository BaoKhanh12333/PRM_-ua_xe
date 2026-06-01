import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();

  // Phát âm thanh động cơ gầm rú khi bấm START
  static Future<void> playEngineStart() async {
    try {
      await _player.stop();
      // Audio source từ Mixkit CDN (Car Engine Start/Rev)
      await _player.play(AssetSource('audio/engine.mp3'));
    } catch (e) {
      print("Không thể phát âm thanh động cơ (Có thể do thiết bị/mạng): $e");
    }
  }
static Future<void> playWinSound() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/win.mp3'));
    } catch (e) {
      print("Không thể phát âm thanh chiến thắng: $e");
    }
  }

  // Phát âm thanh thua cược (Sad trombone)
  static Future<void> playLoseSound() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/lose.mp3'));
    } catch (e) {
      print("Không thể phát âm thanh thua cược: $e");
    }
  }
  // Phát âm thanh phanh xe cháy đường khi xe cán đích

}
