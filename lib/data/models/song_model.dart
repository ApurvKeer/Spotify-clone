/// Song Data Model
///
/// This file contains:
/// - Song model class with JSON serialization
/// - Converts between JSON and Song entity
/// - Data transfer object for API responses
/// - Implements fromJson() and toJson() methods
library;
// library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/song.dart';

class SongModel extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String genre;
  final String audioUrl;
  final String coverUrl;
  final String? lyrics;
  final int duration;
  final DateTime createdAt;

  const SongModel({
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

  /// Convert from JSON
  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      genre: json['genre'] as String,
      audioUrl: json['audioUrl'] as String,
      coverUrl: json['coverUrl'] as String,
      lyrics: json['lyrics'] as String?,
      duration: json['duration'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'genre': genre,
      'audioUrl': audioUrl,
      'coverUrl': coverUrl,
      'lyrics': lyrics,
      'duration': duration,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Convert to domain entity
  Song toEntity() {
    return Song(
      id: id,
      title: title,
      artist: artist,
      genre: genre,
      audioUrl: audioUrl,
      coverUrl: coverUrl,
      lyrics: lyrics,
      duration: duration,
      createdAt: createdAt,
    );
  }

  /// Create from domain entity
  factory SongModel.fromEntity(Song song) {
    return SongModel(
      id: song.id,
      title: song.title,
      artist: song.artist,
      genre: song.genre,
      audioUrl: song.audioUrl,
      coverUrl: song.coverUrl,
      lyrics: song.lyrics,
      duration: song.duration,
      createdAt: song.createdAt,
    );
  }

  /// Create a copy with modified fields
  SongModel copyWith({
    String? id,
    String? title,
    String? artist,
    String? genre,
    String? audioUrl,
    String? coverUrl,
    String? lyrics,
    int? duration,
    DateTime? createdAt,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      genre: genre ?? this.genre,
      audioUrl: audioUrl ?? this.audioUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      lyrics: lyrics ?? this.lyrics,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
    );
  }

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
