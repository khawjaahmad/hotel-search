// test/helpers/test_data_factory.dart
import 'package:hotel_booking/core/models/models.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';

class TestDataFactory {
  // Hotel Test Data
  static const Hotel defaultHotel = Hotel(
    name: 'Test Hotel',
    location: Location(latitude: 40.7128, longitude: -74.0060),
    description: 'A beautiful test hotel in New York',
  );

  static const Hotel hotelWithoutDescription = Hotel(
    name: 'Simple Hotel',
    location: Location(latitude: 41.8781, longitude: -87.6298),
  );

  static const Hotel anotherHotel = Hotel(
    name: 'Another Hotel',
    location: Location(latitude: 34.0522, longitude: -118.2437),
    description: 'A hotel in Los Angeles',
  );

  static List<Hotel> get multipleHotels => [
    defaultHotel,
    hotelWithoutDescription,
    anotherHotel,
  ];

  // Location Test Data
  static const Location newYorkLocation = Location(
    latitude: 40.7128, 
    longitude: -74.0060,
  );

  static const Location chicagoLocation = Location(
    latitude: 41.8781, 
    longitude: -87.6298,
  );

  static const Location losAngelesLocation = Location(
    latitude: 34.0522, 
    longitude: -118.2437,
  );

  // SearchParams Test Data
  static SearchParams get defaultSearchParams => SearchParams(
    query: 'New York',
    checkInDate: DateTime(2024, 6, 15),
    checkOutDate: DateTime(2024, 6, 17),
  );

  static SearchParams get emptyQuerySearchParams => SearchParams(
    query: '',
    checkInDate: DateTime(2024, 6, 15),
    checkOutDate: DateTime(2024, 6, 17),
  );

  static SearchParams get differentCitySearchParams => SearchParams(
    query: 'Boston',
    checkInDate: DateTime(2024, 7, 1),
    checkOutDate: DateTime(2024, 7, 3),
  );

  // PaginatedResponse Test Data
  static PaginatedResponse<Hotel> get firstPageResponse => PaginatedResponse(
    items: [defaultHotel, hotelWithoutDescription],
    nextPageToken: 'page_2_token',
  );

  static PaginatedResponse<Hotel> get lastPageResponse => PaginatedResponse(
    items: [anotherHotel],
    nextPageToken: null,
  );

  static PaginatedResponse<Hotel> get emptyResponse => const PaginatedResponse(
    items: [],
    nextPageToken: null,
  );

  // Edge Cases
  static SearchParams get singleDaySearchParams => SearchParams(
    query: 'Same Day Hotel',
    checkInDate: DateTime(2024, 6, 15),
    checkOutDate: DateTime(2024, 6, 15),
  );

  static const Hotel hotelWithSpecialCharacters = Hotel(
    name: 'Hôtel & Café Résidence',
    location: Location(latitude: 48.8566, longitude: 2.3522),
    description: 'A hotel with special characters: & < > " \'',
  );

  static const Hotel hotelWithLongName = Hotel(
    name: 'The Very Long Named Luxury Resort and Spa with Multiple Amenities and Premium Services',
    location: Location(latitude: 25.7617, longitude: -80.1918),
    description: 'A hotel with an extremely long name for testing UI limits',
  );

  // Utility Methods
  static Hotel createHotelWithLocation(double latitude, double longitude) {
    return Hotel(
      name: 'Hotel at $latitude, $longitude',
      location: Location(latitude: latitude, longitude: longitude),
      description: 'A hotel at coordinates $latitude, $longitude',
    );
  }

  static SearchParams createSearchParams({
    String query = 'Default Query',
    DateTime? checkInDate,
    DateTime? checkOutDate,
  }) {
    return SearchParams(
      query: query,
      checkInDate: checkInDate ?? DateTime(2024, 6, 15),
      checkOutDate: checkOutDate ?? DateTime(2024, 6, 17),
    );
  }

  static PaginatedResponse<Hotel> createPaginatedResponse({
    List<Hotel>? items,
    String? nextPageToken,
  }) {
    return PaginatedResponse(
      items: items ?? [defaultHotel],
      nextPageToken: nextPageToken,
    );
  }
}
