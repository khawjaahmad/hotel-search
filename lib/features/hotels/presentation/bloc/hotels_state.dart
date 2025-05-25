part of 'hotels_bloc.dart';

class HotelsState extends Equatable {
  const HotelsState({
    this.loading = false,
    required this.params,
    this.items = const [],
    this.nextPageToken,
    this.error,
    this.hasReachedMax = false,
  });

  final bool loading;
  final SearchParams params;
  final List<Hotel> items;
  final String? nextPageToken;
  final dynamic error;
  final bool hasReachedMax;

  bool get hasError => error != null;

  @override
  List<Object?> get props {
    return [
      loading,
      params,
      items,
      nextPageToken,
      error,
      hasReachedMax,
    ];
  }

  HotelsState copyWith({
    bool? loading,
    SearchParams? params,
    List<Hotel>? items,
    String? nextPageToken,
    bool setNextPageToken = false,
    bool? hasReachedMax,
    dynamic error,
    bool setError = false,
  }) {
    return HotelsState(
      loading: loading ?? this.loading,
      params: params ?? this.params,
      items: items ?? this.items,
      nextPageToken: setNextPageToken
          ? nextPageToken
          : nextPageToken ?? this.nextPageToken,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      error: setError ? error : error ?? this.error,
    );
  }
}
