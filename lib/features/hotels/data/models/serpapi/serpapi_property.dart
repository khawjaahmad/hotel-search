import 'package:json_annotation/json_annotation.dart';

import 'serpapi_gps_coordinates.dart';

part 'serpapi_property.g.dart';

@JsonSerializable()
class SerpapiProperty {
  const SerpapiProperty({
    required this.name,
    required this.description,
    required this.gpsCoordinates,
  });

  final String name;
  final String? description;

  @JsonKey(name: 'gps_coordinates')
  final SerpapiGpsCoordinates gpsCoordinates;

  factory SerpapiProperty.fromJson(Map<String, dynamic> json) =>
      _$SerpapiPropertyFromJson(json);

  Map<String, dynamic> toJson() => _$SerpapiPropertyToJson(this);
}
