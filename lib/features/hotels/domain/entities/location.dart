import 'package:equatable/equatable.dart';

class Location extends Equatable {
  const Location({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  String get decimalDegrees => '$latitude,$longitude';

  @override
  List<Object?> get props => [latitude, longitude];
}
