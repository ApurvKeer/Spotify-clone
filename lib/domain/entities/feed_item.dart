/// Feed Item Model
///
/// Represents a feed entry pointing to a song with priority.

import 'package:equatable/equatable.dart';

class FeedItem extends Equatable {
  final String songId;
  final int priority;
  final DateTime addedAt;

  const FeedItem({
    required this.songId,
    required this.priority,
    required this.addedAt,
  });

  /// Convert from JSON
  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      songId: json['song_id'] as String,
      priority: json['priority'] as int,
      addedAt: DateTime.parse(json['added_at'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'song_id': songId,
      'priority': priority,
      'added_at': addedAt.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  FeedItem copyWith({String? songId, int? priority, DateTime? addedAt}) {
    return FeedItem(
      songId: songId ?? this.songId,
      priority: priority ?? this.priority,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  List<Object?> get props => [songId, priority, addedAt];
}
