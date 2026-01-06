/// Genre Entity
///
/// This file contains:
/// - Pure business object representing a Genre
/// - Independent of any framework or external library
/// - Contains only business logic properties
/// - No JSON serialization (that's in the model layer)
/// - Used by use cases and presentation layer
library;
// library;

import 'package:equatable/equatable.dart';

class Genre extends Equatable {
  final String id;
  final String name;
  final String coverUrl;

  const Genre({required this.id, required this.name, required this.coverUrl});

  @override
  List<Object?> get props => [id, name, coverUrl];
}
