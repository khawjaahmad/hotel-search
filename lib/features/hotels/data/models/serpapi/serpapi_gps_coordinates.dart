import 'package:json_annotation/json_annotation.dart';

part 'serpapi_gps_coordinates.g.dart';

@JsonSerializable()
class SerpapiGpsCoordinates {
  const SerpapiGpsCoordinates({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  factory SerpapiGpsCoordinates.fromJson(Map<String, dynamic> json) =>
      _$SerpapiGpsCoordinatesFromJson(json);

  Map<String, dynamic> toJson() => _$SerpapiGpsCoordinatesToJson(this);
}
