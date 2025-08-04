import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/locator/service_locator.dart';
import '../../../core/services/sound_settings_service.dart';

/// Widget for toggling tick sound on/off
class SoundToggleWidget extends StatelessWidget {
  const SoundToggleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final soundSettingsService =
        ServiceLocator.instance.get<ISoundSettingsService>();

    return StreamBuilder<bool>(
      stream: soundSettingsService.tickSoundEnabledStream,
      builder: (context, snapshot) {
        final isEnabled = snapshot.data ?? false;

        return FloatingActionButton(
          heroTag: "sound_toggle",
          backgroundColor:
              isEnabled ? AppColors.soundOnButton : AppColors.soundOffButton,
          onPressed: () => soundSettingsService.toggleTickSound(),
          child: Icon(
            isEnabled ? Icons.volume_up : Icons.volume_off,
            color: AppColors.soundButtonIcon,
          ),
        );
      },
    );
  }
}
