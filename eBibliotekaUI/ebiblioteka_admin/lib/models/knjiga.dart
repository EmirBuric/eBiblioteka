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

  Knjiga({this.knjigaId, this.naziv});

  factory Knjiga.fromJson(Map<String, dynamic> json) => _$KnjigaFromJson(json);

  Map<String, dynamic> toJson() => _$KnjigaToJson(this);
}
