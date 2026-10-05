class Lookup {
  List<City>? cities;
  List<Category>? hotelCategories;
  List<Category>? facilitiesCategories;

  Lookup({
    this.cities,
    this.hotelCategories,
    this.facilitiesCategories,
  });

  factory Lookup.fromJson(Map<String, dynamic> json) => Lookup(
        cities: json["cities"] == null
            ? []
            : List<City>.from(json["cities"]!.map((x) => City.fromJson(x))),
        hotelCategories: json["hotel_categories"] == null
            ? []
            : List<Category>.from(
                json["hotel_categories"]!.map((x) => Category.fromJson(x))),
        facilitiesCategories: json["facilities_categories"] == null
            ? []
            : List<Category>.from(json["facilities_categories"]!
                .map((x) => Category.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "cities": cities == null
            ? []
            : List<dynamic>.from(cities!.map((x) => x.toJson())),
        "hotel_categories": hotelCategories == null
            ? []
            : List<dynamic>.from(hotelCategories!.map((x) => x.toJson())),
        "facilities_categories": facilitiesCategories == null
            ? []
            : List<dynamic>.from(facilitiesCategories!.map((x) => x.toJson())),
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

class Category {
  int? id;
  String? title;
  String? iconUrl;
  List<SubFacility>? subFacilities;

  Category({
    this.id,
    this.title,
    this.iconUrl,
    this.subFacilities,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        title: json["title"],
        iconUrl: json["icon_url"],
        subFacilities: json["sub_facilities"] == null
            ? []
            : List<SubFacility>.from(
                json["sub_facilities"]!.map((x) => SubFacility.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "icon_url": iconUrl,
        "sub_facilities": subFacilities == null
            ? []
            : List<dynamic>.from(subFacilities!.map((x) => x.toJson())),
      };
}

class SubFacility {
  int? id;
  String? title;

  SubFacility({
    this.id,
    this.title,
  });

  factory SubFacility.fromJson(Map<String, dynamic> json) => SubFacility(
        id: json["id"],
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
      };
}
