import 'package:json_annotation/json_annotation.dart';

part 'izvjestaj_tip_clanarine.g.dart';

@JsonSerializable()
class TipIzvjestaj {
  int? tipClanarineId;
  int? brojPoTipu;
  int? zaradaPoTipu;

  TipIzvjestaj({
    this.tipClanarineId,
    this.brojPoTipu,
    this.zaradaPoTipu,
  });

  factory TipIzvjestaj.fromJson(Map<String, dynamic> json) =>
      _$TipIzvjestajFromJson(json);

  Map<String, dynamic> toJson() => _$TipIzvjestajToJson(this);
}
