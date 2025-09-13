import 'package:json_annotation/json_annotation.dart';

part 'korisnik_uloga.g.dart';

@JsonSerializable()
class KorisnikUloga {
  int? korisnikUlogaId;
  int? korisnikId;
  int? ulogaId;

  KorisnikUloga({this.korisnikUlogaId, this.korisnikId, this.ulogaId});

  factory KorisnikUloga.fromJson(Map<String, dynamic> json) =>
      _$KorisnikUlogaFromJson(json);

  Map<String, dynamic> toJson() => _$KorisnikUlogaToJson(this);
}
