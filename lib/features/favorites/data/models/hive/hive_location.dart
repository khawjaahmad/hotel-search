import 'package:json_annotation/json_annotation.dart';

part 'hive_location.g.dart';

@JsonSerializable()
class HiveLocation {
  const HiveLocation({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  factory HiveLocation.fromJson(Map<String, dynamic> json) =>
      _$HiveLocationFromJson(json);

  Map<String, dynamic> toJson() => _$HiveLocationToJson(this);
}
