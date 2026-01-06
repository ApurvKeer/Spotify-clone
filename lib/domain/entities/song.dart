/// Song Entity
///
/// This file contains:
/// - Pure business object representing a Song
/// - Independent of any framework or external library
/// - Contains only business logic properties
/// - No JSON serialization (that's in the model layer)
/// - Used by use cases and presentation layer
library;
// library;

import 'package:equatable/equatable.dart';

class Song extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String genre;
  final String audioUrl;
  final String coverUrl;
  final String? lyrics;
  final int duration;
  final DateTime createdAt;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.genre,
    required this.audioUrl,
    required this.coverUrl,
    this.lyrics,
    required this.duration,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    artist,
    genre,
    audioUrl,
    coverUrl,
    lyrics,
    duration,
    createdAt,
  ];
}
