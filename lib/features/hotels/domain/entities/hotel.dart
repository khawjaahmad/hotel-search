import 'package:equatable/equatable.dart';

import 'entities.dart';

class Hotel extends Equatable {
  const Hotel({
    required this.name,
    required this.location,
    this.description,
  });

  final String name;
  final Location location;
  final String? description;

  @override
  List<Object?> get props => [name, location, description];
}
