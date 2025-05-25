// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serpapi_gps_coordinates.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SerpapiGpsCoordinates _$SerpapiGpsCoordinatesFromJson(
        Map<String, dynamic> json) =>
    SerpapiGpsCoordinates(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$SerpapiGpsCoordinatesToJson(
        SerpapiGpsCoordinates instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
