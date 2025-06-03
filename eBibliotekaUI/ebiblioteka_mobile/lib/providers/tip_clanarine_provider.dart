import 'package:ebiblioteka_mobile/models/tip_clanarine.dart';
import 'package:ebiblioteka_mobile/providers/base_provider.dart';

class TipClanarineProvider extends BaseProvider<TipClanarine> {
  TipClanarineProvider() : super("TipClanarine");

  @override
  TipClanarine fromJson(data) {
    return TipClanarine.fromJson(data);
  }
}
