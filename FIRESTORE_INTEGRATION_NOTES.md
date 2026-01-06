/// Firestore Integration Summary
///
/// STEP 1 - Data Models ✓
/// - SongModel (song_model_firestore.dart) - handles snake_case from Firestore
/// - GenreModel (genre_model_firestore.dart) - handles snake_case from Firestore
/// - FeedItemModel (feed_item_model.dart) - Firestore feed items
///
/// STEP 2 - Remote Data Sources ✓
/// - GenreRemoteDataSource (genre_remote_datasource.dart)
/// - SongRemoteDataSource (song_remote_datasource.dart)
/// - FeedRemoteDataSource (feed_remote_datasource.dart)
///
/// STEP 3 - Domain Interfaces ✓
/// - GenreRepository (domain/repositories/genre_repository.dart)
/// - SongRepository (domain/repositories/song_repository.dart)
/// - FeedRepository (domain/repositories/feed_repository.dart)
///
/// STEP 4 - Repositories ✓
/// - GenreRepositoryImpl (data/repositories/genre_repository_impl.dart)
/// - SongRepositoryImpl (data/repositories/song_repository_impl_firestore.dart)
/// - FeedRepositoryImpl (data/repositories/feed_repository_impl.dart)
///
/// STEP 5 - Riverpod Providers ✓
/// - firestore_providers.dart (all data and repository providers)
///
/// STEP 6 - Firestore Config ✓
/// - FirestoreConfig (core/services/firestore_config.dart) - offline persistence
///
/// Notes:
/// - All Firestore field names are snake_case (audio_url, cover_url, etc)
/// - Models handle both snake_case and camelCase for compatibility
/// - Offline persistence enabled for better performance
/// - No writes to Firestore (read-only)
/// - Clean architecture with clear separation of concerns
