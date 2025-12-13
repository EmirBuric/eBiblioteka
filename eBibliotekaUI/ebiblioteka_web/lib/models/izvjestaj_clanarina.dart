import 'package:ebiblioteka_web/models/izvjestaj_tip_clanarine.dart';
import 'package:json_annotation/json_annotation.dart';

part 'izvjestaj_clanarina.g.dart';

@JsonSerializable()
class ClanarinaIzvjestaj {
  double? ukupnaZarada;
  List<TipIzvjestaj>? tipIzvjestaji;

  ClanarinaIzvjestaj({
    this.ukupnaZarada,
    this.tipIzvjestaji,
  });

  factory ClanarinaIzvjestaj.fromJson(Map<String, dynamic> json) =>
      _$ClanarinaIzvjestajFromJson(json);

  Map<String, dynamic> toJson() => _$ClanarinaIzvjestajToJson(this);
}
