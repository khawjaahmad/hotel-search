// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serpapi_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SerpapiResponse _$SerpapiResponseFromJson(Map<String, dynamic> json) =>
    SerpapiResponse(
      properties: (json['properties'] as List<dynamic>)
          .map((e) => SerpapiProperty.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: SerpapiPagination.fromJson(
          json['serpapi_pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SerpapiResponseToJson(SerpapiResponse instance) =>
    <String, dynamic>{
      'properties': instance.properties,
      'serpapi_pagination': instance.pagination,
    };
