import 'package:json_annotation/json_annotation.dart';

part 'knjiga.g.dart';

@JsonSerializable()
class Knjiga {
  int? knjigaId;
  String? naziv;
  String? kratkiOpis;
  int? godinaIzdanja;
  List<int>? slika;
  int? zanrId;
  bool? isDeleted;
  DateTime? vrijemeBrisanja;
  int? kolicina;
  bool? dostupna;
  bool? knjigaDana;
  List<int>? autoriIds;

  Knjiga({
    this.knjigaId,
    this.naziv,
    this.autoriIds,
  });

  factory Knjiga.fromJson(Map<String, dynamic> json) => _$KnjigaFromJson(json);

  Map<String, dynamic> toJson() => _$KnjigaToJson(this);
}

class KnjigaInsert {
  String? naziv;
  String? kratkiOpis;
  int? godinaIzdanja;
  List<int>? slika; // image bytes
  int? zanrId;
  int? kolicina;
  List<int>? autori;

  KnjigaInsert({
    this.naziv,
    this.kratkiOpis,
    this.godinaIzdanja,
    this.slika,
    this.zanrId,
    this.kolicina,
    this.autori,
  });
}
