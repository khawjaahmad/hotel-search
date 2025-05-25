import 'package:json_annotation/json_annotation.dart';

import 'hive_location.dart';

part 'hive_hotel.g.dart';

@JsonSerializable()
class HiveHotel {
  const HiveHotel({
    required this.name,
    required this.location,
    this.description,
  });

  final String name;
  final HiveLocation location;
  final String? description;

  factory HiveHotel.fromJson(Map<String, dynamic> json) =>
      _$HiveHotelFromJson(json);

  Map<String, dynamic> toJson() => _$HiveHotelToJson(this);
}
