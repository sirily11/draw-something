class User {
  User({
    this.name,
    this.point,
    this.uuid,
  });

  String name;
  double point;
  String uuid;

  factory User.fromJson(Map<String, dynamic> json) => User(
        name: json["name"],
        point: json["point"] == null ? null : json["point"].toDouble(),
        uuid: json["uuid"] == null ? null : json["uuid"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "point": point == null ? null : point,
        "uuid": uuid == null ? null : uuid,
      };

  @override
  String toString() {
    return this.uuid;
  }

  @override
  bool operator ==(o) => o is User && o.uuid == uuid && o.name == name;

  @override
  int get hashCode => uuid.hashCode;
}
