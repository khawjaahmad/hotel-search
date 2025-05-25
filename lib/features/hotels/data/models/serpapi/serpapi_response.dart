import 'package:json_annotation/json_annotation.dart';

import 'serpapi_property.dart';
import 'serpapi_pagination.dart';

part 'serpapi_response.g.dart';

@JsonSerializable()
class SerpapiResponse {
  const SerpapiResponse({
    required this.properties,
    required this.pagination,
  });

  final List<SerpapiProperty> properties;

  @JsonKey(name: 'serpapi_pagination')
  final SerpapiPagination pagination;

  factory SerpapiResponse.fromJson(Map<String, dynamic> json) =>
      _$SerpapiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SerpapiResponseToJson(this);
}
