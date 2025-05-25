import 'package:json_annotation/json_annotation.dart';

part 'serpapi_pagination.g.dart';

@JsonSerializable()
class SerpapiPagination {
  const SerpapiPagination({
    required this.nextPageToken,
  });

  @JsonKey(name: 'next_page_token')
  final String? nextPageToken;

  factory SerpapiPagination.fromJson(Map<String, dynamic> json) =>
      _$SerpapiPaginationFromJson(json);

  Map<String, dynamic> toJson() => _$SerpapiPaginationToJson(this);
}
