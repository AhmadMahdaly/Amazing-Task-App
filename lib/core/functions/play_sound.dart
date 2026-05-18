import 'package:audioplayers/audioplayers.dart';
import 'package:s/core/constants.dart';

Future<void> playSound() async {
  final player = AudioPlayer();
  const sound = appSound;
  await player.play(AssetSource(sound));
}
