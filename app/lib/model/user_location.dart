import 'package:mnmn/ui/all.dart';

class UserLocation {
  const UserLocation({
    required this.id,
    required this.latLng,
    this.radius,
    this.name,
  });

  factory UserLocation.fromMap(Map<String, dynamic> map) {
    return UserLocation(
      id: map['id'] as int,
      latLng: LatLngExtension.fromPoint(map['point'] as Map<String, dynamic>),
      radius: map['radius'] as int?,
      name: map['name'] as String?,
    );
  }

  final int id;
  final LatLng latLng;
  final int? radius;
  final String? name;

  bool get isPraySite {
    return name != null;
  }

  UserLocation copyWith({
    int? id,
    LatLng? latLng,
    int? radius,
    String? name,
  }) {
    return UserLocation(
      id: id ?? this.id,
      latLng: latLng ?? this.latLng,
      radius: radius ?? this.radius,
      name: name ?? this.name,
    );
  }
}
