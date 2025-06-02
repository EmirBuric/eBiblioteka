import 'package:json_annotation/json_annotation.dart';

part 'citaonica.g.dart';

@JsonSerializable()
class Citaonica {
  int? citaonicaId;
  String? naziv;

  Citaonica({this.citaonicaId, this.naziv});

  factory Citaonica.fromJson(Map<String, dynamic> json) =>
      _$CitaonicaFromJson(json);
  Map<String, dynamic> toJson() => _$CitaonicaToJson(this);
}
