/// Feed Item Data Model
///
/// Data transfer object for feed items from Firestore.

import 'package:equatable/equatable.dart';
import '../../domain/entities/feed_item.dart';

class FeedItemModel extends Equatable {
  final String songId;
  final int priority;
  final DateTime addedAt;

  const FeedItemModel({
    required this.songId,
    required this.priority,
    required this.addedAt,
  });

  /// Convert from JSON
  factory FeedItemModel.fromJson(Map<String, dynamic> json) {
    final songId = json['song_id'];
    final priority = json['priority'];
    final addedAt = json['added_at'];

    return FeedItemModel(
      songId: songId is String ? songId : '',
      priority: priority is int ? priority : 0,
      addedAt: addedAt is String ? DateTime.parse(addedAt) : DateTime.now(),
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

  /// Convert to domain entity
  FeedItem toEntity() {
    return FeedItem(songId: songId, priority: priority, addedAt: addedAt);
  }

  /// Create from domain entity
  factory FeedItemModel.fromEntity(FeedItem item) {
    return FeedItemModel(
      songId: item.songId,
      priority: item.priority,
      addedAt: item.addedAt,
    );
  }

  /// Create a copy with modified fields
  FeedItemModel copyWith({String? songId, int? priority, DateTime? addedAt}) {
    return FeedItemModel(
      songId: songId ?? this.songId,
      priority: priority ?? this.priority,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  List<Object?> get props => [songId, priority, addedAt];
}
