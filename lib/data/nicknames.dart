import 'dart:math';

class Nicknames {
  static const _options = [
    'GrooveGuru',
    'BeatBuddy',
    'RhythmRider',
    'MelodyMaker',
    'BassBoss',
    'TuneTrekker',
    'VibeSeeker',
    'SoundSage',
    'LyricLover',
    'WaveWalker',
  ];

  static String random() => _options[Random().nextInt(_options.length)];
}
