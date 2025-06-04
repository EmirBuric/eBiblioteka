import 'package:ebiblioteka_mobile/models/knjiga.dart';
import 'package:json_annotation/json_annotation.dart';

part 'korisnik_izabrana_knjiga.g.dart';

@JsonSerializable()
class KorisnikIzabranaKnjiga {
  int? korisnikIzabranaKnjigaId;
  int? korisnikId;
  int? knjigaId;
  DateTime? datumRezervacije;
  DateTime? datumVracanja;
  bool? isChecked;
  Knjiga? knjiga;

  KorisnikIzabranaKnjiga(
      {this.korisnikIzabranaKnjigaId,
      this.korisnikId,
      this.knjigaId,
      this.datumRezervacije,
      this.datumVracanja,
      this.isChecked});

  factory KorisnikIzabranaKnjiga.fromJson(Map<String, dynamic> json) =>
      _$KorisnikIzabranaKnjigaFromJson(json);

  Map<String, dynamic> toJson() => _$KorisnikIzabranaKnjigaToJson(this);
}
