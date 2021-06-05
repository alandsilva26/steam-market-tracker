import "./steam_item.dart";

class SteamItemGroup {
  String groupId;
  List<SteamItem> steamItems;

  SteamItemGroup({
    this.groupId,
    this.steamItems,
  });

  factory SteamItemGroup.fromJson(Map<String, dynamic> json) {
    return SteamItemGroup(
      groupId: json["groupId"],
      steamItems: json["steamItems"].map((item) => SteamItem.fromJson(item)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "groupId": this.groupId,
      "steamItems": this.steamItems.map((SteamItem item) => item.toJson()),
    };
  }
}
