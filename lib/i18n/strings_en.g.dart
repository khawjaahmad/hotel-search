///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations implements BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsOverviewEn overview = TranslationsOverviewEn._(_root);
	late final TranslationsHotelsEn hotels = TranslationsHotelsEn._(_root);
	late final TranslationsFavoritesEn favorites = TranslationsFavoritesEn._(_root);
	late final TranslationsAccountEn account = TranslationsAccountEn._(_root);
}

// Path: overview
class TranslationsOverviewEn {
	TranslationsOverviewEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Hotel Booking';
	String get label => 'Overview';
}

// Path: hotels
class TranslationsHotelsEn {
	TranslationsHotelsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get search => 'Search Hotels';
	String get label => 'Hotels';
	late final TranslationsHotelsErrorEn error = TranslationsHotelsErrorEn._(_root);
}

// Path: favorites
class TranslationsFavoritesEn {
	TranslationsFavoritesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Your Favorite Hotels';
	String get label => 'Favorites';
}

// Path: account
class TranslationsAccountEn {
	TranslationsAccountEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Your Account';
	String get label => 'Account';
}

// Path: hotels.error
class TranslationsHotelsErrorEn {
	TranslationsHotelsErrorEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get message => 'Something went wrong';
	String get retry => 'Try Again';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.
extension on Translations {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'overview.title': return 'Hotel Booking';
			case 'overview.label': return 'Overview';
			case 'hotels.search': return 'Search Hotels';
			case 'hotels.label': return 'Hotels';
			case 'hotels.error.message': return 'Something went wrong';
			case 'hotels.error.retry': return 'Try Again';
			case 'favorites.title': return 'Your Favorite Hotels';
			case 'favorites.label': return 'Favorites';
			case 'account.title': return 'Your Account';
			case 'account.label': return 'Account';
			default: return null;
		}
	}
}

