// import "package:flutter/material.dart";

class PriceArchive {
  String marketHash;
  List<Price> prices;

  PriceArchive({
    this.marketHash,
    this.prices,
  });

  factory PriceArchive.fromJson(Map<String, dynamic> jsonData) {
    return PriceArchive(
      marketHash: jsonData["market_hash"] ?? "",
      prices:
          jsonData["prices"] ?? [].map((item) => Price.fromJson(item)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "market_hash": this.marketHash,
      "prices": this.prices.map((Price price) => price.toMap()).toList(),
    };
  }
}

class Price {
  String price;
  DateTime timeStamp;

  Price({
    this.price,
    this.timeStamp,
  });

  factory Price.fromJson(Map<String, dynamic> jsonData) {
    return Price(
      price: jsonData["price"] ?? "",
      timeStamp: jsonData["timeStamp"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "price": this.price,
      "timeStamp": this.timeStamp.toString(),
    };
  }
}
