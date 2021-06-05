class SteamItem {
  String id;
  String marketHash;
  String name;
  String gameId;
  String lowestPrice;
  String volume;
  String medianPrice;
  String archivePrice;
  String archiveVolume;

  SteamItem({
    this.id,
    this.marketHash,
    this.name,
    this.gameId,
    this.lowestPrice,
    this.volume,
    this.medianPrice,
    this.archivePrice,
    this.archiveVolume,
  });

  factory SteamItem.fromJson(Map<String, dynamic> json) {
    return SteamItem(
      id: json["id"],
      marketHash: json["marketHash"],
      name: json["name"] ?? "",
      gameId: json["gameId"],
      lowestPrice: json["lowest_price"] ?? "",
      volume: json["volume"] ?? "",
      medianPrice: json["median_price"] ?? "",
      archivePrice: json["archive_price"] ?? "",
      archiveVolume: json["archiveVolume"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "marketHash": this.marketHash ?? "",
      "name": this.name ?? "",
      "gameId": this.gameId,
      "lowest_price": this.lowestPrice ?? "",
      "volume": this.volume ?? "",
      "median_price": this.medianPrice,
      "archive_price": this.archivePrice ?? "",
      "archiveVolume": this.archiveVolume ?? "",
    };
  }
}
