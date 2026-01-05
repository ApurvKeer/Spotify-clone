class Song {
  final int? id;
  final String title;
  final String artist;
  final String? album;
  final String duration;
  final String? audioPath;
  final String? albumArt;
  final String? genre;
  final int year;
  final String? playlistId;

  const Song({
    this.id,
    required this.title,
    required this.artist,
    this.album,
    required this.duration,
    this.audioPath,
    this.albumArt,
    this.genre,
    this.year = 0,
    this.playlistId,
  });

  // Convert Song to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'duration': duration,
      'audioPath': audioPath,
      'albumArt': albumArt,
      'genre': genre,
      'year': year,
      'playlistId': playlistId,
    };
  }

  // Create Song from Map
  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'] as int?,
      title: map['title'] as String,
      artist: map['artist'] as String,
      album: map['album'] as String?,
      duration: map['duration'] as String,
      audioPath: map['audioPath'] as String?,
      albumArt: map['albumArt'] as String?,
      genre: map['genre'] as String?,
      year: map['year'] as int? ?? 0,
      playlistId: map['playlistId'] as String?,
    );
  }

  // Copy with method for easy updates
  Song copyWith({
    int? id,
    String? title,
    String? artist,
    String? album,
    String? duration,
    String? audioPath,
    String? albumArt,
    String? genre,
    int? year,
    String? playlistId,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      audioPath: audioPath ?? this.audioPath,
      albumArt: albumArt ?? this.albumArt,
      genre: genre ?? this.genre,
      year: year ?? this.year,
      playlistId: playlistId ?? this.playlistId,
    );
  }
}

class Playlist {
  final String id;
  final String name;
  final String? description;
  final String? coverImage;

  const Playlist({
    required this.id,
    required this.name,
    this.description,
    this.coverImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coverImage': coverImage,
    };
  }

  factory Playlist.fromMap(Map<String, dynamic> map) {
    return Playlist(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      coverImage: map['coverImage'] as String?,
    );
  }
}
