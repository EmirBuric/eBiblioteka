import 'package:json_annotation/json_annotation.dart';

part 'izvjestaj_knjiga.g.dart';

@JsonSerializable()
class IzvjestajKnjiga {
  int? knjigaId;
  String? naziv;
  Map<String, int>? rezervacijePoMjesecu;
  Map<int, int>? recenzijePoOcjeni;
  double? prosjecnaOcjena;

  IzvjestajKnjiga({
    this.knjigaId,
    this.naziv,
    this.rezervacijePoMjesecu,
    this.recenzijePoOcjeni,
    this.prosjecnaOcjena,
  });

  factory IzvjestajKnjiga.fromJson(Map<String, dynamic> json) =>
      _$IzvjestajKnjigaFromJson(json);

  Map<String, dynamic> toJson() => _$IzvjestajKnjigaToJson(this);
}
