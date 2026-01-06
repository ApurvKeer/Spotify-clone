/// Song Data Model (Firestore compatible)
///
/// Handles JSON serialization for Firestore snake_case fields.

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

  /// Convert from JSON (handles both camelCase and snake_case)
  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      genre: json['genre'] as String,
      // Handle both snake_case (Firestore) and camelCase
      audioUrl: (json['audio_url'] ?? json['audioUrl']) as String,
      coverUrl: (json['cover_url'] ?? json['coverUrl']) as String,
      lyrics: json['lyrics'] as String?,
      duration: json['duration'] as int,
      // Handle both snake_case (Firestore) and camelCase
      createdAt: DateTime.parse(
        (json['created_at'] ?? json['createdAt']) as String,
      ),
    );
  }

  /// Convert to JSON (snake_case for Firestore compatibility)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'genre': genre,
      'audio_url': audioUrl,
      'cover_url': coverUrl,
      'lyrics': lyrics,
      'duration': duration,
      'created_at': createdAt.toIso8601String(),
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
