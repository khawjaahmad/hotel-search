// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HiveLocation _$HiveLocationFromJson(Map<String, dynamic> json) => HiveLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$HiveLocationToJson(HiveLocation instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
