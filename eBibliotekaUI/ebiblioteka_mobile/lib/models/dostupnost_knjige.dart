import 'package:json_annotation/json_annotation.dart';

part 'dostupnost_knjige.g.dart';

@JsonSerializable()
class DostupnostKnjige {
  int? knjigaId;
  Map<DateTime, bool>? dostupnost;

  DostupnostKnjige({
    this.knjigaId,
    this.dostupnost,
  });

  factory DostupnostKnjige.fromJson(Map<String, dynamic> json) =>
      _$DostupnostKnjigeFromJson(json);

  Map<String, dynamic> toJson() => _$DostupnostKnjigeToJson(this);
}
