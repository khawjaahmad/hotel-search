import 'package:flutter/material.dart';
import 'package:hotel_booking/features/hotels/domain/entities/entities.dart';

class HotelCard extends StatelessWidget {
  const HotelCard({
    super.key,
    required this.hotel,
    required this.isFavorite,
    required this.onFavoriteChanged,
  });

  final Hotel hotel;
  final bool isFavorite;
  final ValueChanged<bool> onFavoriteChanged;

  @override
  Widget build(BuildContext context) {
    // Using hotel's location coordinates as unique identifier for keys
    final hotelId = hotel.location.decimalDegrees;

    return Card.filled(
      key: Key('hotel_card_$hotelId'),
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      hotel.name,
                      key: Key('hotel_name_$hotelId'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (hotel.description != null)
                      Text(
                        hotel.description!,
                        key: Key('hotel_description_$hotelId'),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                  ],
                ),
              ),
            ),
            IconButton(
              key: Key('hotel_favorite_button_$hotelId'),
              icon: Icon(Icons.favorite_outline),
              selectedIcon: Icon(Icons.favorite),
              isSelected: isFavorite,
              onPressed: () => onFavoriteChanged(!isFavorite),
            ),
          ],
        ),
      ),
    );
  }
}
