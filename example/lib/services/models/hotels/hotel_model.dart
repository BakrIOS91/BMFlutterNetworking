class Hotels {
  List<Hotel>? hotels;
  Pagination? pagination;

  Hotels({
    this.hotels,
    this.pagination,
  });

  factory Hotels.fromJson(Map<String, dynamic> json) => Hotels(
        hotels: json["hotels"] == null
            ? []
            : List<Hotel>.from(json["hotels"]!.map((x) => Hotel.fromJson(x))),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "hotels": hotels == null
            ? []
            : List<dynamic>.from(hotels!.map((x) => x.toJson())),
        "pagination": pagination?.toJson(),
      };
}

class Pagination {
  int? pageIndex;
  int? pageSize;
  int? totalCount;
  bool? shouldPaginate;

  Pagination({
    this.pageIndex,
    this.pageSize,
    this.totalCount,
    this.shouldPaginate,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        pageIndex: json["page_index"],
        pageSize: json["page_size"],
        totalCount: json["total_count"],
        shouldPaginate: json["should_paginate"],
      );

  Map<String, dynamic> toJson() => {
        "page_index": pageIndex,
        "page_size": pageSize,
        "total_count": totalCount,
        "should_paginate": shouldPaginate,
      };
}

class Hotel {
  int? id;
  String? title;
  String? image;
  String? description;
  int? pricePerNight;
  double? rate;
  int? beds;
  int? bathrooms;
  bool? instantBook;
  String? phone;
  Category? category;
  Location? location;
  List<Facility>? facilities;
  bool? isFavorite;

  Hotel({
    this.id,
    this.title,
    this.image,
    this.description,
    this.pricePerNight,
    this.rate,
    this.beds,
    this.bathrooms,
    this.instantBook,
    this.phone,
    this.category,
    this.location,
    this.facilities,
    this.isFavorite,
  });

  Hotel copyWith(
      {int? id,
      String? title,
      String? image,
      String? description,
      int? pricePerNight,
      double? rate,
      int? beds,
      int? bathrooms,
      bool? instantBook,
      String? phone,
      Category? category,
      Location? location,
      List<Facility>? facilities,
      bool? isFavorite}) {
    return Hotel(
        id: id ?? this.id,
        title: title ?? this.title,
        image: image ?? this.image,
        description: description ?? this.description,
        pricePerNight: pricePerNight ?? this.pricePerNight,
        rate: rate ?? this.rate,
        beds: beds ?? this.beds,
        bathrooms: bathrooms ?? this.bathrooms,
        instantBook: instantBook ?? this.instantBook,
        phone: phone ?? this.phone,
        category: category ?? this.category,
        location: location ?? this.location,
        facilities: facilities ?? this.facilities,
        isFavorite: isFavorite ?? this.isFavorite);
  }

  factory Hotel.fromJson(Map<String, dynamic> json) => Hotel(
        id: json["id"],
        title: json["title"],
        image: json["image"],
        description: json["description"],
        pricePerNight: json["price_per_night"],
        rate: json["rate"]?.toDouble(),
        beds: json["beds"],
        bathrooms: json["bathrooms"],
        instantBook: json["instant_book"],
        phone: json["phone"],
        category: json["category"] == null
            ? null
            : Category.fromJson(json["category"]),
        location: json["location"] == null
            ? null
            : Location.fromJson(json["location"]),
        facilities: json["facilities"] == null
            ? []
            : List<Facility>.from(
                json["facilities"]!.map((x) => Facility.fromJson(x))),
        isFavorite: json["is_favorite"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "image": image,
        "description": description,
        "price_per_night": pricePerNight,
        "rate": rate,
        "beds": beds,
        "bathrooms": bathrooms,
        "instant_book": instantBook,
        "phone": phone,
        "category": category?.toJson(),
        "location": location?.toJson(),
        "facilities": facilities == null
            ? []
            : List<dynamic>.from(facilities!.map((x) => x.toJson())),
        "is_favorite": isFavorite,
      };
}

class Category {
  int? id;
  String? icon;
  String? title;

  Category({
    this.id,
    this.icon,
    this.title,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        icon: json["icon"],
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "icon": icon,
        "title": title,
      };
}

class Facility {
  String? icon;
  int? categoryId;
  String? categoryTitle;
  List<String>? subFacilities;

  Facility({
    this.icon,
    this.categoryId,
    this.categoryTitle,
    this.subFacilities,
  });

  factory Facility.fromJson(Map<String, dynamic> json) => Facility(
        icon: json["icon"],
        categoryId: json["category_id"],
        categoryTitle: json["category_title"],
        subFacilities: json["sub_facilities"] == null
            ? []
            : List<String>.from(json["sub_facilities"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "icon": icon,
        "category_id": categoryId,
        "category_title": categoryTitle,
        "sub_facilities": subFacilities == null
            ? []
            : List<dynamic>.from(subFacilities!.map((x) => x)),
      };
}

class Location {
  double? lat;
  double? lon;
  City? city;
  String? address;

  Location({
    this.lat,
    this.lon,
    this.city,
    this.address,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        lat: json["lat"]?.toDouble(),
        lon: json["lon"]?.toDouble(),
        city: json["city"] == null ? null : City.fromJson(json["city"]),
        address: json["address"],
      );

  Map<String, dynamic> toJson() => {
        "lat": lat,
        "lon": lon,
        "city": city?.toJson(),
        "address": address,
      };
}

class City {
  int? id;
  String? name;

  City({
    this.id,
    this.name,
  });

  factory City.fromJson(Map<String, dynamic> json) => City(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
