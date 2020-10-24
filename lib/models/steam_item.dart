class SteamItem {
  String id;
  String name;
  String lowestPrice;
  String volume;
  String medianPrice;

  SteamItem(
      {this.id, this.name, this.lowestPrice, this.volume, this.medianPrice});

  factory SteamItem.fromJson(Map<String, dynamic> json) {
    return SteamItem(
      id: json["id"],
      name: json["name"],
      lowestPrice: json["lowest_price"],
      volume: json["volume"],
      medianPrice: json["median_price"],
    );
  }
}
