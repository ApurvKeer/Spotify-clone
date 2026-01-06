/// Genre Data Model
///
/// This file contains:
/// - Genre model class with JSON serialization
/// - Converts between JSON and Genre entity
/// - Data transfer object for API responses
/// - Implements fromJson() and toJson() methods
library;
// library;

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

  /// Convert from JSON
  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(
      id: json['id'] as String,
      name: json['name'] as String,
      coverUrl: json['coverUrl'] as String,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'coverUrl': coverUrl};
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
