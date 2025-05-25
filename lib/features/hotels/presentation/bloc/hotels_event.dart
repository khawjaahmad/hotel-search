part of 'hotels_bloc.dart';

sealed class HotelsEvent extends Equatable {
  const HotelsEvent();

  @override
  List<Object?> get props => [];
}

class HotelsSearchUpdateEvent extends HotelsEvent {
  const HotelsSearchUpdateEvent({
    required this.params,
  });

  final SearchParams params;

  @override
  List<Object?> get props => [params];
}

class HotelsFetchNextPageEvent extends HotelsEvent {
  const HotelsFetchNextPageEvent();
}

class HotelsFetchSuccessEvent extends HotelsEvent {
  const HotelsFetchSuccessEvent({
    required this.response,
  });

  final PaginatedResponse<Hotel> response;

  @override
  List<Object?> get props => [response];
}

class HotelsFetchFailureEvent extends HotelsEvent {
  const HotelsFetchFailureEvent({
    required this.error,
  });

  final Exception error;

  @override
  List<Object?> get props => [error];
}
