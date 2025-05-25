// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_hotel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HiveHotel _$HiveHotelFromJson(Map<String, dynamic> json) => HiveHotel(
      name: json['name'] as String,
      location: HiveLocation.fromJson(json['location'] as Map<String, dynamic>),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$HiveHotelToJson(HiveHotel instance) => <String, dynamic>{
      'name': instance.name,
      'location': instance.location,
      'description': instance.description,
    };
