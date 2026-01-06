/// Genre Data Model (Firestore compatible)
///
/// Handles JSON serialization for Firestore snake_case fields.

import 'package:equatable/equatable.dart';
import '../../domain/entities/genre.dart';

class GenreModel extends Equatable {
  final String id;
  final String name;
  final String coverUrl;

  const GenreModel({
    required this.id,
    required this.name,
    required this.coverUrl,
  });

  /// Convert from JSON (handles both camelCase and snake_case)
  factory GenreModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final coverUrl = json['cover_url'] ?? json['coverUrl'];

    return GenreModel(
      id: id is String ? id : '',
      name: name is String ? name : '',
      coverUrl: coverUrl is String ? coverUrl : '',
    );
  }

  /// Convert to JSON (snake_case for Firestore compatibility)
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'cover_url': coverUrl};
  }

  /// Convert to domain entity
  Genre toEntity() {
    return Genre(id: id, name: name, coverUrl: coverUrl);
  }

  /// Create from domain entity
  factory GenreModel.fromEntity(Genre genre) {
    return GenreModel(id: genre.id, name: genre.name, coverUrl: genre.coverUrl);
  }

  /// Create a copy with modified fields
  GenreModel copyWith({String? id, String? name, String? coverUrl}) {
    return GenreModel(
      id: id ?? this.id,
      name: name ?? this.name,
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }

  @override
  List<Object?> get props => [id, name, coverUrl];
}
