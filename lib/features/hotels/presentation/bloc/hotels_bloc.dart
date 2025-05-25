import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:hotel_booking/core/models/models.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';
import 'package:hotel_booking/features/hotels/domain/usecases/usecases.dart';

part 'hotels_event.dart';
part 'hotels_state.dart';

EventTransformer<Event> debounce<Event>() {
  return (events, mapper) =>
      events.debounce(Duration(milliseconds: 500)).switchMap(mapper);
}

class HotelsBloc extends Bloc<HotelsEvent, HotelsState> {
  final FetchHotelsUseCase _fetchHotelsUseCase;

  HotelsBloc({
    required FetchHotelsUseCase fetchHotelsUseCase,
  })  : _fetchHotelsUseCase = fetchHotelsUseCase,
        super(
          HotelsState(
            params: SearchParams(
              query: '',
              checkInDate: DateTime.now(),
              checkOutDate: DateTime.now().add(Duration(days: 1)),
            ),
          ),
        ) {
    on<HotelsSearchUpdateEvent>(_updateSearch, transformer: debounce());
    on<HotelsFetchNextPageEvent>(_fetchNextPage, transformer: droppable());
    on<HotelsFetchSuccessEvent>(_fetchSuccess);
    on<HotelsFetchFailureEvent>(_fetchFailure);
  }

  Future<void> _updateSearch(
    HotelsSearchUpdateEvent event,
    Emitter<HotelsState> emit,
  ) async {
    emit.call(
      HotelsState(params: event.params),
    );
    if (event.params.query.isNotEmpty) {
      add(HotelsFetchNextPageEvent());
    }
  }

  Future<void> _fetchNextPage(
    HotelsFetchNextPageEvent event,
    Emitter<HotelsState> emit,
  ) async {
    emit.call(
      state.copyWith(
        loading: true,
        error: null,
        setError: true,
      ),
    );
    try {
      final response = await _fetchHotelsUseCase.call(
        params: state.params,
        pageToken: state.nextPageToken,
      );
      add(HotelsFetchSuccessEvent(response: response));
    } on Exception catch (error) {
      add(HotelsFetchFailureEvent(error: error));
    }
  }

  void _fetchSuccess(
    HotelsFetchSuccessEvent event,
    Emitter<HotelsState> emit,
  ) {
    emit.call(
      state.copyWith(
        loading: false,
        items: [
          ...state.items,
          ...event.response.items,
        ],
        nextPageToken: event.response.nextPageToken,
        setNextPageToken: true,
        hasReachedMax: event.response.nextPageToken == null,
        error: null,
        setError: true,
      ),
    );
  }

  void _fetchFailure(
    HotelsFetchFailureEvent event,
    Emitter<HotelsState> emit,
  ) {
    emit.call(
      state.copyWith(
        loading: false,
        error: event.error,
      ),
    );
  }
}
