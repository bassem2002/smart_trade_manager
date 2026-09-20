import 'package:flutter/services.dart';
import 'settings_service.dart';

class AudioService {
  static Future<void> playSuccessSound() async {
    final hasSound = await SettingsService.getSound();
    if (!hasSound) return;

    // Use System Sound (Click) to avoid needing external assets
    await SystemSound.play(SystemSoundType.click);
  }
}
