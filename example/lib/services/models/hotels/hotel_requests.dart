import 'package:flutter/foundation.dart';

class PopularHotelsRequest {
  final String? lang;
  final int pageIndex;
  final int pageSize;

  const PopularHotelsRequest({
    this.lang,
    this.pageIndex = 1,
    this.pageSize = 10,
  });

  PopularHotelsRequest copyWith({
    String? lang,
    int? pageIndex,
    int? pageSize,
  }) {
    return PopularHotelsRequest(
      lang: lang ?? this.lang,
      pageIndex: pageIndex ?? this.pageIndex,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  factory PopularHotelsRequest.fromJson(Map<String, dynamic> json) {
    return PopularHotelsRequest(
      lang: json['lang'],
      pageIndex: json['page_index'] ?? 1,
      pageSize: json['page_size'] ?? 10,
    );
  }

  Map<String, dynamic> toJson() => {
        'lang': lang,
        'page_index': pageIndex,
        'page_size': pageSize,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PopularHotelsRequest &&
          lang == other.lang &&
          pageIndex == other.pageIndex &&
          pageSize == other.pageSize;

  @override
  int get hashCode => lang.hashCode ^ pageIndex.hashCode ^ pageSize.hashCode;
}

class FilterHotelsRequest {
  static const Object _sentinel = Object();

  final int? catId;
  final int minPrice;
  final int maxPrice;
  final String? cityName;
  final int? minRating;
  final String? lang;
  final bool pInstantBook;
  final List<int> facilitiesIds;
  final String? searchText;
  final int pageIndex;
  final int pageSize;

  const FilterHotelsRequest({
    this.catId,
    this.minPrice = 0,
    this.maxPrice = 200,
    this.cityName,
    this.minRating,
    this.lang,
    this.pInstantBook = false,
    this.facilitiesIds = const [],
    this.searchText,
    this.pageIndex = 1,
    this.pageSize = 100,
  });

  bool get isFilterActive =>
      minPrice != 0 ||
      maxPrice != 200 ||
      cityName != null ||
      minRating != null ||
      pInstantBook ||
      facilitiesIds.isNotEmpty;

  FilterHotelsRequest copyWith({
    Object? catId = _sentinel,
    int? minPrice,
    int? maxPrice,
    Object? cityName = _sentinel,
    Object? minRating = _sentinel,
    Object? lang = _sentinel,
    bool? pInstantBook,
    List<int>? facilitiesIds,
    Object? searchText = _sentinel,
    int? pageIndex,
    int? pageSize,
  }) {
    return FilterHotelsRequest(
      catId: identical(catId, _sentinel) ? this.catId : catId as int?,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      cityName:
          identical(cityName, _sentinel) ? this.cityName : cityName as String?,
      minRating:
          identical(minRating, _sentinel) ? this.minRating : minRating as int?,
      lang: identical(lang, _sentinel) ? this.lang : lang as String?,
      pInstantBook: pInstantBook ?? this.pInstantBook,
      facilitiesIds: facilitiesIds ?? this.facilitiesIds,
      searchText: identical(searchText, _sentinel)
          ? this.searchText
          : searchText as String?,
      pageIndex: pageIndex ?? this.pageIndex,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  factory FilterHotelsRequest.fromJson(Map<String, dynamic> json) {
    return FilterHotelsRequest(
      catId: json['cat_id'],
      minPrice: json['min_price'] ?? 0,
      maxPrice: json['max_price'] ?? 200,
      cityName: json['city_name'],
      minRating: json['min_rating'],
      lang: json['lang'],
      pInstantBook: json['p_instant_book'] ?? false,
      facilitiesIds: _facilitiesFromJson(json['facilities_ids']),
      searchText: json['search_text'],
      pageIndex: json['page_index'] ?? 1,
      pageSize: json['page_size'] ?? 10,
    );
  }

  Map<String, dynamic> toJson() => {
        'cat_id': catId,
        'min_price': minPrice,
        'max_price': maxPrice,
        'city_name': cityName,
        'min_rating': minRating,
        'lang': lang,
        'p_instant_book': pInstantBook,
        'facilities_ids': _facilitiesToJson(facilitiesIds),
        'search_text': searchText,
        'page_index': pageIndex,
        'page_size': pageSize,
      };

  static String? _facilitiesToJson(List<int> ids) =>
      ids.isEmpty ? null : ids.join(',');

  static List<int> _facilitiesFromJson(dynamic json) {
    if (json == null) return [];
    if (json is String) {
      if (json.isEmpty) return [];
      return json
          .split(',')
          .map((e) => int.tryParse(e))
          .whereType<int>()
          .toList();
    }
    if (json is List) {
      return json.map((e) => e as int).toList();
    }
    return [];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterHotelsRequest &&
          catId == other.catId &&
          minPrice == other.minPrice &&
          maxPrice == other.maxPrice &&
          cityName == other.cityName &&
          minRating == other.minRating &&
          lang == other.lang &&
          pInstantBook == other.pInstantBook &&
          listEquals(facilitiesIds, other.facilitiesIds) &&
          searchText == other.searchText &&
          pageIndex == other.pageIndex &&
          pageSize == other.pageSize;

  @override
  int get hashCode =>
      catId.hashCode ^
      minPrice.hashCode ^
      maxPrice.hashCode ^
      cityName.hashCode ^
      minRating.hashCode ^
      lang.hashCode ^
      pInstantBook.hashCode ^
      facilitiesIds.hashCode ^
      searchText.hashCode ^
      pageIndex.hashCode ^
      pageSize.hashCode;
}
