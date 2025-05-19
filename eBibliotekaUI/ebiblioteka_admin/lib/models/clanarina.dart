import 'package:json_annotation/json_annotation.dart';

part 'clanarina.g.dart';

@JsonSerializable()
class Clanarina {
  int? clanarinaId;
  String? statusClanarine;
  DateTime? datumUplate;
  DateTime? datumIsteka;
  int? korisnikId;
  int? tipClanarineId;

  Clanarina({
    this.clanarinaId,
    this.korisnikId,
    this.tipClanarineId,
    this.statusClanarine,
    this.datumUplate,
    this.datumIsteka,
  });

  factory Clanarina.fromJson(Map<String, dynamic> json) =>
      _$ClanarinaFromJson(json);

  Map<String, dynamic> toJson() => _$ClanarinaToJson(this);
}
