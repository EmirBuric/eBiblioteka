import 'package:json_annotation/json_annotation.dart';
import 'knjiga.dart';
import 'korisnik.dart';

part 'recenzija.g.dart';

@JsonSerializable()
class Recenzija {
  int? recenzijaId;
  int? knjigaId;
  int? korisnikId;
  String? opis;
  int? ocjena;
  DateTime? datumRecenzije;
  bool? odobrena;
  Knjiga? knjiga;
  Korisnik? korisnik;

  Recenzija(
      {this.recenzijaId,
      this.knjigaId,
      this.korisnikId,
      this.opis,
      this.ocjena,
      this.datumRecenzije,
      this.odobrena});

  factory Recenzija.fromJson(Map<String, dynamic> json) =>
      _$RecenzijaFromJson(json);

  Map<String, dynamic> toJson() => _$RecenzijaToJson(this);
}
