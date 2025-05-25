import 'package:equatable/equatable.dart';

class SearchParams extends Equatable {
  SearchParams({
    required this.query,
    required this.checkInDate,
    required this.checkOutDate,
  }) {
    assert(
      checkInDate.compareTo(checkOutDate) <= 0,
      'checkInDate: $checkInDate should be before checkOutDate: $checkOutDate',
    );
  }

  final String query;
  final DateTime checkInDate;
  final DateTime checkOutDate;

  @override
  List<Object?> get props => [query, checkInDate, checkOutDate];

  SearchParams copyWith({
    String? query,
    DateTime? checkInDate,
    DateTime? checkOutDate,
  }) {
    return SearchParams(
      query: query ?? this.query,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
    );
  }
}
