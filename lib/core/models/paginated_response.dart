import 'package:equatable/equatable.dart';

class PaginatedResponse<T> extends Equatable {
  const PaginatedResponse({
    required this.items,
    required this.nextPageToken,
  });

  final List<T> items;
  final String? nextPageToken;

  @override
  List<Object?> get props => [items, nextPageToken];
}
