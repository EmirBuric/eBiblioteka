import 'package:json_annotation/json_annotation.dart';

part 'autor.g.dart';

@JsonSerializable()
class Autor {
  int? autorId;
  String? ime;
  String? prezime;
  DateTime? datumRodjenja;
  String? biografija;

  Autor({this.autorId, this.ime, this.prezime});

  factory Autor.fromJson(Map<String, dynamic> json) => _$AutorFromJson(json);

  Map<String, dynamic> toJson() => _$AutorToJson(this);
}
