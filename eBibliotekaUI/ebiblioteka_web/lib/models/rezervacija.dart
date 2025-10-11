import 'package:json_annotation/json_annotation.dart';
import 'knjiga.dart';

part 'rezervacija.g.dart';

@JsonSerializable()
class Rezervacija {
  int? rezervacijaId;
  int? knjigaId;
  int? korisnikId;
  DateTime? datumRezervacije;
  DateTime? datumVracanja;
  bool? odobrena;
  Knjiga? knjiga;

  Rezervacija({
    this.rezervacijaId,
    this.knjigaId,
    this.korisnikId,
    this.datumRezervacije,
    this.datumVracanja,
    this.odobrena,
    this.knjiga,
  });

  factory Rezervacija.fromJson(Map<String, dynamic> json) =>
      _$RezervacijaFromJson(json);

  Map<String, dynamic> toJson() => _$RezervacijaToJson(this);
}
