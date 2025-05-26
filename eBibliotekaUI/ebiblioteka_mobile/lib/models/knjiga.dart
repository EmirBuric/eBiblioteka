import 'package:json_annotation/json_annotation.dart';

part 'knjiga.g.dart';

@JsonSerializable()
class Knjiga {
  int? knjigaId;
  String? naziv;
  String? kratkiOpis;
  int? godinaIzdanja;
  String? slika;
  int? zanrId;
  bool? isDeleted;
  DateTime? vrijemeBrisanja;
  int? kolicina;
  bool? dostupna;
  bool? knjigaDana;
  bool? preporuceno;
  List<int>? autoriIds;

  Knjiga({
    this.knjigaId,
    this.naziv,
    this.kratkiOpis,
    this.godinaIzdanja,
    this.slika,
    this.zanrId,
    this.isDeleted,
    this.vrijemeBrisanja,
    this.kolicina,
    this.dostupna,
    this.knjigaDana,
    this.preporuceno,
    this.autoriIds,
  });

  factory Knjiga.fromJson(Map<String, dynamic> json) => _$KnjigaFromJson(json);

  Map<String, dynamic> toJson() => _$KnjigaToJson(this);
}
