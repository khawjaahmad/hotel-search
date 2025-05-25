// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serpapi_property.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SerpapiProperty _$SerpapiPropertyFromJson(Map<String, dynamic> json) =>
    SerpapiProperty(
      name: json['name'] as String,
      description: json['description'] as String?,
      gpsCoordinates: SerpapiGpsCoordinates.fromJson(
          json['gps_coordinates'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SerpapiPropertyToJson(SerpapiProperty instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'gps_coordinates': instance.gpsCoordinates,
    };
